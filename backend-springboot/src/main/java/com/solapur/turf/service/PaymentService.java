package com.solapur.turf.service;

import com.razorpay.Order;
import com.razorpay.RazorpayClient;
import com.razorpay.Utils;
import com.solapur.turf.dto.*;
import com.solapur.turf.entity.Booking;
import com.solapur.turf.entity.Transaction;
import com.solapur.turf.entity.User;
import com.solapur.turf.enums.BookingStatus;
import com.solapur.turf.enums.PaymentStatus;
import com.solapur.turf.enums.TransactionStatus;
import com.solapur.turf.enums.TransactionType;
import com.solapur.turf.exception.ApiException;
import com.solapur.turf.repository.BookingRepository;
import com.solapur.turf.repository.TransactionRepository;
import com.solapur.turf.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class PaymentService {

    private final RazorpayClient razorpayClient;
    private final TransactionRepository transactionRepository;
    private final BookingRepository bookingRepository;
    private final UserRepository userRepository;
    private final WalletService walletService;
    private final NotificationService notificationService;

    @Value("${razorpay.key.secret}")
    private String keySecret;

    @Value("${razorpay.webhook.secret:}")
    private String webhookSecret;

    public void handleWebhook(String payload, String signature) {
        try {
            // Verify signature
            if (webhookSecret != null && !webhookSecret.isEmpty()) {
                boolean isValid = Utils.verifyWebhookSignature(payload, signature, webhookSecret);
                if (!isValid) {
                    log.error("Invalid webhook signature received from Razorpay");
                    throw new ApiException("Invalid webhook signature", HttpStatus.BAD_REQUEST);
                }
            }

            JSONObject event = new JSONObject(payload);
            String eventName = event.getString("event");
            JSONObject paymentEntity = event.getJSONObject("payload")
                    .getJSONObject("payment")
                    .getJSONObject("entity");

            String orderId = paymentEntity.optString("order_id");
            String paymentId = paymentEntity.optString("id");

            log.info("Processing Razorpay webhook event: {} for order: {}", eventName, orderId);

            if (orderId == null || orderId.isEmpty()) return;

            Transaction transaction = transactionRepository.findByGatewayOrderId(orderId).orElse(null);
            if (transaction == null) {
                log.warn("Transaction not found for orderId: {}", orderId);
                return;
            }

            if ("payment.captured".equals(eventName)) {
                if (transaction.getStatus() != TransactionStatus.SUCCESS) {
                    processSuccessfulPayment(transaction, paymentId, signature);
                }
            } else if ("payment.failed".equals(eventName)) {
                if (transaction.getStatus() == TransactionStatus.PENDING) {
                    processFailedPayment(transaction, paymentId, paymentEntity.optString("error_description"));
                }
            }
        } catch (Exception e) {
            log.error("Error processing Razorpay webhook: {}", e.getMessage());
        }
    }

    private void processSuccessfulPayment(Transaction transaction, String paymentId, String signature) {
        transaction.setGatewayPaymentId(paymentId);
        transaction.setGatewaySignature(signature);
        transaction.setStatus(TransactionStatus.SUCCESS);
        transactionRepository.save(transaction);

        if (transaction.getTransactionType() == TransactionType.WALLET_TOPUP) {
            TopUpRequest topUpRequest = new TopUpRequest();
            topUpRequest.setAmount(transaction.getAmount());
            topUpRequest.setTransactionReference(paymentId);
            walletService.addFunds(transaction.getUser().getId(), topUpRequest);
            
            notificationService.sendPushNotification(transaction.getUser().getFcmToken(), 
                "Wallet Recharged 💰", "₹" + transaction.getAmount() + " added to your wallet.");
        } else if (transaction.getTransactionType() == TransactionType.BOOKING_PAYMENT && transaction.getBooking() != null) {
            Booking booking = transaction.getBooking();
            booking.setPaymentStatus(PaymentStatus.PAID);
            booking.setBookingStatus(BookingStatus.CONFIRMED);
            bookingRepository.save(booking);

            notificationService.sendPushNotification(transaction.getUser().getFcmToken(), 
                "Slot Confirmed! 🏟️", "Your booking at " + booking.getTurf().getName() + " is confirmed.");
        }
        log.info("Successfully processed payment via webhook for order: {}", transaction.getGatewayOrderId());
    }

    private void processFailedPayment(Transaction transaction, String paymentId, String error) {
        transaction.setStatus(TransactionStatus.FAILED);
        transaction.setGatewayPaymentId(paymentId);
        transaction.setError(error);
        transactionRepository.save(transaction);

        if (transaction.getTransactionType() == TransactionType.BOOKING_PAYMENT && transaction.getBooking() != null) {
            Booking booking = transaction.getBooking();
            booking.setPaymentStatus(PaymentStatus.FAILED);
            booking.setBookingStatus(BookingStatus.CANCELLED);
            booking.setCancellationReason("Payment failed: " + error);
            bookingRepository.save(booking);

            notificationService.sendPushNotification(transaction.getUser().getFcmToken(), 
                "Payment Failed ⚠️", "Your payment for " + booking.getTurf().getName() + " failed.");
        }
        log.info("Marked payment as FAILED via webhook for order: {}", transaction.getGatewayOrderId());
    }

    public PaymentOrderResponse createOrder(PaymentOrderRequest request, UUID userId) {
        try {
            // Amount in paise
            int amount = request.getAmount().multiply(new BigDecimal(100)).intValue();

            JSONObject orderRequest = new JSONObject();
            orderRequest.put("amount", amount);
            orderRequest.put("currency", request.getCurrency() != null ? request.getCurrency() : "INR");
            orderRequest.put("receipt", "txn_" + System.currentTimeMillis());

            Order order = razorpayClient.orders.create(orderRequest);

            // Fetch User
            User user = userRepository.findById(userId)
                    .orElseThrow(() -> new ApiException("User not found", HttpStatus.NOT_FOUND));

            // Optional Booking
            Booking booking = null;
            if (request.getBookingId() != null) {
                booking = bookingRepository.findById(request.getBookingId())
                        .orElseThrow(() -> new ApiException("Booking not found", HttpStatus.NOT_FOUND));
            }

            // Define Transaction Type securely
            TransactionType txType = TransactionType.WALLET_TOPUP;
            if (request.getTransactionType() != null) {
                try {
                    txType = TransactionType.valueOf(request.getTransactionType());
                } catch (IllegalArgumentException e) {
                    txType = TransactionType.WALLET_TOPUP;
                }
            }

            // Save Transaction to DB
            Transaction transaction = Transaction.builder()
                    .user(user)
                    .booking(booking)
                    .transactionType(txType)
                    .amount(request.getAmount())
                    .gatewayOrderId(order.get("id"))
                    .status(TransactionStatus.PENDING)
                    .build();

            transactionRepository.save(transaction);

            return PaymentOrderResponse.builder()
                    .id(order.get("id"))
                    .currency(order.get("currency"))
                    .amount(order.get("amount"))
                    .status(order.get("status"))
                    .build();

        } catch (Exception e) {
            log.error("Error creating Razorpay order: {}", e.getMessage());
            throw new ApiException("Could not create payment order", HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    public boolean verifySignature(PaymentVerificationRequest request, UUID userId) {
        try {
            JSONObject options = new JSONObject();
            options.put("razorpay_order_id", request.getRazorpayOrderId());
            options.put("razorpay_payment_id", request.getRazorpayPaymentId());
            options.put("razorpay_signature", request.getRazorpaySignature());

            boolean isValid = Utils.verifyPaymentSignature(options, keySecret);

            if (isValid) {
                Transaction transaction = transactionRepository.findByGatewayOrderId(request.getRazorpayOrderId())
                        .orElseThrow(() -> new ApiException("Transaction not found", HttpStatus.NOT_FOUND));

                if (!transaction.getUser().getId().equals(userId)) {
                    log.warn("User {} tried to verify transaction {} belonging to user {}", userId, transaction.getId(), transaction.getUser().getId());
                    throw new ApiException("Transaction does not belong to you", HttpStatus.FORBIDDEN);
                }

                if (transaction.getStatus() == TransactionStatus.SUCCESS) {
                    return true; // Already processed
                }

                transaction.setGatewayPaymentId(request.getRazorpayPaymentId());
                transaction.setGatewaySignature(request.getRazorpaySignature());
                transaction.setStatus(TransactionStatus.SUCCESS);
                transactionRepository.save(transaction);

                // Handle logic based on transaction type
                if (transaction.getTransactionType() == TransactionType.WALLET_TOPUP) {
                    TopUpRequest topUpRequest = new TopUpRequest();
                    topUpRequest.setAmount(transaction.getAmount());
                    topUpRequest.setTransactionReference(transaction.getGatewayPaymentId());
                    walletService.addFunds(transaction.getUser().getId(), topUpRequest);
                } else if (transaction.getTransactionType() == TransactionType.BOOKING_PAYMENT && transaction.getBooking() != null) {
                    Booking booking = transaction.getBooking();
                    booking.setPaymentStatus(PaymentStatus.PAID);
                    booking.setBookingStatus(BookingStatus.CONFIRMED);
                    bookingRepository.save(booking);
                }
            }
            return isValid;
        } catch (Exception e) {
            log.error("Signature verification failed: {}", e.getMessage());
            return false;
        }
    }

    public void handlePaymentFailure(PaymentFailureRequest request, UUID userId) {
        try {
            Transaction transaction = transactionRepository.findByGatewayOrderId(request.getRazorpayOrderId())
                    .orElseThrow(() -> new ApiException("Transaction not found", HttpStatus.NOT_FOUND));

            if (!transaction.getUser().getId().equals(userId)) {
                log.warn("User {} tried to report failure for transaction {} belonging to user {}", userId, transaction.getId(), transaction.getUser().getId());
                throw new ApiException("Transaction does not belong to you", HttpStatus.FORBIDDEN);
            }

            transaction.setStatus(TransactionStatus.FAILED);
            transaction.setGatewayPaymentId(request.getRazorpayPaymentId());
            transaction.setError(request.getErrorCode() + ": " + request.getErrorDescription());
            transactionRepository.save(transaction);

            if (transaction.getTransactionType() == TransactionType.BOOKING_PAYMENT && transaction.getBooking() != null) {
                Booking booking = transaction.getBooking();
                // If it was a booking, maybe mark it as failed or keep it pending for a retry
                // Let's mark it as FAILED if it was strictly an online payment attempt
                booking.setPaymentStatus(PaymentStatus.FAILED);
                booking.setBookingStatus(BookingStatus.CANCELLED);
                booking.setCancellationReason("Payment failure: " + request.getErrorDescription());
                bookingRepository.save(booking);
            }
        } catch (Exception e) {
            log.error("Error handling payment failure: {}", e.getMessage());
        }
    }

    public boolean processRefund(PaymentRefundRequest request) {
        try {
            // Find the original transaction
            Transaction originalTransaction = transactionRepository.findByGatewayPaymentId(request.getTransactionId())
                    .orElseThrow(() -> new ApiException("Original transaction not found", HttpStatus.NOT_FOUND));

            // Razorpay refund
            JSONObject refundRequest = new JSONObject();
            refundRequest.put("payment_id", request.getTransactionId());
            if (request.getAmount() != null) {
                refundRequest.put("amount", request.getAmount().multiply(new BigDecimal(100)).intValue());
            }

            com.razorpay.Refund razorpayRefund = razorpayClient.payments.refund(refundRequest);

            // Record refund transaction
            Transaction refundTransaction = Transaction.builder()
                    .user(originalTransaction.getUser())
                    .booking(originalTransaction.getBooking())
                    .transactionType(TransactionType.REFUND)
                    .amount(request.getAmount() != null ? request.getAmount() : originalTransaction.getAmount())
                    .gatewayOrderId(originalTransaction.getGatewayOrderId())
                    .gatewayPaymentId(razorpayRefund.get("id"))
                    .status(TransactionStatus.SUCCESS)
                    .build();

            transactionRepository.save(refundTransaction);

            // Update booking if applicable
            if (originalTransaction.getBooking() != null) {
                Booking booking = originalTransaction.getBooking();
                booking.setPaymentStatus(PaymentStatus.REFUNDED);
                bookingRepository.save(booking);
            }

            return true;
        } catch (Exception e) {
            log.error("Error processing Razorpay refund: {}", e.getMessage());
            return false;
        }
    }

    public boolean processRefundByBookingId(UUID bookingId, BigDecimal amount, String reason) {
        try {
            Transaction originalTransaction = transactionRepository.findByBookingIdAndStatusAndTransactionType(
                    bookingId, TransactionStatus.SUCCESS, TransactionType.BOOKING_PAYMENT)
                    .orElseThrow(() -> new ApiException("Successful booking transaction not found", HttpStatus.NOT_FOUND));

            PaymentRefundRequest refundRequest = new PaymentRefundRequest();
            refundRequest.setTransactionId(originalTransaction.getGatewayPaymentId());
            refundRequest.setAmount(amount);
            refundRequest.setReason(reason);

            return processRefund(refundRequest);
        } catch (Exception e) {
            log.error("Error processing refund for booking {}: {}", bookingId, e.getMessage());
            return false;
        }
    }
}

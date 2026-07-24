package com.solapur.turf.service;

import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import org.springframework.scheduling.annotation.Async;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Service
@RequiredArgsConstructor
@Slf4j
public class EmailService {

    private final JavaMailSender mailSender;

    @Value("${spring.mail.username:}")
    private String fromEmail;

    @Async
    public void sendBookingConfirmation(String toEmail, String userName, String turfName, String bookingDate, String startTime, String endTime, String bookingId, double amount) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            helper.setFrom(fromEmail);
            helper.setTo(toEmail);
            helper.setSubject("✅ Booking Confirmed — " + turfName);

            String htmlContent = "<div style=\"font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 12px;\">" +
                    "<h2 style=\"color: #4CAF50; text-align: center;\">Booking Confirmed!</h2>" +
                    "<p>Hello <strong>" + userName + "</strong>,</p>" +
                    "<p>Your slot has been successfully booked at <strong>" + turfName + "</strong>. Here are the details:</p>" +
                    "<table style=\"width: 100%; border-collapse: collapse; margin: 20px 0;\">" +
                    "  <tr style=\"background-color: #f8f9fa;\">" +
                    "    <td style=\"padding: 10px; border: 1px solid #dee2e6; font-weight: bold;\">Booking ID</td>" +
                    "    <td style=\"padding: 10px; border: 1px solid #dee2e6;\">" + bookingId + "</td>" +
                    "  </tr>" +
                    "  <tr>" +
                    "    <td style=\"padding: 10px; border: 1px solid #dee2e6; font-weight: bold;\">Date</td>" +
                    "    <td style=\"padding: 10px; border: 1px solid #dee2e6;\">" + bookingDate + "</td>" +
                    "  </tr>" +
                    "  <tr style=\"background-color: #f8f9fa;\">" +
                    "    <td style=\"padding: 10px; border: 1px solid #dee2e6; font-weight: bold;\">Time</td>" +
                    "    <td style=\"padding: 10px; border: 1px solid #dee2e6;\">" + startTime + " - " + endTime + "</td>" +
                    "  </tr>" +
                    "  <tr>" +
                    "    <td style=\"padding: 10px; border: 1px solid #dee2e6; font-weight: bold;\">Amount Paid</td>" +
                    "    <td style=\"padding: 10px; border: 1px solid #dee2e6; color: #4CAF50; font-weight: bold;\">₹" + amount + "</td>" +
                    "  </tr>" +
                    "</table>" +
                    "<p style=\"text-align: center; color: #777; font-size: 12px; margin-top: 30px;\">Thank you for using Solapur Turf Booking App!</p>" +
                    "</div>";

            helper.setText(htmlContent, true);
            mailSender.send(message);
            log.info("Booking confirmation email sent successfully to {}", toEmail);
        } catch (Exception e) {
            log.error("Failed to send booking confirmation email to {}: {}", toEmail, e.getMessage());
        }
    }

    @Async
    public void sendBookingCancellation(String toEmail, String userName, String turfName, String bookingDate, String reason) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            helper.setFrom(fromEmail);
            helper.setTo(toEmail);
            helper.setSubject("❌ Booking Cancelled — " + turfName);

            String htmlContent = "<div style=\"font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 12px;\">" +
                    "<h2 style=\"color: #f44336; text-align: center;\">Booking Cancelled</h2>" +
                    "<p>Hello <strong>" + userName + "</strong>,</p>" +
                    "<p>Your booking at <strong>" + turfName + "</strong> scheduled for <strong>" + bookingDate + "</strong> has been cancelled.</p>" +
                    "<p><strong>Reason:</strong> " + reason + "</p>" +
                    "<p>If a refund is applicable, the amount will be credited back to your original payment source or wallet.</p>" +
                    "<p style=\"text-align: center; color: #777; font-size: 12px; margin-top: 30px;\">Thank you for using Solapur Turf Booking App!</p>" +
                    "</div>";

            helper.setText(htmlContent, true);
            mailSender.send(message);
            log.info("Booking cancellation email sent successfully to {}", toEmail);
        } catch (Exception e) {
            log.error("Failed to send booking cancellation email to {}: {}", toEmail, e.getMessage());
        }
    }

    @Async
    public void sendSubscriptionRenewal(String toEmail, String ownerName, String businessName, LocalDateTime expiresAt) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            helper.setFrom(fromEmail);
            helper.setTo(toEmail);
            helper.setSubject("🎉 Subscription Renewed — Solapur Turf Platform");

            String expiryDateStr = expiresAt.format(DateTimeFormatter.ofPattern("dd MMM yyyy, hh:mm a"));

            String htmlContent = "<div style=\"font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 12px;\">" +
                    "<h2 style=\"color: #4CAF50; text-align: center;\">Subscription Renewed Successfully!</h2>" +
                    "<p>Hello <strong>" + ownerName + "</strong>,</p>" +
                    "<p>Thank you for your payment of <strong>₹699</strong>. Your partner account for <strong>" + businessName + "</strong> has been extended.</p>" +
                    "<table style=\"width: 100%; border-collapse: collapse; margin: 20px 0;\">" +
                    "  <tr style=\"background-color: #f8f9fa;\">" +
                    "    <td style=\"padding: 10px; border: 1px solid #dee2e6; font-weight: bold;\">Plan</td>" +
                    "    <td style=\"padding: 10px; border: 1px solid #dee2e6;\">Monthly Partner Plan</td>" +
                    "  </tr>" +
                    "  <tr>" +
                    "    <td style=\"padding: 10px; border: 1px solid #dee2e6; font-weight: bold;\">Price</td>" +
                    "    <td style=\"padding: 10px; border: 1px solid #dee2e6;\">₹699</td>" +
                    "  </tr>" +
                    "  <tr style=\"background-color: #f8f9fa;\">" +
                    "    <td style=\"padding: 10px; border: 1px solid #dee2e6; font-weight: bold;\">New Expiry Date</td>" +
                    "    <td style=\"padding: 10px; border: 1px solid #dee2e6; color: #4CAF50; font-weight: bold;\">" + expiryDateStr + "</td>" +
                    "  </tr>" +
                    "</table>" +
                    "<p>Your turf listings are now fully active and visible to all users looking for bookings in Solapur!</p>" +
                    "<p style=\"text-align: center; color: #777; font-size: 12px; margin-top: 30px;\">Thank you for partnering with us!</p>" +
                    "</div>";

            helper.setText(htmlContent, true);
            mailSender.send(message);
            log.info("Subscription renewal email sent successfully to {}", toEmail);
        } catch (Exception e) {
            log.error("Failed to send subscription renewal email to {}: {}", toEmail, e.getMessage());
        }
    }
}

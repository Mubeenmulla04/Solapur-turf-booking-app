package com.solapur.turf.service;

import com.solapur.turf.dto.UserWalletDto;
import com.solapur.turf.entity.UserWallet;
import com.solapur.turf.entity.WalletTransaction;
import com.solapur.turf.exception.ApiException;
import com.solapur.turf.repository.UserWalletRepository;
import com.solapur.turf.repository.WalletTransactionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class WalletService {

    private final UserWalletRepository userWalletRepository;
    private final WalletTransactionRepository walletTransactionRepository;

    public UserWalletDto getWalletByUserId(UUID userId) {
        UserWallet wallet = userWalletRepository.findByUserId(userId)
                .orElseThrow(() -> new ApiException("Wallet not found for user", HttpStatus.NOT_FOUND));

        return UserWalletDto.builder()
                .id(wallet.getId())
                .balance(wallet.getBalance())
                .totalAdded(wallet.getTotalAdded())
                .totalSpent(wallet.getTotalSpent())
                .build();
    }

    @org.springframework.transaction.annotation.Transactional
    public UserWalletDto addFunds(UUID userId, com.solapur.turf.dto.TopUpRequest request) {
        UserWallet wallet = userWalletRepository.findByUserId(userId)
                .orElseThrow(() -> new ApiException("Wallet not found", HttpStatus.NOT_FOUND));

        wallet.setBalance(wallet.getBalance().add(request.getAmount()));
        wallet.setTotalAdded(wallet.getTotalAdded().add(request.getAmount()));
        userWalletRepository.save(wallet);

        WalletTransaction tx = WalletTransaction.builder()
                .wallet(wallet)
                .amount(request.getAmount())
                .type("CREDIT")
                .description("Wallet Top-up")
                .transactionReference(request.getTransactionReference())
                .build();
        walletTransactionRepository.save(tx);

        return getWalletByUserId(userId);
    }

    @org.springframework.transaction.annotation.Transactional
    public UserWalletDto debitFunds(UUID userId, java.math.BigDecimal amount, String description) {
        UserWallet wallet = userWalletRepository.findByUserId(userId)
                .orElseThrow(() -> new ApiException("Wallet not found", HttpStatus.NOT_FOUND));

        if (wallet.getBalance().compareTo(amount) < 0) {
            throw new ApiException("Insufficient wallet balance", HttpStatus.BAD_REQUEST);
        }

        wallet.setBalance(wallet.getBalance().subtract(amount));
        wallet.setTotalSpent(wallet.getTotalSpent().add(amount));
        userWalletRepository.save(wallet);

        WalletTransaction tx = WalletTransaction.builder()
                .wallet(wallet)
                .amount(amount)
                .type("DEBIT")
                .description(description)
                .build();
        walletTransactionRepository.save(tx);

        return getWalletByUserId(userId);
    }

    public com.solapur.turf.dto.PageResponse<com.solapur.turf.dto.WalletTransactionDto> getTransactions(UUID userId, int page, int limit) {
        UserWallet wallet = userWalletRepository.findByUserId(userId)
                .orElseThrow(() -> new ApiException("Wallet not found", HttpStatus.NOT_FOUND));

        org.springframework.data.domain.Pageable pageable = org.springframework.data.domain.PageRequest.of(Math.max(0, page - 1), limit,
                org.springframework.data.domain.Sort.by(org.springframework.data.domain.Sort.Direction.DESC, "createdAt"));
        
        org.springframework.data.domain.Page<WalletTransaction> txPage = walletTransactionRepository.findByWalletId(wallet.getId(), pageable);
        
        org.springframework.data.domain.Page<com.solapur.turf.dto.WalletTransactionDto> dtoPage = txPage.map(this::mapToTxDto);
        return new com.solapur.turf.dto.PageResponse<>(dtoPage);
    }

    private com.solapur.turf.dto.WalletTransactionDto mapToTxDto(WalletTransaction tx) {
        return com.solapur.turf.dto.WalletTransactionDto.builder()
                .id(tx.getId().toString())
                .amount(tx.getAmount())
                .type(tx.getType())
                .description(tx.getDescription())
                .transactionReference(tx.getTransactionReference())
                .createdAt(tx.getCreatedAt())
                .build();
    }
}

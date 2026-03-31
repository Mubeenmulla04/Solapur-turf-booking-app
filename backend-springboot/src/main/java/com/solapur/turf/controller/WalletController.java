package com.solapur.turf.controller;

import com.solapur.turf.dto.UserWalletDto;
import com.solapur.turf.security.CustomUserDetails;
import com.solapur.turf.service.WalletService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/wallets")
@RequiredArgsConstructor
public class WalletController {

    private final WalletService walletService;

    @GetMapping("/me")
    public ResponseEntity<UserWalletDto> getMyWallet(@AuthenticationPrincipal CustomUserDetails userDetails) {
        return ResponseEntity.ok(walletService.getWalletByUserId(userDetails.getUser().getId()));
    }

    @org.springframework.web.bind.annotation.PostMapping("/topup")
    public ResponseEntity<UserWalletDto> topUp(@AuthenticationPrincipal CustomUserDetails userDetails,
                                               @jakarta.validation.Valid @org.springframework.web.bind.annotation.RequestBody com.solapur.turf.dto.TopUpRequest request) {
        return ResponseEntity.ok(walletService.addFunds(userDetails.getUser().getId(), request));
    }

    @GetMapping("/transactions")
    public ResponseEntity<com.solapur.turf.dto.ApiResponse<com.solapur.turf.dto.PageResponse<com.solapur.turf.dto.WalletTransactionDto>>> getTransactions(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @org.springframework.web.bind.annotation.RequestParam(defaultValue = "1") int page,
            @org.springframework.web.bind.annotation.RequestParam(defaultValue = "10") int limit) {
        com.solapur.turf.dto.PageResponse<com.solapur.turf.dto.WalletTransactionDto> transactions = walletService.getTransactions(
                userDetails.getUser().getId(), page, limit);
        return ResponseEntity.ok(com.solapur.turf.dto.ApiResponse.success(transactions, "Transactions fetched successfully"));
    }
}

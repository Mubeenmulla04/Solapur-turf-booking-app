package com.solapur.turf.enums;

import com.fasterxml.jackson.annotation.JsonCreator;
import java.util.stream.Stream;

/**
 * Payment methods accepted by the platform.
 */
public enum PaymentMethod {
    ONLINE,
    CASH,
    FULL_ONLINE,
    PARTIAL_ONLINE_CASH,
    CASH_ON_BOOKING,
    WALLET;

    @JsonCreator
    public static PaymentMethod fromString(String key) {
        return Stream.of(PaymentMethod.values())
                .filter(pm -> pm.name().equalsIgnoreCase(key))
                .findFirst()
                .orElse(ONLINE); // Default to ONLINE for safety with old records
    }

    public boolean isOnline() {
        return this == ONLINE || this == FULL_ONLINE || this == PARTIAL_ONLINE_CASH || this == WALLET;
    }

    public boolean isCash() {
        return this == CASH || this == CASH_ON_BOOKING || this == PARTIAL_ONLINE_CASH;
    }

    public boolean requiresPrepayment() {
        return this == ONLINE || this == FULL_ONLINE || this == WALLET;
    }
}

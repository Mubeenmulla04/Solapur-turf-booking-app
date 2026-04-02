package com.solapur.turf.service;

import com.solapur.turf.entity.AvailabilitySlot;
import com.solapur.turf.entity.TurfListing;
import com.solapur.turf.entity.TurfOwner;
import com.solapur.turf.enums.SlotStatus;
import com.solapur.turf.exception.ApiException;
import com.solapur.turf.repository.AvailabilitySlotRepository;
import com.solapur.turf.repository.TurfOwnerRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.Optional;
import java.util.UUID;
import com.solapur.turf.repository.TurfListingRepository;

@Service
@RequiredArgsConstructor
public class AvailabilitySlotService {

    private final AvailabilitySlotRepository slotRepository;
    private final TurfOwnerRepository turfOwnerRepository;
    private final TurfListingRepository turfListingRepository;

    /**
     * Toggles the status of a slot between AVAILABLE and BLOCKED.
     * Owners use this to manually reserve slots for phone bookings or maintenance.
     */
    @Transactional
    public AvailabilitySlot toggleSlotBlock(UUID userId, UUID turfId, LocalDate date, LocalTime startTime, LocalTime endTime) {
        TurfListing turf = turfListingRepository.findById(turfId)
                .orElseThrow(() -> new ApiException("Turf not found", HttpStatus.NOT_FOUND));

        // Security: Verify ownership
        verifyOwnership(userId, turf);

        Optional<AvailabilitySlot> existingSlotOpt = slotRepository.findByTurfIdAndDate(turfId, date).stream()
                .filter(s -> s.getStartTime().equals(startTime))
                .findFirst();

        AvailabilitySlot slot;
        if (existingSlotOpt.isPresent()) {
            slot = existingSlotOpt.get();
            if (slot.getStatus() == SlotStatus.BOOKED) {
                throw new ApiException("Cannot block/unblock a slot that is already booked.", HttpStatus.BAD_REQUEST);
            }
            if (slot.getStatus() == SlotStatus.BLOCKED || slot.getStatus() == SlotStatus.MAINTENANCE) {
                slot.setStatus(SlotStatus.AVAILABLE);
            } else {
                slot.setStatus(SlotStatus.BLOCKED);
            }
        } else {
            // Slot doesn't exist yet, which means it was dynamically available. Block it.
            slot = AvailabilitySlot.builder()
                    .turf(turf)
                    .date(date)
                    .startTime(startTime)
                    .endTime(endTime)
                    .status(SlotStatus.BLOCKED)
                    .build();
        }

        return slotRepository.save(slot);
    }

    private void verifyOwnership(UUID userId, TurfListing turf) {
        TurfOwner owner = turfOwnerRepository.findByUserId(userId)
                .orElseThrow(() -> new ApiException("Owner profile not found", HttpStatus.NOT_FOUND));
        
        if (!turf.getOwner().getId().equals(owner.getId())) {
            throw new ApiException("You do not have permission to manage this turf's slots.", HttpStatus.FORBIDDEN);
        }
    }
}

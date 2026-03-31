package com.solapur.turf.service;

import com.solapur.turf.dto.AvailabilitySlotDto;
import com.solapur.turf.dto.PageResponse;
import com.solapur.turf.entity.AvailabilitySlot;
import com.solapur.turf.entity.TurfListing;
import com.solapur.turf.entity.TurfOwner;
import com.solapur.turf.enums.SlotStatus;
import com.solapur.turf.exception.ApiException;
import com.solapur.turf.repository.AvailabilitySlotRepository;
import com.solapur.turf.repository.TurfListingRepository;
import com.solapur.turf.repository.TurfOwnerRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AvailabilitySlotService {

    private final AvailabilitySlotRepository availabilitySlotRepository;
    private final TurfOwnerRepository turfOwnerRepository;
    private final TurfListingRepository turfListingRepository;

    public List<AvailabilitySlotDto> getSlotsByTurfAndDate(UUID turfId, LocalDate date) {
        List<AvailabilitySlot> slots = availabilitySlotRepository.findByTurfIdAndDateOrderByStartTime(turfId, date);
        return slots.stream().map(this::mapToDto).collect(Collectors.toList());
    }

    public List<AvailabilitySlotDto> getSlotsByTurfAndDateRange(UUID turfId, LocalDate startDate, LocalDate endDate) {
        List<AvailabilitySlot> slots = availabilitySlotRepository.findByTurfIdAndDateBetweenOrderByDateAscStartTimeAsc(turfId, startDate, endDate);
        return slots.stream().map(this::mapToDto).collect(Collectors.toList());
    }

    public PageResponse<AvailabilitySlotDto> getSlotsByOwner(UUID userId, int page, int limit, LocalDate date) {
        // Find the turf owner for this user
        TurfOwner owner = turfOwnerRepository.findByUserId(userId)
                .orElseThrow(() -> new ApiException("Turf owner profile not found", HttpStatus.NOT_FOUND));

        Pageable pageable = PageRequest.of(Math.max(0, page - 1), limit,
                Sort.by(Sort.Direction.DESC, "date", "startTime"));

        Page<AvailabilitySlot> slotPage;
        if (date != null) {
            slotPage = availabilitySlotRepository.findByTurfOwnerIdAndDate(owner.getId(), date, pageable);
        } else {
            slotPage = availabilitySlotRepository.findByTurfOwnerId(owner.getId(), pageable);
        }

        return new PageResponse<>(slotPage.map(this::mapToDto));
    }

    public AvailabilitySlotDto createSlot(UUID userId, AvailabilitySlotDto slotDto) {
        // Find the turf owner for this user
        TurfOwner owner = turfOwnerRepository.findByUserId(userId)
                .orElseThrow(() -> new ApiException("Turf owner profile not found", HttpStatus.NOT_FOUND));

        TurfListing turf = turfListingRepository.findById(slotDto.getTurfId())
                .orElseThrow(() -> new ApiException("Turf not found", HttpStatus.NOT_FOUND));

        // Verify ownership
        if (!turf.getOwner().getId().equals(owner.getId())) {
            throw new ApiException("You can only create slots for your own turfs", HttpStatus.FORBIDDEN);
        }

        // Check for overlapping slots
        checkSlotOverlap(turf.getId(), slotDto.getDate(), slotDto.getStartTime(), slotDto.getEndTime(), null);

        AvailabilitySlot slot = AvailabilitySlot.builder()
                .turf(turf)
                .date(slotDto.getDate())
                .startTime(slotDto.getStartTime())
                .endTime(slotDto.getEndTime())
                .status(SlotStatus.AVAILABLE)
                .price(slotDto.getPrice() != null ? slotDto.getPrice() : turf.getHourlyRate())
                .build();

        AvailabilitySlot saved = availabilitySlotRepository.save(slot);
        return mapToDto(saved);
    }

    public List<AvailabilitySlotDto> createBulkSlots(UUID userId, BulkSlotRequest request) {
        // Find the turf owner for this user
        TurfOwner owner = turfOwnerRepository.findByUserId(userId)
                .orElseThrow(() -> new ApiException("Turf owner profile not found", HttpStatus.NOT_FOUND));

        TurfListing turf = turfListingRepository.findById(request.getTurfId())
                .orElseThrow(() -> new ApiException("Turf not found", HttpStatus.NOT_FOUND));

        // Verify ownership
        if (!turf.getOwner().getId().equals(owner.getId())) {
            throw new ApiException("You can only create slots for your own turfs", HttpStatus.FORBIDDEN);
        }

        List<AvailabilitySlot> slots = new ArrayList<>();
        LocalDate currentDate = request.getStartDate();

        while (!currentDate.isAfter(request.getEndDate())) {
            // Check if this day of week is included (if specified)
            if (request.getDaysOfWeek() == null || request.getDaysOfWeek().isEmpty() || 
                request.getDaysOfWeek().contains(currentDate.getDayOfWeek())) {
                
                // Check for overlapping slots
                checkSlotOverlap(turf.getId(), currentDate, request.getStartTime(), request.getEndTime(), null);

                AvailabilitySlot slot = AvailabilitySlot.builder()
                        .turf(turf)
                        .date(currentDate)
                        .startTime(request.getStartTime())
                        .endTime(request.getEndTime())
                        .status(SlotStatus.AVAILABLE)
                        .price(request.getPrice() != null ? request.getPrice() : turf.getHourlyRate())
                        .build();

                slots.add(slot);
            }
            currentDate = currentDate.plusDays(1);
        }

        List<AvailabilitySlot> savedSlots = availabilitySlotRepository.saveAll(slots);
        return savedSlots.stream().map(this::mapToDto).collect(Collectors.toList());
    }

    public AvailabilitySlotDto updateSlot(UUID slotId, UUID userId, AvailabilitySlotDto slotDto) {
        // Find the turf owner for this user
        TurfOwner owner = turfOwnerRepository.findByUserId(userId)
                .orElseThrow(() -> new ApiException("Turf owner profile not found", HttpStatus.NOT_FOUND));

        AvailabilitySlot slot = availabilitySlotRepository.findById(slotId)
                .orElseThrow(() -> new ApiException("Slot not found", HttpStatus.NOT_FOUND));

        // Verify ownership
        if (!slot.getTurf().getOwner().getId().equals(owner.getId())) {
            throw new ApiException("You can only update your own slots", HttpStatus.FORBIDDEN);
        }

        // Check for overlapping slots (excluding current slot)
        checkSlotOverlap(slot.getTurf().getId(), slotDto.getDate(), slotDto.getStartTime(), slotDto.getEndTime(), slotId);

        // Update fields
        if (slotDto.getDate() != null) slot.setDate(slotDto.getDate());
        if (slotDto.getStartTime() != null) slot.setStartTime(slotDto.getStartTime());
        if (slotDto.getEndTime() != null) slot.setEndTime(slotDto.getEndTime());
        if (slotDto.getPrice() != null) slot.setPrice(slotDto.getPrice());

        AvailabilitySlot saved = availabilitySlotRepository.save(slot);
        return mapToDto(saved);
    }

    public void deleteSlot(UUID slotId, UUID userId) {
        // Find the turf owner for this user
        TurfOwner owner = turfOwnerRepository.findByUserId(userId)
                .orElseThrow(() -> new ApiException("Turf owner profile not found", HttpStatus.NOT_FOUND));

        AvailabilitySlot slot = availabilitySlotRepository.findById(slotId)
                .orElseThrow(() -> new ApiException("Slot not found", HttpStatus.NOT_FOUND));

        // Verify ownership
        if (!slot.getTurf().getOwner().getId().equals(owner.getId())) {
            throw new ApiException("You can only delete your own slots", HttpStatus.FORBIDDEN);
        }

        // Check if slot has bookings
        if (slot.getStatus() == SlotStatus.BOOKED) {
            throw new ApiException("Cannot delete a slot that is already booked", HttpStatus.BAD_REQUEST);
        }

        availabilitySlotRepository.delete(slot);
    }

    public AvailabilitySlotDto updateSlotStatus(UUID slotId, UUID userId, String status) {
        // Find the turf owner for this user
        TurfOwner owner = turfOwnerRepository.findByUserId(userId)
                .orElseThrow(() -> new ApiException("Turf owner profile not found", HttpStatus.NOT_FOUND));

        AvailabilitySlot slot = availabilitySlotRepository.findById(slotId)
                .orElseThrow(() -> new ApiException("Slot not found", HttpStatus.NOT_FOUND));

        // Verify ownership
        if (!slot.getTurf().getOwner().getId().equals(owner.getId())) {
            throw new ApiException("You can only update your own slots", HttpStatus.FORBIDDEN);
        }

        try {
            SlotStatus newStatus = SlotStatus.valueOf(status.toUpperCase());
            slot.setStatus(newStatus);
            AvailabilitySlot saved = availabilitySlotRepository.save(slot);
            return mapToDto(saved);
        } catch (IllegalArgumentException e) {
            throw new ApiException("Invalid slot status: " + status, HttpStatus.BAD_REQUEST);
        }
    }

    private void checkSlotOverlap(UUID turfId, LocalDate date, LocalTime startTime, LocalTime endTime, UUID excludeSlotId) {
        List<AvailabilitySlot> existingSlots = availabilitySlotRepository.findByTurfIdAndDate(turfId, date);
        
        for (AvailabilitySlot existing : existingSlots) {
            // Skip the slot we're excluding (for updates)
            if (excludeSlotId != null && existing.getId().equals(excludeSlotId)) {
                continue;
            }
            
            // Check for time overlap
            if (isTimeOverlapping(startTime, endTime, existing.getStartTime(), existing.getEndTime())) {
                throw new ApiException("Slot time overlaps with existing slot", HttpStatus.CONFLICT);
            }
        }
    }

    private boolean isTimeOverlapping(LocalTime start1, LocalTime end1, LocalTime start2, LocalTime end2) {
        return start1.isBefore(end2) && start2.isBefore(end1);
    }

    private AvailabilitySlotDto mapToDto(AvailabilitySlot slot) {
        return AvailabilitySlotDto.builder()
                .id(slot.getId())
                .turfId(slot.getTurf().getId())
                .date(slot.getDate())
                .startTime(slot.getStartTime())
                .endTime(slot.getEndTime())
                .status(slot.getStatus())
                .price(slot.getPrice())
                .turfName(slot.getTurf().getName())
                .turfAddress(slot.getTurf().getAddress())
                .build();
    }

    // DTO for bulk slot creation
    public static class BulkSlotRequest {
        private UUID turfId;
        private LocalDate startDate;
        private LocalDate endDate;
        private LocalTime startTime;
        private LocalTime endTime;
        private BigDecimal price;
        private List<DayOfWeek> daysOfWeek;

        // Getters and setters
        public UUID getTurfId() { return turfId; }
        public void setTurfId(UUID turfId) { this.turfId = turfId; }
        public LocalDate getStartDate() { return startDate; }
        public void setStartDate(LocalDate startDate) { this.startDate = startDate; }
        public LocalDate getEndDate() { return endDate; }
        public void setEndDate(LocalDate endDate) { this.endDate = endDate; }
        public LocalTime getStartTime() { return startTime; }
        public void setStartTime(LocalTime startTime) { this.startTime = startTime; }
        public LocalTime getEndTime() { return endTime; }
        public void setEndTime(LocalTime endTime) { this.endTime = endTime; }
        public BigDecimal getPrice() { return price; }
        public void setPrice(BigDecimal price) { this.price = price; }
        public List<DayOfWeek> getDaysOfWeek() { return daysOfWeek; }
        public void setDaysOfWeek(List<DayOfWeek> daysOfWeek) { this.daysOfWeek = daysOfWeek; }
    }
}

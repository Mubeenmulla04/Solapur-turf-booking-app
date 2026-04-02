package com.solapur.turf.service;

import com.solapur.turf.dto.AvailabilitySlotDto;
import com.solapur.turf.entity.Booking;
import com.solapur.turf.enums.BookingStatus;
import com.solapur.turf.enums.SlotStatus;
import com.solapur.turf.repository.AvailabilitySlotRepository;
import com.solapur.turf.repository.BookingRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import com.solapur.turf.entity.TurfListing;
import com.solapur.turf.repository.TurfListingRepository;
import com.solapur.turf.exception.ResourceNotFoundException;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class SlotService {
 
    private final BookingRepository bookingRepository;
    private final TurfListingRepository turfListingRepository;
    private final AvailabilitySlotRepository availabilitySlotRepository;

    public List<AvailabilitySlotDto> getAvailableSlots(UUID turfId, LocalDate date) {
        return generateSlots(turfId, date).stream()
                .filter(slot -> slot.getStatus() == SlotStatus.AVAILABLE)
                .toList();
    }

    public List<AvailabilitySlotDto> getAllSlots(UUID turfId, LocalDate date) {
        return generateSlots(turfId, date);
    }

    private List<AvailabilitySlotDto> generateSlots(UUID turfId, LocalDate date) {
        // 1. Fetch any existing bookings for this turf/date that are NOT cancelled
        List<Booking> existingBookings = bookingRepository.findByTurfIdAndBookingDateAndBookingStatusNot(
                turfId, date, BookingStatus.CANCELLED);

        // Fetch explicitly saved availability slots (like manually blocked ones)
        List<com.solapur.turf.entity.AvailabilitySlot> explicitSlots = availabilitySlotRepository.findByTurfIdAndDate(turfId, date);

        // 2. If the requested date is today, record the current time to filter past slots
        boolean isToday = date.equals(LocalDate.now());
        LocalTime now = isToday ? LocalTime.now() : null;

        List<AvailabilitySlotDto> dailySlots = new ArrayList<>();

        // 3. Get operating hours from TurfListing
        TurfListing turf = turfListingRepository.findById(turfId)
                .orElseThrow(() -> new ResourceNotFoundException("Turf", "id", turfId));
        
        LocalTime opening = turf.getOpeningTime() != null ? turf.getOpeningTime() : LocalTime.of(6, 0);
        LocalTime closing = turf.getClosingTime() != null ? turf.getClosingTime() : LocalTime.of(23, 0);

        LocalTime currentSlotTime = opening;
        LocalTime closingTime     = closing;

        while (currentSlotTime.isBefore(closingTime)) {
            LocalTime slotEnd          = currentSlotTime.plusHours(1);
            final LocalTime checkStart = currentSlotTime;
            final LocalTime checkEnd   = slotEnd;

            // 4. Check booking overlap
            boolean isBooked = existingBookings.stream().anyMatch(b ->
                    checkStart.isBefore(b.getEndTime()) && checkEnd.isAfter(b.getStartTime())
            );

            // Check explicit slot status (e.g. BLOCKED)
            com.solapur.turf.entity.AvailabilitySlot explicitSlot = explicitSlots.stream()
                    .filter(s -> s.getStartTime().equals(checkStart))
                    .findFirst()
                    .orElse(null);

            // 6. A currently-in-progress slot that is not yet booked is also blocked
            //    to prevent partial-hour bookings (e.g. booking 15 min into the hour)
            SlotStatus status;
            if (isBooked) {
                status = SlotStatus.BOOKED;
            } else if (explicitSlot != null && explicitSlot.getStatus() != SlotStatus.AVAILABLE) {
                status = explicitSlot.getStatus();
            } else if (isToday && checkStart.isBefore(now)) {
                status = SlotStatus.BOOKED;   // slot already started — unavailable
            } else {
                status = SlotStatus.AVAILABLE;
            }

            dailySlots.add(AvailabilitySlotDto.builder()
                    .id(explicitSlot != null ? explicitSlot.getId() : UUID.randomUUID())
                    .turfId(turfId)
                    .date(date)
                    .startTime(checkStart)
                    .endTime(checkEnd)
                    .status(status)
                    .price(BigDecimal.ZERO)   // frontend reads hourly rate from TurfListing
                    .build());

            currentSlotTime = slotEnd;
        }

        return dailySlots;
    }
}

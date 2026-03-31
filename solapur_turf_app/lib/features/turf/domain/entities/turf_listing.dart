import 'package:freezed_annotation/freezed_annotation.dart';

part 'turf_listing.freezed.dart';

enum SportType { football, cricket, basketball, volleyball, tennis, badminton, multiSport }
enum SurfaceType { naturalGrass, artificialGrass, concrete, wooden, clay }

extension SportTypeX on SportType {
  String get label => switch (this) {
        SportType.football => 'Football',
        SportType.cricket => 'Cricket',
        SportType.basketball => 'Basketball',
        SportType.volleyball => 'Volleyball',
        SportType.tennis => 'Tennis',
        SportType.badminton => 'Badminton',
        SportType.multiSport => 'Multi-Sport',
      };

  static SportType fromString(String s) => switch (s.toUpperCase()) {
        'CRICKET' => SportType.cricket,
        'BOX_CRICKET' => SportType.cricket,
        'BASKETBALL' => SportType.basketball,
        'VOLLEYBALL' => SportType.volleyball,
        'TENNIS' => SportType.tennis,
        'BADMINTON' => SportType.badminton,
        'MULTI_SPORT' => SportType.multiSport,
        _ => SportType.football,
      };
}

@freezed
class TurfListing with _$TurfListing {
  const factory TurfListing({
    required String turfId,
    required String turfName,
    required String address,
    required String city,
    required String state,
    required String pincode,
    required SportType sportType,
    required SurfaceType surfaceType,
    required double hourlyRate,
    required bool isActive,
    required double ratingAverage,
    required int totalReviews,
    String? size,
    double? peakHourRate,
    List<String>? peakHours,
    List<String>? amenities,
    String? description,
    double? latitude,
    double? longitude,
    List<String>? imageUrls,
  }) = _TurfListing;
}

@freezed
class AvailabilitySlot with _$AvailabilitySlot {
  const factory AvailabilitySlot({
    required String slotId,
    required String turfId,
    required String date,
    required String startTime,
    required String endTime,
    required String status, // AVAILABLE, BOOKED
  }) = _AvailabilitySlot;

  const AvailabilitySlot._();
  bool get isAvailable => status == 'AVAILABLE';
}

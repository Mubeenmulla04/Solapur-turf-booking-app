import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/turf_listing.dart';

part 'turf_model.freezed.dart';
part 'turf_model.g.dart';

@freezed
class TurfListingModel with _$TurfListingModel {
  const factory TurfListingModel({
    @JsonKey(name: 'turfId') required String turfId,
    @JsonKey(name: 'turfName') required String turfName,
    required String address,
    required String city,
    required String state,
    @JsonKey(name: 'pinCode') required String pincode,
    @JsonKey(name: 'sportType') required String sportType,
    @JsonKey(name: 'surfaceType') required String surfaceType,
    @JsonKey(name: 'hourlyRate') required dynamic hourlyRate,
    @JsonKey(name: 'isActive', defaultValue: true) required bool isActive,
    @JsonKey(name: 'ratingAverage', defaultValue: 0) required dynamic ratingAverage,
    @JsonKey(name: 'reviewCount', defaultValue: 0) required int totalReviews,
    String? size,
    @JsonKey(name: 'peak_hour_rate') dynamic peakHourRate,
    @JsonKey(name: 'peak_hours') List<String>? peakHours,
    List<String>? amenities,
    String? description,
    dynamic latitude,
    dynamic longitude,
    List<TurfImageModel>? images,
  }) = _TurfListingModel;

  factory TurfListingModel.fromJson(Map<String, dynamic> json) =>
      _$TurfListingModelFromJson(json);
}

@freezed
class TurfImageModel with _$TurfImageModel {
  const factory TurfImageModel({
    @JsonKey(name: 'image_url') required String imageUrl,
  }) = _TurfImageModel;

  factory TurfImageModel.fromJson(Map<String, dynamic> json) =>
      _$TurfImageModelFromJson(json);
}

@freezed
class AvailabilitySlotModel with _$AvailabilitySlotModel {
  const factory AvailabilitySlotModel({
    @JsonKey(name: 'id', defaultValue: '') required String slotId,
    @JsonKey(name: 'turfId') required String turfId,
    required String date,
    @JsonKey(name: 'startTime') required String startTime,
    @JsonKey(name: 'endTime') required String endTime,
    @JsonKey(defaultValue: 'AVAILABLE') required String status,
  }) = _AvailabilitySlotModel;

  factory AvailabilitySlotModel.fromJson(Map<String, dynamic> json) =>
      _$AvailabilitySlotModelFromJson(json);
}

// ── Mappers ─────────────────────────────────────────────────────────────────

extension TurfListingModelX on TurfListingModel {
  TurfListing toDomain() => TurfListing(
        turfId: turfId,
        turfName: turfName,
        address: address,
        city: city,
        state: state,
        pincode: pincode,
        sportType: SportTypeX.fromString(sportType),
        surfaceType: _parseSurface(surfaceType),
        hourlyRate: double.tryParse(hourlyRate.toString()) ?? 0,
        isActive: isActive,
        ratingAverage: double.tryParse(ratingAverage.toString()) ?? 0,
        totalReviews: totalReviews,
        size: size,
        peakHourRate: peakHourRate != null
            ? double.tryParse(peakHourRate.toString())
            : null,
        peakHours: peakHours,
        amenities: amenities,
        description: description,
        latitude: latitude != null ? double.tryParse(latitude.toString()) : null,
        longitude:
            longitude != null ? double.tryParse(longitude.toString()) : null,
        imageUrls: images?.map((i) => i.imageUrl).toList(),
      );

  SurfaceType _parseSurface(String s) => switch (s.toUpperCase()) {
        'ARTIFICIAL_GRASS' => SurfaceType.artificialGrass,
        'CONCRETE' => SurfaceType.concrete,
        'WOODEN' => SurfaceType.wooden,
        'CLAY' => SurfaceType.clay,
        _ => SurfaceType.naturalGrass,
      };
}

extension AvailabilitySlotModelX on AvailabilitySlotModel {
  AvailabilitySlot toDomain() => AvailabilitySlot(
        slotId: slotId,
        turfId: turfId,
        date: date,
        startTime: startTime,
        endTime: endTime,
        status: status,
      );
}

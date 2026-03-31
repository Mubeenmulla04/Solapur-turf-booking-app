// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'turf_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TurfListingModelImpl _$$TurfListingModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TurfListingModelImpl(
      turfId: json['turfId'] as String,
      turfName: json['turfName'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      pincode: json['pinCode'] as String,
      sportType: json['sportType'] as String,
      surfaceType: json['surfaceType'] as String,
      hourlyRate: json['hourlyRate'],
      isActive: json['isActive'] as bool? ?? true,
      ratingAverage: json['ratingAverage'] ?? 0,
      totalReviews: (json['reviewCount'] as num?)?.toInt() ?? 0,
      size: json['size'] as String?,
      peakHourRate: json['peak_hour_rate'],
      peakHours: (json['peak_hours'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      amenities: (json['amenities'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      description: json['description'] as String?,
      latitude: json['latitude'],
      longitude: json['longitude'],
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => TurfImageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$TurfListingModelImplToJson(
        _$TurfListingModelImpl instance) =>
    <String, dynamic>{
      'turfId': instance.turfId,
      'turfName': instance.turfName,
      'address': instance.address,
      'city': instance.city,
      'state': instance.state,
      'pinCode': instance.pincode,
      'sportType': instance.sportType,
      'surfaceType': instance.surfaceType,
      'hourlyRate': instance.hourlyRate,
      'isActive': instance.isActive,
      'ratingAverage': instance.ratingAverage,
      'reviewCount': instance.totalReviews,
      'size': instance.size,
      'peak_hour_rate': instance.peakHourRate,
      'peak_hours': instance.peakHours,
      'amenities': instance.amenities,
      'description': instance.description,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'images': instance.images,
    };

_$TurfImageModelImpl _$$TurfImageModelImplFromJson(Map<String, dynamic> json) =>
    _$TurfImageModelImpl(
      imageUrl: json['image_url'] as String,
    );

Map<String, dynamic> _$$TurfImageModelImplToJson(
        _$TurfImageModelImpl instance) =>
    <String, dynamic>{
      'image_url': instance.imageUrl,
    };

_$AvailabilitySlotModelImpl _$$AvailabilitySlotModelImplFromJson(
        Map<String, dynamic> json) =>
    _$AvailabilitySlotModelImpl(
      slotId: json['id'] as String? ?? '',
      turfId: json['turfId'] as String,
      date: json['date'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      status: json['status'] as String? ?? 'AVAILABLE',
    );

Map<String, dynamic> _$$AvailabilitySlotModelImplToJson(
        _$AvailabilitySlotModelImpl instance) =>
    <String, dynamic>{
      'id': instance.slotId,
      'turfId': instance.turfId,
      'date': instance.date,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'status': instance.status,
    };

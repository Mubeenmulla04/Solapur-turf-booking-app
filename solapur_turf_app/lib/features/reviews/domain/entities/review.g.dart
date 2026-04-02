// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReviewImpl _$$ReviewImplFromJson(Map<String, dynamic> json) => _$ReviewImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      turfId: json['turfId'] as String,
      turfName: json['turfName'] as String,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String,
      isVerifiedReview: json['isVerifiedReview'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$ReviewImplToJson(_$ReviewImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'userName': instance.userName,
      'turfId': instance.turfId,
      'turfName': instance.turfName,
      'rating': instance.rating,
      'comment': instance.comment,
      'isVerifiedReview': instance.isVerifiedReview,
      'createdAt': instance.createdAt.toIso8601String(),
    };

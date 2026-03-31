// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'turf_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TurfListingModel _$TurfListingModelFromJson(Map<String, dynamic> json) {
  return _TurfListingModel.fromJson(json);
}

/// @nodoc
mixin _$TurfListingModel {
  @JsonKey(name: 'turfId')
  String get turfId => throw _privateConstructorUsedError;
  @JsonKey(name: 'turfName')
  String get turfName => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String get city => throw _privateConstructorUsedError;
  String get state => throw _privateConstructorUsedError;
  @JsonKey(name: 'pinCode')
  String get pincode => throw _privateConstructorUsedError;
  @JsonKey(name: 'sportType')
  String get sportType => throw _privateConstructorUsedError;
  @JsonKey(name: 'surfaceType')
  String get surfaceType => throw _privateConstructorUsedError;
  @JsonKey(name: 'hourlyRate')
  dynamic get hourlyRate => throw _privateConstructorUsedError;
  @JsonKey(name: 'isActive', defaultValue: true)
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'ratingAverage', defaultValue: 0)
  dynamic get ratingAverage => throw _privateConstructorUsedError;
  @JsonKey(name: 'reviewCount', defaultValue: 0)
  int get totalReviews => throw _privateConstructorUsedError;
  String? get size => throw _privateConstructorUsedError;
  @JsonKey(name: 'peak_hour_rate')
  dynamic get peakHourRate => throw _privateConstructorUsedError;
  @JsonKey(name: 'peak_hours')
  List<String>? get peakHours => throw _privateConstructorUsedError;
  List<String>? get amenities => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  dynamic get latitude => throw _privateConstructorUsedError;
  dynamic get longitude => throw _privateConstructorUsedError;
  List<TurfImageModel>? get images => throw _privateConstructorUsedError;

  /// Serializes this TurfListingModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TurfListingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TurfListingModelCopyWith<TurfListingModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TurfListingModelCopyWith<$Res> {
  factory $TurfListingModelCopyWith(
          TurfListingModel value, $Res Function(TurfListingModel) then) =
      _$TurfListingModelCopyWithImpl<$Res, TurfListingModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'turfId') String turfId,
      @JsonKey(name: 'turfName') String turfName,
      String address,
      String city,
      String state,
      @JsonKey(name: 'pinCode') String pincode,
      @JsonKey(name: 'sportType') String sportType,
      @JsonKey(name: 'surfaceType') String surfaceType,
      @JsonKey(name: 'hourlyRate') dynamic hourlyRate,
      @JsonKey(name: 'isActive', defaultValue: true) bool isActive,
      @JsonKey(name: 'ratingAverage', defaultValue: 0) dynamic ratingAverage,
      @JsonKey(name: 'reviewCount', defaultValue: 0) int totalReviews,
      String? size,
      @JsonKey(name: 'peak_hour_rate') dynamic peakHourRate,
      @JsonKey(name: 'peak_hours') List<String>? peakHours,
      List<String>? amenities,
      String? description,
      dynamic latitude,
      dynamic longitude,
      List<TurfImageModel>? images});
}

/// @nodoc
class _$TurfListingModelCopyWithImpl<$Res, $Val extends TurfListingModel>
    implements $TurfListingModelCopyWith<$Res> {
  _$TurfListingModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TurfListingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? turfId = null,
    Object? turfName = null,
    Object? address = null,
    Object? city = null,
    Object? state = null,
    Object? pincode = null,
    Object? sportType = null,
    Object? surfaceType = null,
    Object? hourlyRate = freezed,
    Object? isActive = null,
    Object? ratingAverage = freezed,
    Object? totalReviews = null,
    Object? size = freezed,
    Object? peakHourRate = freezed,
    Object? peakHours = freezed,
    Object? amenities = freezed,
    Object? description = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? images = freezed,
  }) {
    return _then(_value.copyWith(
      turfId: null == turfId
          ? _value.turfId
          : turfId // ignore: cast_nullable_to_non_nullable
              as String,
      turfName: null == turfName
          ? _value.turfName
          : turfName // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      city: null == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
      pincode: null == pincode
          ? _value.pincode
          : pincode // ignore: cast_nullable_to_non_nullable
              as String,
      sportType: null == sportType
          ? _value.sportType
          : sportType // ignore: cast_nullable_to_non_nullable
              as String,
      surfaceType: null == surfaceType
          ? _value.surfaceType
          : surfaceType // ignore: cast_nullable_to_non_nullable
              as String,
      hourlyRate: freezed == hourlyRate
          ? _value.hourlyRate
          : hourlyRate // ignore: cast_nullable_to_non_nullable
              as dynamic,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      ratingAverage: freezed == ratingAverage
          ? _value.ratingAverage
          : ratingAverage // ignore: cast_nullable_to_non_nullable
              as dynamic,
      totalReviews: null == totalReviews
          ? _value.totalReviews
          : totalReviews // ignore: cast_nullable_to_non_nullable
              as int,
      size: freezed == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as String?,
      peakHourRate: freezed == peakHourRate
          ? _value.peakHourRate
          : peakHourRate // ignore: cast_nullable_to_non_nullable
              as dynamic,
      peakHours: freezed == peakHours
          ? _value.peakHours
          : peakHours // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      amenities: freezed == amenities
          ? _value.amenities
          : amenities // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as dynamic,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as dynamic,
      images: freezed == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<TurfImageModel>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TurfListingModelImplCopyWith<$Res>
    implements $TurfListingModelCopyWith<$Res> {
  factory _$$TurfListingModelImplCopyWith(_$TurfListingModelImpl value,
          $Res Function(_$TurfListingModelImpl) then) =
      __$$TurfListingModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'turfId') String turfId,
      @JsonKey(name: 'turfName') String turfName,
      String address,
      String city,
      String state,
      @JsonKey(name: 'pinCode') String pincode,
      @JsonKey(name: 'sportType') String sportType,
      @JsonKey(name: 'surfaceType') String surfaceType,
      @JsonKey(name: 'hourlyRate') dynamic hourlyRate,
      @JsonKey(name: 'isActive', defaultValue: true) bool isActive,
      @JsonKey(name: 'ratingAverage', defaultValue: 0) dynamic ratingAverage,
      @JsonKey(name: 'reviewCount', defaultValue: 0) int totalReviews,
      String? size,
      @JsonKey(name: 'peak_hour_rate') dynamic peakHourRate,
      @JsonKey(name: 'peak_hours') List<String>? peakHours,
      List<String>? amenities,
      String? description,
      dynamic latitude,
      dynamic longitude,
      List<TurfImageModel>? images});
}

/// @nodoc
class __$$TurfListingModelImplCopyWithImpl<$Res>
    extends _$TurfListingModelCopyWithImpl<$Res, _$TurfListingModelImpl>
    implements _$$TurfListingModelImplCopyWith<$Res> {
  __$$TurfListingModelImplCopyWithImpl(_$TurfListingModelImpl _value,
      $Res Function(_$TurfListingModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TurfListingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? turfId = null,
    Object? turfName = null,
    Object? address = null,
    Object? city = null,
    Object? state = null,
    Object? pincode = null,
    Object? sportType = null,
    Object? surfaceType = null,
    Object? hourlyRate = freezed,
    Object? isActive = null,
    Object? ratingAverage = freezed,
    Object? totalReviews = null,
    Object? size = freezed,
    Object? peakHourRate = freezed,
    Object? peakHours = freezed,
    Object? amenities = freezed,
    Object? description = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? images = freezed,
  }) {
    return _then(_$TurfListingModelImpl(
      turfId: null == turfId
          ? _value.turfId
          : turfId // ignore: cast_nullable_to_non_nullable
              as String,
      turfName: null == turfName
          ? _value.turfName
          : turfName // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      city: null == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
      pincode: null == pincode
          ? _value.pincode
          : pincode // ignore: cast_nullable_to_non_nullable
              as String,
      sportType: null == sportType
          ? _value.sportType
          : sportType // ignore: cast_nullable_to_non_nullable
              as String,
      surfaceType: null == surfaceType
          ? _value.surfaceType
          : surfaceType // ignore: cast_nullable_to_non_nullable
              as String,
      hourlyRate: freezed == hourlyRate
          ? _value.hourlyRate
          : hourlyRate // ignore: cast_nullable_to_non_nullable
              as dynamic,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      ratingAverage: freezed == ratingAverage
          ? _value.ratingAverage
          : ratingAverage // ignore: cast_nullable_to_non_nullable
              as dynamic,
      totalReviews: null == totalReviews
          ? _value.totalReviews
          : totalReviews // ignore: cast_nullable_to_non_nullable
              as int,
      size: freezed == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as String?,
      peakHourRate: freezed == peakHourRate
          ? _value.peakHourRate
          : peakHourRate // ignore: cast_nullable_to_non_nullable
              as dynamic,
      peakHours: freezed == peakHours
          ? _value._peakHours
          : peakHours // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      amenities: freezed == amenities
          ? _value._amenities
          : amenities // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as dynamic,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as dynamic,
      images: freezed == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<TurfImageModel>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TurfListingModelImpl implements _TurfListingModel {
  const _$TurfListingModelImpl(
      {@JsonKey(name: 'turfId') required this.turfId,
      @JsonKey(name: 'turfName') required this.turfName,
      required this.address,
      required this.city,
      required this.state,
      @JsonKey(name: 'pinCode') required this.pincode,
      @JsonKey(name: 'sportType') required this.sportType,
      @JsonKey(name: 'surfaceType') required this.surfaceType,
      @JsonKey(name: 'hourlyRate') required this.hourlyRate,
      @JsonKey(name: 'isActive', defaultValue: true) required this.isActive,
      @JsonKey(name: 'ratingAverage', defaultValue: 0)
      required this.ratingAverage,
      @JsonKey(name: 'reviewCount', defaultValue: 0) required this.totalReviews,
      this.size,
      @JsonKey(name: 'peak_hour_rate') this.peakHourRate,
      @JsonKey(name: 'peak_hours') final List<String>? peakHours,
      final List<String>? amenities,
      this.description,
      this.latitude,
      this.longitude,
      final List<TurfImageModel>? images})
      : _peakHours = peakHours,
        _amenities = amenities,
        _images = images;

  factory _$TurfListingModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TurfListingModelImplFromJson(json);

  @override
  @JsonKey(name: 'turfId')
  final String turfId;
  @override
  @JsonKey(name: 'turfName')
  final String turfName;
  @override
  final String address;
  @override
  final String city;
  @override
  final String state;
  @override
  @JsonKey(name: 'pinCode')
  final String pincode;
  @override
  @JsonKey(name: 'sportType')
  final String sportType;
  @override
  @JsonKey(name: 'surfaceType')
  final String surfaceType;
  @override
  @JsonKey(name: 'hourlyRate')
  final dynamic hourlyRate;
  @override
  @JsonKey(name: 'isActive', defaultValue: true)
  final bool isActive;
  @override
  @JsonKey(name: 'ratingAverage', defaultValue: 0)
  final dynamic ratingAverage;
  @override
  @JsonKey(name: 'reviewCount', defaultValue: 0)
  final int totalReviews;
  @override
  final String? size;
  @override
  @JsonKey(name: 'peak_hour_rate')
  final dynamic peakHourRate;
  final List<String>? _peakHours;
  @override
  @JsonKey(name: 'peak_hours')
  List<String>? get peakHours {
    final value = _peakHours;
    if (value == null) return null;
    if (_peakHours is EqualUnmodifiableListView) return _peakHours;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _amenities;
  @override
  List<String>? get amenities {
    final value = _amenities;
    if (value == null) return null;
    if (_amenities is EqualUnmodifiableListView) return _amenities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? description;
  @override
  final dynamic latitude;
  @override
  final dynamic longitude;
  final List<TurfImageModel>? _images;
  @override
  List<TurfImageModel>? get images {
    final value = _images;
    if (value == null) return null;
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'TurfListingModel(turfId: $turfId, turfName: $turfName, address: $address, city: $city, state: $state, pincode: $pincode, sportType: $sportType, surfaceType: $surfaceType, hourlyRate: $hourlyRate, isActive: $isActive, ratingAverage: $ratingAverage, totalReviews: $totalReviews, size: $size, peakHourRate: $peakHourRate, peakHours: $peakHours, amenities: $amenities, description: $description, latitude: $latitude, longitude: $longitude, images: $images)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TurfListingModelImpl &&
            (identical(other.turfId, turfId) || other.turfId == turfId) &&
            (identical(other.turfName, turfName) ||
                other.turfName == turfName) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.pincode, pincode) || other.pincode == pincode) &&
            (identical(other.sportType, sportType) ||
                other.sportType == sportType) &&
            (identical(other.surfaceType, surfaceType) ||
                other.surfaceType == surfaceType) &&
            const DeepCollectionEquality()
                .equals(other.hourlyRate, hourlyRate) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            const DeepCollectionEquality()
                .equals(other.ratingAverage, ratingAverage) &&
            (identical(other.totalReviews, totalReviews) ||
                other.totalReviews == totalReviews) &&
            (identical(other.size, size) || other.size == size) &&
            const DeepCollectionEquality()
                .equals(other.peakHourRate, peakHourRate) &&
            const DeepCollectionEquality()
                .equals(other._peakHours, _peakHours) &&
            const DeepCollectionEquality()
                .equals(other._amenities, _amenities) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other.latitude, latitude) &&
            const DeepCollectionEquality().equals(other.longitude, longitude) &&
            const DeepCollectionEquality().equals(other._images, _images));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        turfId,
        turfName,
        address,
        city,
        state,
        pincode,
        sportType,
        surfaceType,
        const DeepCollectionEquality().hash(hourlyRate),
        isActive,
        const DeepCollectionEquality().hash(ratingAverage),
        totalReviews,
        size,
        const DeepCollectionEquality().hash(peakHourRate),
        const DeepCollectionEquality().hash(_peakHours),
        const DeepCollectionEquality().hash(_amenities),
        description,
        const DeepCollectionEquality().hash(latitude),
        const DeepCollectionEquality().hash(longitude),
        const DeepCollectionEquality().hash(_images)
      ]);

  /// Create a copy of TurfListingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TurfListingModelImplCopyWith<_$TurfListingModelImpl> get copyWith =>
      __$$TurfListingModelImplCopyWithImpl<_$TurfListingModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TurfListingModelImplToJson(
      this,
    );
  }
}

abstract class _TurfListingModel implements TurfListingModel {
  const factory _TurfListingModel(
      {@JsonKey(name: 'turfId') required final String turfId,
      @JsonKey(name: 'turfName') required final String turfName,
      required final String address,
      required final String city,
      required final String state,
      @JsonKey(name: 'pinCode') required final String pincode,
      @JsonKey(name: 'sportType') required final String sportType,
      @JsonKey(name: 'surfaceType') required final String surfaceType,
      @JsonKey(name: 'hourlyRate') required final dynamic hourlyRate,
      @JsonKey(name: 'isActive', defaultValue: true)
      required final bool isActive,
      @JsonKey(name: 'ratingAverage', defaultValue: 0)
      required final dynamic ratingAverage,
      @JsonKey(name: 'reviewCount', defaultValue: 0)
      required final int totalReviews,
      final String? size,
      @JsonKey(name: 'peak_hour_rate') final dynamic peakHourRate,
      @JsonKey(name: 'peak_hours') final List<String>? peakHours,
      final List<String>? amenities,
      final String? description,
      final dynamic latitude,
      final dynamic longitude,
      final List<TurfImageModel>? images}) = _$TurfListingModelImpl;

  factory _TurfListingModel.fromJson(Map<String, dynamic> json) =
      _$TurfListingModelImpl.fromJson;

  @override
  @JsonKey(name: 'turfId')
  String get turfId;
  @override
  @JsonKey(name: 'turfName')
  String get turfName;
  @override
  String get address;
  @override
  String get city;
  @override
  String get state;
  @override
  @JsonKey(name: 'pinCode')
  String get pincode;
  @override
  @JsonKey(name: 'sportType')
  String get sportType;
  @override
  @JsonKey(name: 'surfaceType')
  String get surfaceType;
  @override
  @JsonKey(name: 'hourlyRate')
  dynamic get hourlyRate;
  @override
  @JsonKey(name: 'isActive', defaultValue: true)
  bool get isActive;
  @override
  @JsonKey(name: 'ratingAverage', defaultValue: 0)
  dynamic get ratingAverage;
  @override
  @JsonKey(name: 'reviewCount', defaultValue: 0)
  int get totalReviews;
  @override
  String? get size;
  @override
  @JsonKey(name: 'peak_hour_rate')
  dynamic get peakHourRate;
  @override
  @JsonKey(name: 'peak_hours')
  List<String>? get peakHours;
  @override
  List<String>? get amenities;
  @override
  String? get description;
  @override
  dynamic get latitude;
  @override
  dynamic get longitude;
  @override
  List<TurfImageModel>? get images;

  /// Create a copy of TurfListingModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TurfListingModelImplCopyWith<_$TurfListingModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TurfImageModel _$TurfImageModelFromJson(Map<String, dynamic> json) {
  return _TurfImageModel.fromJson(json);
}

/// @nodoc
mixin _$TurfImageModel {
  @JsonKey(name: 'image_url')
  String get imageUrl => throw _privateConstructorUsedError;

  /// Serializes this TurfImageModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TurfImageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TurfImageModelCopyWith<TurfImageModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TurfImageModelCopyWith<$Res> {
  factory $TurfImageModelCopyWith(
          TurfImageModel value, $Res Function(TurfImageModel) then) =
      _$TurfImageModelCopyWithImpl<$Res, TurfImageModel>;
  @useResult
  $Res call({@JsonKey(name: 'image_url') String imageUrl});
}

/// @nodoc
class _$TurfImageModelCopyWithImpl<$Res, $Val extends TurfImageModel>
    implements $TurfImageModelCopyWith<$Res> {
  _$TurfImageModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TurfImageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? imageUrl = null,
  }) {
    return _then(_value.copyWith(
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TurfImageModelImplCopyWith<$Res>
    implements $TurfImageModelCopyWith<$Res> {
  factory _$$TurfImageModelImplCopyWith(_$TurfImageModelImpl value,
          $Res Function(_$TurfImageModelImpl) then) =
      __$$TurfImageModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@JsonKey(name: 'image_url') String imageUrl});
}

/// @nodoc
class __$$TurfImageModelImplCopyWithImpl<$Res>
    extends _$TurfImageModelCopyWithImpl<$Res, _$TurfImageModelImpl>
    implements _$$TurfImageModelImplCopyWith<$Res> {
  __$$TurfImageModelImplCopyWithImpl(
      _$TurfImageModelImpl _value, $Res Function(_$TurfImageModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TurfImageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? imageUrl = null,
  }) {
    return _then(_$TurfImageModelImpl(
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TurfImageModelImpl implements _TurfImageModel {
  const _$TurfImageModelImpl(
      {@JsonKey(name: 'image_url') required this.imageUrl});

  factory _$TurfImageModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TurfImageModelImplFromJson(json);

  @override
  @JsonKey(name: 'image_url')
  final String imageUrl;

  @override
  String toString() {
    return 'TurfImageModel(imageUrl: $imageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TurfImageModelImpl &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, imageUrl);

  /// Create a copy of TurfImageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TurfImageModelImplCopyWith<_$TurfImageModelImpl> get copyWith =>
      __$$TurfImageModelImplCopyWithImpl<_$TurfImageModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TurfImageModelImplToJson(
      this,
    );
  }
}

abstract class _TurfImageModel implements TurfImageModel {
  const factory _TurfImageModel(
          {@JsonKey(name: 'image_url') required final String imageUrl}) =
      _$TurfImageModelImpl;

  factory _TurfImageModel.fromJson(Map<String, dynamic> json) =
      _$TurfImageModelImpl.fromJson;

  @override
  @JsonKey(name: 'image_url')
  String get imageUrl;

  /// Create a copy of TurfImageModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TurfImageModelImplCopyWith<_$TurfImageModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AvailabilitySlotModel _$AvailabilitySlotModelFromJson(
    Map<String, dynamic> json) {
  return _AvailabilitySlotModel.fromJson(json);
}

/// @nodoc
mixin _$AvailabilitySlotModel {
  @JsonKey(name: 'id', defaultValue: '')
  String get slotId => throw _privateConstructorUsedError;
  @JsonKey(name: 'turfId')
  String get turfId => throw _privateConstructorUsedError;
  String get date => throw _privateConstructorUsedError;
  @JsonKey(name: 'startTime')
  String get startTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'endTime')
  String get endTime => throw _privateConstructorUsedError;
  @JsonKey(defaultValue: 'AVAILABLE')
  String get status => throw _privateConstructorUsedError;

  /// Serializes this AvailabilitySlotModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AvailabilitySlotModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AvailabilitySlotModelCopyWith<AvailabilitySlotModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AvailabilitySlotModelCopyWith<$Res> {
  factory $AvailabilitySlotModelCopyWith(AvailabilitySlotModel value,
          $Res Function(AvailabilitySlotModel) then) =
      _$AvailabilitySlotModelCopyWithImpl<$Res, AvailabilitySlotModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'id', defaultValue: '') String slotId,
      @JsonKey(name: 'turfId') String turfId,
      String date,
      @JsonKey(name: 'startTime') String startTime,
      @JsonKey(name: 'endTime') String endTime,
      @JsonKey(defaultValue: 'AVAILABLE') String status});
}

/// @nodoc
class _$AvailabilitySlotModelCopyWithImpl<$Res,
        $Val extends AvailabilitySlotModel>
    implements $AvailabilitySlotModelCopyWith<$Res> {
  _$AvailabilitySlotModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AvailabilitySlotModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? slotId = null,
    Object? turfId = null,
    Object? date = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? status = null,
  }) {
    return _then(_value.copyWith(
      slotId: null == slotId
          ? _value.slotId
          : slotId // ignore: cast_nullable_to_non_nullable
              as String,
      turfId: null == turfId
          ? _value.turfId
          : turfId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AvailabilitySlotModelImplCopyWith<$Res>
    implements $AvailabilitySlotModelCopyWith<$Res> {
  factory _$$AvailabilitySlotModelImplCopyWith(
          _$AvailabilitySlotModelImpl value,
          $Res Function(_$AvailabilitySlotModelImpl) then) =
      __$$AvailabilitySlotModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'id', defaultValue: '') String slotId,
      @JsonKey(name: 'turfId') String turfId,
      String date,
      @JsonKey(name: 'startTime') String startTime,
      @JsonKey(name: 'endTime') String endTime,
      @JsonKey(defaultValue: 'AVAILABLE') String status});
}

/// @nodoc
class __$$AvailabilitySlotModelImplCopyWithImpl<$Res>
    extends _$AvailabilitySlotModelCopyWithImpl<$Res,
        _$AvailabilitySlotModelImpl>
    implements _$$AvailabilitySlotModelImplCopyWith<$Res> {
  __$$AvailabilitySlotModelImplCopyWithImpl(_$AvailabilitySlotModelImpl _value,
      $Res Function(_$AvailabilitySlotModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of AvailabilitySlotModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? slotId = null,
    Object? turfId = null,
    Object? date = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? status = null,
  }) {
    return _then(_$AvailabilitySlotModelImpl(
      slotId: null == slotId
          ? _value.slotId
          : slotId // ignore: cast_nullable_to_non_nullable
              as String,
      turfId: null == turfId
          ? _value.turfId
          : turfId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AvailabilitySlotModelImpl implements _AvailabilitySlotModel {
  const _$AvailabilitySlotModelImpl(
      {@JsonKey(name: 'id', defaultValue: '') required this.slotId,
      @JsonKey(name: 'turfId') required this.turfId,
      required this.date,
      @JsonKey(name: 'startTime') required this.startTime,
      @JsonKey(name: 'endTime') required this.endTime,
      @JsonKey(defaultValue: 'AVAILABLE') required this.status});

  factory _$AvailabilitySlotModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AvailabilitySlotModelImplFromJson(json);

  @override
  @JsonKey(name: 'id', defaultValue: '')
  final String slotId;
  @override
  @JsonKey(name: 'turfId')
  final String turfId;
  @override
  final String date;
  @override
  @JsonKey(name: 'startTime')
  final String startTime;
  @override
  @JsonKey(name: 'endTime')
  final String endTime;
  @override
  @JsonKey(defaultValue: 'AVAILABLE')
  final String status;

  @override
  String toString() {
    return 'AvailabilitySlotModel(slotId: $slotId, turfId: $turfId, date: $date, startTime: $startTime, endTime: $endTime, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AvailabilitySlotModelImpl &&
            (identical(other.slotId, slotId) || other.slotId == slotId) &&
            (identical(other.turfId, turfId) || other.turfId == turfId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, slotId, turfId, date, startTime, endTime, status);

  /// Create a copy of AvailabilitySlotModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AvailabilitySlotModelImplCopyWith<_$AvailabilitySlotModelImpl>
      get copyWith => __$$AvailabilitySlotModelImplCopyWithImpl<
          _$AvailabilitySlotModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AvailabilitySlotModelImplToJson(
      this,
    );
  }
}

abstract class _AvailabilitySlotModel implements AvailabilitySlotModel {
  const factory _AvailabilitySlotModel(
          {@JsonKey(name: 'id', defaultValue: '') required final String slotId,
          @JsonKey(name: 'turfId') required final String turfId,
          required final String date,
          @JsonKey(name: 'startTime') required final String startTime,
          @JsonKey(name: 'endTime') required final String endTime,
          @JsonKey(defaultValue: 'AVAILABLE') required final String status}) =
      _$AvailabilitySlotModelImpl;

  factory _AvailabilitySlotModel.fromJson(Map<String, dynamic> json) =
      _$AvailabilitySlotModelImpl.fromJson;

  @override
  @JsonKey(name: 'id', defaultValue: '')
  String get slotId;
  @override
  @JsonKey(name: 'turfId')
  String get turfId;
  @override
  String get date;
  @override
  @JsonKey(name: 'startTime')
  String get startTime;
  @override
  @JsonKey(name: 'endTime')
  String get endTime;
  @override
  @JsonKey(defaultValue: 'AVAILABLE')
  String get status;

  /// Create a copy of AvailabilitySlotModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AvailabilitySlotModelImplCopyWith<_$AvailabilitySlotModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

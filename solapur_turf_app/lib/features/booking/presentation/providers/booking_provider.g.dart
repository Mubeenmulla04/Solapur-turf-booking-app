// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bookingRepositoryHash() => r'2f27728203b04c9cec8d717f3895cb2c4a88ae44';

/// See also [bookingRepository].
@ProviderFor(bookingRepository)
final bookingRepositoryProvider =
    AutoDisposeProvider<BookingRepository>.internal(
  bookingRepository,
  name: r'bookingRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bookingRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BookingRepositoryRef = AutoDisposeProviderRef<BookingRepository>;
String _$myBookingsHash() => r'709c006b281a99345d328a201dd0acf6ead58f94';

/// See also [myBookings].
@ProviderFor(myBookings)
final myBookingsProvider = AutoDisposeFutureProvider<List<Booking>>.internal(
  myBookings,
  name: r'myBookingsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$myBookingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MyBookingsRef = AutoDisposeFutureProviderRef<List<Booking>>;
String _$bookingNotifierHash() => r'4d70ce07cf4955b45d80fb0a9f01fcc01a05388c';

/// See also [BookingNotifier].
@ProviderFor(BookingNotifier)
final bookingNotifierProvider =
    AutoDisposeNotifierProvider<BookingNotifier, BookingFlowState>.internal(
  BookingNotifier.new,
  name: r'bookingNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bookingNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BookingNotifier = AutoDisposeNotifier<BookingFlowState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

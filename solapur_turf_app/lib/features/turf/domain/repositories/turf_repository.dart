import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/turf_listing.dart';

abstract class TurfRepository {
  Future<Either<Failure, List<TurfListing>>> getTurfs({
    String? city,
    String? sportType,
    String? search,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    int page,
    int limit,
  });

  Future<Either<Failure, TurfListing>> getTurfById(String turfId);

  Future<Either<Failure, List<AvailabilitySlot>>> getAvailableSlots({
    required String turfId,
    required String date,
  });
}

import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/turf_listing.dart';
import '../../domain/repositories/turf_repository.dart';
import '../datasources/turf_remote_datasource.dart';
import '../models/turf_model.dart';

class TurfRepositoryImpl implements TurfRepository {
  final TurfRemoteDataSource _remote;

  TurfRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<TurfListing>>> getTurfs({
    String? city,
    String? sportType,
    String? search,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final models = await _remote.getTurfs(
        city: city,
        sportType: sportType,
        search: search,
        minPrice: minPrice,
        maxPrice: maxPrice,
        sortBy: sortBy,
        page: page,
        limit: limit,
      );
      return Right(models.map((m) => m.toDomain()).toList());
    } on AppException catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, TurfListing>> getTurfById(String turfId) async {
    try {
      final model = await _remote.getTurfById(turfId);
      return Right(model.toDomain());
    } on AppException catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, List<AvailabilitySlot>>> getAvailableSlots({
    required String turfId,
    required String date,
  }) async {
    try {
      final models =
          await _remote.getAvailableSlots(turfId: turfId, date: date);
      return Right(models.map((m) => m.toDomain()).toList());
    } on AppException catch (e) {
      return Left(_map(e));
    }
  }

  Failure _map(AppException e) {
    if (e.statusCode == 404) return Failure.notFound(message: e.message);
    if (e.statusCode == null) return Failure.network(message: e.message);
    return Failure.server(statusCode: e.statusCode!, message: e.message);
  }
}

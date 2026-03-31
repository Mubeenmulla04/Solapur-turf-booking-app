import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

/// Base class for all use cases with parameters.
abstract class UseCase<Output, Params> {
  Future<Either<Failure, Output>> call(Params params);
}

/// Base class for use cases with no parameters.
abstract class NoParamsUseCase<Output> {
  Future<Either<Failure, Output>> call();
}

/// Sentinel class for use cases that need no params.
class NoParams {
  const NoParams();
}

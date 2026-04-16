/// Simple callable use case contract for async operations.
abstract class UseCase<Result, Params> {
  Future<Result> call(Params params);
}

/// Use when no parameters are needed.
class NoParams {
  const NoParams();
}

abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class ParsingFailure extends Failure {
  const ParsingFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

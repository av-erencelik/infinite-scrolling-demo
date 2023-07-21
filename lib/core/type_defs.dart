import 'package:fpdart/fpdart.dart';
import 'package:infinite/core/failure.dart';

typedef FutureEither<T> = Future<Either<Failure, T>>;
typedef FutureVoid = FutureEither<void>;

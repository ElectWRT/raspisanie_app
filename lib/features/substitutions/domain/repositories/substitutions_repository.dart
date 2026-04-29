import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/substitution.dart';

abstract class SubstitutionsRepository {
  Future<Either<Failure, Unit>> refreshSubstitutions({String? date});
  Future<Either<Failure, List<SubstitutionEntity>>> getLocalSubstitutions();
  Stream<List<SubstitutionEntity>> watchSubstitutions();
}

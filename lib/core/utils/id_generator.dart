import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class IdGenerator {
  const IdGenerator();

  String generate() => const Uuid().v4();
}

final idGeneratorProvider = Provider<IdGenerator>((ref) => const IdGenerator());

import 'dart:io';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'customer_model.dart';
import 'loan_model.dart';
import 'payment_model.dart';

class LocalDb {
  LocalDb(this.isar);

  final Isar isar;

  static Future<LocalDb> open() async {
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [
        CustomerModelSchema,
        LoanModelSchema,
        PaymentModelSchema,
      ],
      directory: dir.path,
      name: 'bookinman',
    );
    return LocalDb(isar);
  }

  Future<void> close() => isar.close();
}

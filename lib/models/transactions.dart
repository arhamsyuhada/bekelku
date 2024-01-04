import 'package:drift/drift.dart';

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(max: 128)();
  IntColumn get categoryId => integer()();
  DateTimeColumn get transactionDate => dateTime()();
  IntColumn get amount => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

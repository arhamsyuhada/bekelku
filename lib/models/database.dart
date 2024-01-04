import 'dart:io';

import 'package:bekelku/models/category.dart';
import 'package:bekelku/models/transaction_category.dart';
import 'package:bekelku/models/transactions.dart';
import 'package:drift/drift.dart';
// These imports are used to open the database
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

@DriftDatabase(
    // relative import for the drift file. Drift also supports `package:`
    // imports
    tables: [Categories, Transactions])
class AppDb extends _$AppDb {
  AppDb() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // CRUD Category

  Future<List<Category>> getAllCategoryRepo(int type) async {
    return await (select(categories)..where((tbl) => tbl.type.equals(type)))
        .get();
  }

  Future updateCategoryRepo(int id, String name) async {
    return (update(categories)..where((tbl) => tbl.id.equals(id)))
        .write(CategoriesCompanion(name: Value(name)));
  }

  Future deleteCategoryRepo(int id) async {
    return (delete(categories)..where((tbl) => tbl.id.equals(id))).go();
  }

  //Transaction
  Stream<List<TransactionWithCategory>> getTransactionByDateRepo(
      DateTime date) {
    final query = (select(transactions).join([
      innerJoin(categories, categories.id.equalsExp(transactions.categoryId))
    ])
      ..where(transactions.transactionDate.equals(date)));

    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithCategory(
            row.readTable(transactions), row.readTable(categories));
      }).toList();
    });
  }

  Future updateTransactionRepo(int id, int amount, int categoryId,
      DateTime transactionDate, String detail) async {
    return (update(transactions)..where((tbl) => tbl.id.equals(id))).write(
        TransactionsCompanion(
            name: Value(detail),
            amount: Value(amount),
            categoryId: Value(categoryId),
            transactionDate: Value(transactionDate)));
  }

  Future deleteTransactionRepo(int id) async {
    return (delete(transactions)..where((tbl) => tbl.id.equals(id))).go();
  }

  //Select SUM All Transaction in month
  Future<List<Transaction>> getAllTransactionsRepo({int? amount}) async {
    final query = select(transactions);

    if (amount != null) {
      query.where((tbl) => tbl.amount.equals(amount));
    }

    return await query.get();
  }

  Future<void> deleteAllTransactionsRepo() async {
    await delete(transactions).go();
  }
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));

    return NativeDatabase.createInBackground(file);
  });
}

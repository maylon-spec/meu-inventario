import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../models/inventory_item.dart';

class InventoryDatabase {
  InventoryDatabase._();
  static final instance = InventoryDatabase._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final dbPath = await getDatabasesPath();
    _database = await openDatabase(
      p.join(dbPath, 'meu_inventario.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE items (
            id TEXT PRIMARY KEY, name TEXT NOT NULL, category TEXT NOT NULL,
            room TEXT NOT NULL, barcode TEXT, quantity INTEGER NOT NULL,
            unitValue REAL NOT NULL, notes TEXT, updatedAt TEXT NOT NULL,
            synced INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('CREATE INDEX idx_items_barcode ON items(barcode)');
      },
    );
    return _database!;
  }

  Future<void> save(InventoryItem item) async {
    final db = await database;
    await db.insert('items', item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<InventoryItem>> all() async {
    final db = await database;
    final rows = await db.query('items', orderBy: 'name COLLATE NOCASE');
    return rows.map(InventoryItem.fromMap).toList();
  }

  Future<InventoryItem?> byBarcode(String barcode) async {
    final db = await database;
    final rows = await db.query('items',
        where: 'barcode = ?', whereArgs: [barcode], limit: 1);
    return rows.isEmpty ? null : InventoryItem.fromMap(rows.first);
  }

  Future<void> delete(String id) async {
    final db = await database;
    await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> totalValue() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(quantity * unitValue) AS total FROM items');
    return (result.first['total'] as num? ?? 0).toDouble();
  }

  Future<int> pendingCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM items WHERE synced = 0');
    return (result.first['count'] as int?) ?? 0;
  }
}

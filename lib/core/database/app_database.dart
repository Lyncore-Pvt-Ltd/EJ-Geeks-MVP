import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  static const _dbName = 'ej_geek.db';
  static const _dbVersion = 1;

  Database? _database;

  Future<Database> get database async {
    return _database ??= await _open();
  }

  Future<Database> _open() async {
    final dbPath = p.join(await getDatabasesPath(), _dbName);
    return openDatabase(dbPath, version: _dbVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE inspections (
        id TEXT PRIMARY KEY,
        invoice_id TEXT NOT NULL,
        make TEXT,
        model TEXT,
        rego TEXT,
        year TEXT,
        odometer TEXT,
        vin TEXT,
        engine_no TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE inspection_items (
        id TEXT PRIMARY KEY,
        inspection_id TEXT NOT NULL,
        section TEXT NOT NULL,
        item_label TEXT NOT NULL,
        rating TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE inspection_section_comments (
        id TEXT PRIMARY KEY,
        inspection_id TEXT NOT NULL,
        section TEXT NOT NULL,
        comment TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE inspection_images (
        id TEXT PRIMARY KEY,
        inspection_id TEXT NOT NULL,
        file_path TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }
}

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/kundali_model.dart';

/// Local Database Helper for storing Kundali data
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('dishaajyoti.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
      CREATE TABLE kundalis (
        id $idType,
        userId $textType,
        name $textType,
        dateOfBirth $textType,
        timeOfBirth $textType,
        placeOfBirth $textType,
        pdfPath TEXT,
        dataJson TEXT,
        createdAt $textType
      )
    ''');
  }

  /// Insert a Kundali
  Future<void> insertKundali(Kundali kundali) async {
    final db = await database;
    await db.insert(
      'kundalis',
      kundali.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all Kundalis for a user
  Future<List<Kundali>> getKundalis(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'kundalis',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return Kundali.fromMap(maps[i]);
    });
  }

  /// Get a specific Kundali by ID
  Future<Kundali?> getKundali(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'kundalis',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Kundali.fromMap(maps.first);
  }

  /// Update a Kundali
  Future<void> updateKundali(Kundali kundali) async {
    final db = await database;
    await db.update(
      'kundalis',
      kundali.toMap(),
      where: 'id = ?',
      whereArgs: [kundali.id],
    );
  }

  /// Delete a Kundali
  Future<void> deleteKundali(String id) async {
    final db = await database;
    await db.delete(
      'kundalis',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Close the database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

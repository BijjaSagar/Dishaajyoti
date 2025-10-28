import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/kundali_model.dart';
import '../models/kundali_with_chart_model.dart';

/// Local Database Helper for storing Kundali data
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static const int _currentVersion = 2; // Updated version for schema changes

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
      version: _currentVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
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
        chartDataJson TEXT,
        chartStyle TEXT DEFAULT 'northIndian',
        chartImagePath TEXT,
        syncStatus TEXT DEFAULT 'pending',
        serverId TEXT,
        createdAt $textType
      )
    ''');
  }

  /// Upgrade database schema
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns for chart data
      await db.execute('ALTER TABLE kundalis ADD COLUMN chartDataJson TEXT');
      await db.execute(
          'ALTER TABLE kundalis ADD COLUMN chartStyle TEXT DEFAULT "northIndian"');
      await db.execute('ALTER TABLE kundalis ADD COLUMN chartImagePath TEXT');
      await db.execute(
          'ALTER TABLE kundalis ADD COLUMN syncStatus TEXT DEFAULT "pending"');
      await db.execute('ALTER TABLE kundalis ADD COLUMN serverId TEXT');
    }
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

  /// Insert a KundaliWithChart
  Future<void> insertKundaliWithChart(KundaliWithChart kundali) async {
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

  /// Get all KundaliWithChart for a user
  Future<List<KundaliWithChart>> getKundalisWithChart(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'kundalis',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return KundaliWithChart.fromMap(maps[i]);
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

  /// Get a specific KundaliWithChart by ID
  Future<KundaliWithChart?> getKundaliWithChart(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'kundalis',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return KundaliWithChart.fromMap(maps.first);
  }

  /// Get pending sync Kundalis
  Future<List<KundaliWithChart>> getPendingSyncKundalis() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'kundalis',
      where: 'syncStatus = ?',
      whereArgs: ['pending'],
      orderBy: 'createdAt ASC',
    );

    return List.generate(maps.length, (i) {
      return KundaliWithChart.fromMap(maps[i]);
    });
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

  /// Update a KundaliWithChart
  Future<void> updateKundaliWithChart(KundaliWithChart kundali) async {
    final db = await database;
    await db.update(
      'kundalis',
      kundali.toMap(),
      where: 'id = ?',
      whereArgs: [kundali.id],
    );
  }

  /// Update sync status
  Future<void> updateSyncStatus(
    String id,
    String status, {
    String? serverId,
  }) async {
    final db = await database;
    final Map<String, dynamic> values = {'syncStatus': status};
    if (serverId != null) {
      values['serverId'] = serverId;
    }
    await db.update(
      'kundalis',
      values,
      where: 'id = ?',
      whereArgs: [id],
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

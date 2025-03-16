import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('unieats.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // Increment version when modifying schema
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT UNIQUE,
        password TEXT,
        role TEXT
      )
    ''');
    await db.execute('''
  CREATE TABLE orders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    userId INTEGER,
    foodItemId INTEGER,
    foodName TEXT,   -- ✅ Add this line
    quantity INTEGER,
    totalPrice REAL,
    address TEXT,
    status TEXT,
    paymentMethod TEXT
  )
''');

    Future<void> createTables(Database db) async {
      await db.execute('''
    CREATE TABLE IF NOT EXISTS orders (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId INTEGER,
      foodItemId INTEGER,
      foodName TEXT,  -- Add foodName column
      quantity INTEGER,
      totalPrice REAL,
      address TEXT,
      status TEXT,
      paymentMethod TEXT
    )
  ''');
    }

    await db.execute('''
      CREATE TABLE food_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        price REAL,
        image TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        foodItemId INTEGER,
        quantity INTEGER,
        totalPrice REAL, 
        address TEXT, 
        status TEXT DEFAULT 'Pending',
        orderDate TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (userId) REFERENCES users(id),
        FOREIGN KEY (foodItemId) REFERENCES food_items(id)
      )
    ''');
    await db.execute('''
          CREATE TABLE favorites (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            food_id INTEGER
          )
        ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE orders ADD COLUMN foodName TEXT');
    }

  }


  Future<void> placeOrder(int userId, int foodItemId, int quantity, double price, String address, String paymentMethod, String foodName) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'orders',
      {
        'userId': userId,
        'foodItemId': foodItemId,
        'foodName': foodName,  // ✅ Now this will be stored
        'quantity': quantity,
        'totalPrice': price,
        'address': address,
        'status': 'Processing',
        'paymentMethod': paymentMethod,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }





  Future<List<Map<String, dynamic>>> getUserOrders(int userId) async {
    final db = await database;
    return await db.query(
      'orders',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  Future<List<Map<String, dynamic>>> getOrders() async {
    final db = await database;
    return await db.query('orders');
  }






  Future<int> updateOrderStatus(int orderId, String newStatus) async {
    final db = await instance.database;
    return await db.update(
      'orders',
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }
  Future<void> addToFavorites(int userId, int foodId) async {
    final db = await database;
    await db.insert(
      'favorites',
      {'user_id': userId, 'food_id': foodId},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> removeFromFavorites(int userId, int foodId) async {
    final db = await database;
    await db.delete(
      'favorites',
      where: 'user_id = ? AND food_id = ?',
      whereArgs: [userId, foodId],
    );
  }

  Future<List<Map<String, dynamic>>> getFavoriteItems(int userId) async {
    final db = await database;
    return await db.rawQuery('''
    SELECT f.* FROM food_items f 
    INNER JOIN favorites fav ON f.id = fav.food_id 
    WHERE fav.user_id = ?
  ''', [userId]);
  }

  Future<int> createUser(String name, String email, String password, String role) async {
    final db = await instance.database;
    return await db.insert('users', {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    });
  }

  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    return result.isNotEmpty ? result.first : null;
  }

  Future<int> resetPassword(String email, String newPassword) async {
    final db = await instance.database;
    return await db.update(
      'users',
      {'password': newPassword},
      where: 'email = ?',
      whereArgs: [email],
    );
  }


  Future<int> addFoodItem(String name, double price, String image) async {
    final db = await instance.database;
    return await db.insert('food_items', {'name': name, 'price': price, 'image': image});
  }

  Future<List<Map<String, dynamic>>> getFoodItems() async {
    final db = await instance.database;
    return await db.query('food_items');
  }

  Future<int> deleteFoodItem(int id) async {
    final db = await instance.database;
    return await db.delete('food_items', where: 'id = ?', whereArgs: [id]);
  }
}

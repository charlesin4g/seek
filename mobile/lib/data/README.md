### 1. 什么是 Floor？

Floor 是一个在 Flutter 和 Dart 上构建的**轻量级、响应式且类型安全的 SQLite ORM（对象关系映射）库**。它的设计灵感来源于 Android 的 Room 持久化库。

简单来说，Floor 的核心目标是让你能够使用面向对象的方式来操作数据库，而无需编写大量的原始 SQL 语句和手动处理数据映射。它充当了你的 Dart 对象和 SQLite 数据库之间的桥梁。

**核心特点：**

*   **类型安全：** 通过代码生成，在编译时就能发现很多错误，而不是在运行时。
*   **响应式：** 与 `Stream` 深度集成，可以轻松监听数据库的变化并自动更新 UI。
*   **轻量级：** 专注于提供核心的 ORM 功能，没有过多复杂的抽象。
*   **简单易用：** API 设计简洁明了，学习曲线平缓。

---

### 2. 核心概念与组件

Floor 的工作流程主要围绕以下几个部分：

#### a. Entity（实体）
代表数据库中的一张表。使用 `@Entity` 注解标记一个类。
*   每个实体必须有一个主键（使用 `@PrimaryKey`）。
*   类的字段会映射到表的列。

```dart
// entity/person.dart
import 'package:floor/floor.dart';

@entity
class Person {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String name;
  final int age;

  Person(this.id, this.name, this.age);
}
```

#### b. DAO（Data Access Object，数据访问对象）
一个接口，用于定义访问数据库的方法。使用 `@dao` 注解标记。
*   方法上使用 `@Query` 来执行自定义的 SELECT 语句。
*   使用 `@insert`, `@update`, `@delete` 注解来执行相应的操作。

```dart
// dao/person_dao.dart
import 'package:floor/floor.dart';

@dao
abstract class PersonDao {
  @Query('SELECT * FROM Person')
  Future<List<Person>> findAllPersons(); // 查找所有

  @Query('SELECT * FROM Person WHERE id = :id')
  Stream<Person?> findPersonById(int id); // 通过ID查找，返回Stream以监听变化

  @insert
  Future<void> insertPerson(Person person); // 插入

  @update
  Future<int> updatePerson(Person person); // 更新，返回更新的行数

  @delete
  Future<void> deletePerson(Person person); // 删除
}
```

#### c. Database（数据库）
数据库的抽象基类，使用 `@Database` 注解标记。
*   需要指定包含的实体（`entities`）和版本号（`version`）。
*   必须实现一个获取 DAO 的抽象方法。

```dart
// database/database.dart
import 'package:floor/floor.dart';
import 'dao/person_dao.dart';
import 'entity/person.dart';

part 'database.g.dart'; // 重要：生成的文件

@Database(version: 1, entities: [Person])
abstract class AppDatabase extends FloorDatabase {
  PersonDao get personDao;
}
```
注意 `part 'database.g.dart';` 这一行。Floor 通过 **build_runner** 来生成实现代码，这个文件就是生成的。

---

### 3. 安装与配置

1.  **添加依赖**
    在 `pubspec.yaml` 中添加：

    ```yaml
    dependencies:
      flutter:
        sdk: flutter
      floor: ^1.4.0 # 请检查最新版本
      sqflite: ^2.3.0 # floor 依赖于 sqflite 和 path_provider
      path_provider: ^2.1.1

    dev_dependencies:
      flutter_test:
        sdk: flutter
      floor_generator: ^1.4.0 # 代码生成器
      build_runner: ^2.4.7 # 运行代码生成的工具
    ```

2.  **创建如上所述的 Entity、DAO、Database 类文件。**

3.  **生成代码**
    在终端运行以下命令。它会读取你的注解，并在 `database.g.dart` 中生成 `AppDatabase` 的具体实现。

    ```bash
    flutter packages pub run build_runner build
    ```
    如果想在文件变化时自动生成，可以使用：
    ```bash
    flutter packages pub run build_runner watch
    ```

---

### 4. 使用流程

生成代码后，你就可以在应用中使用数据库了。

```dart
import 'package:flutter/material.dart';
import 'database/database.dart'; // 导入你的数据库抽象类
import 'entity/person.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 确保插件初始化

  // 获取数据库实例
  final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  final personDao = database.personDao;

  // 示例：插入一条数据
  final person = Person(null, 'John Doe', 30);
  await personDao.insertPerson(person);

  // 示例：查询所有数据并监听变化
  personDao.findAllPersons().then((allPersons) {
    print('All persons: $allPersons');
  });

  // 监听单个实体的变化
  personDao.findPersonById(1).listen((person) {
    print('Person with ID 1 updated: $person');
  });

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Floor Example')),
        body: Center(child: Text('Check the console for output')),
      ),
    );
  }
}
```

---

### 5. 高级特性

*   **复杂查询：** 可以在 DAO 的 `@Query` 注解中使用任何有效的 SQL 语句，包括 `JOIN`, `WHERE`, `ORDER BY` 等。
    ```dart
    @Query('SELECT * FROM Person WHERE age > :age ORDER BY name DESC')
    Future<List<Person>> findPersonsOlderThan(int age);
    ```

*   **事务：** 使用 `transaction` 方法来执行原子操作。
    ```dart
    await database.transaction((txn) async {
      await txn.persons.insert(Person(null, 'Alice', 25));
      await txn.persons.delete(Person(1, '...', ...));
    });
    ```

*   **类型转换器：** 可以将不支持的 Dart 类型（如 `DateTime`, `Enum`）转换为 SQLite 支持的 `INTEGER` 或 `TEXT`。
    ```dart
    // 定义转换器
    class DateTimeConverter extends TypeConverter<DateTime, int> {
      @override
      DateTime decode(int databaseValue) {
        return DateTime.fromMillisecondsSinceEpoch(databaseValue);
      }

      @override
      int encode(DateTime value) {
        return value.millisecondsSinceEpoch;
      }
    }

    // 在实体中使用
    @entity
    class Event {
      @PrimaryKey()
      final int id;
      @TypeConverters([DateTimeConverter]) // 应用转换器
      final DateTime createdAt;
    }
    ```

*   **数据库迁移：** 当数据库结构发生变化（如增加表、修改字段）时，需要使用 Migration 来平滑升级。
    ```dart
    final migration1to2 = Migration(1, 2, (database) async {
      await database.execute('ALTER TABLE Person ADD COLUMN email TEXT');
    });

    final database = await $FloorAppDatabase
        .databaseBuilder('app_database.db')
        .addMigrations([migration1to2])
        .build();
    ```

---

### 6. 总结

**优点：**
*   **开发效率高：** 极大减少了模板代码，让开发者更专注于业务逻辑。
*   **代码健壮：** 编译时类型检查避免了潜在的运行时错误。
*   **响应式编程友好：** 与 Stream 的无缝结合使得构建动态 UI 变得非常简单。
*   **社区成熟：** 作为主流的 Flutter ORM 之一，文档和社区支持良好。

**缺点/注意事项：**
*   **需要代码生成步骤：** 增加了构建过程的复杂性，对于不熟悉该模式的开发者可能有点困惑。
*   **灵活性略逊于 Drift：** 对于极其复杂的 SQL 查询或需要数据库特定高级功能的场景，Drift 可能是更好的选择。
*   **对空安全的支持：** 需要确保你的实体类和生成代码都正确处理了可空性。

总而言之，**Floor 是 Flutter 开发中一个非常优秀、实用的数据库解决方案**，特别适合中小型项目或任何希望以类型安全和响应式方式管理本地 SQLite 数据的场景。它完美地平衡了功能性和易用性。
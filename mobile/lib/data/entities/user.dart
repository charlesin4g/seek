
/// 用户基本信息
library;
import 'package:floor/floor.dart';
import 'package:mobile/annotations/field_info.dart';

@Entity(tableName: 'train_station')
class User {
  @PrimaryKey(autoGenerate: true)
  final int? id;  

  @ColumnInfo(name: 'name')
  @FieldInfo('姓名', isRequired: true, example: '张三')
  final String name;

  @ColumnInfo(name: 'year')
  @FieldInfo('出生年', isRequired: false, example: '20')
  final int? year;

  User({this.id, required this.name, required this.year});
}


/// 字段描述注解
class FieldInfo {
  final String description;
  final String? example;
  final List<String>? enumValues;
  final bool isRequired;

  const FieldInfo(
    this.description, {
    this.example,
    this.enumValues,
    this.isRequired = false,
  });
}



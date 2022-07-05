enum ValueType { string, float, bool, int }

class TypedValue {
  final dynamic value;
  final ValueType type;

  TypedValue(this.value, this.type);

  Map<String, dynamic> toMap() {
    return {
      "value": value,
      "type": type.toString().substring(type.toString().indexOf('.') + 1)
    };
  }
}

part of 'todo_model.dart';

class ToDoItemAdapter extends TypeAdapter<ToDoItem> {
  @override
  final int typeId = 0;

  @override
  ToDoItem read(BinaryReader reader) {
    final count = reader.readByte();

    int? id;
    String? name;
    bool? isActive;

    for (var i = 0; i < count; i++) {
      final field = reader.readByte();

      if (field == 0) {
        id = reader.read() as int?;
      } else if (field == 1) {
        name = reader.read() as String?;
      } else if (field == 2) {
        isActive = reader.read() as bool?;
      }
    }

    return ToDoItem(
      id: id ?? 0,
      name: name ?? '',
      isActive: isActive ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, ToDoItem item) {
    writer.writeByte(3);

    writer.writeByte(0);
    writer.write(item.id);

    writer.writeByte(1);
    writer.write(item.name);

    writer.writeByte(2);
    writer.write(item.isActive);
  }

  @override
  bool operator ==(Object other) {
    return other is ToDoItemAdapter && typeId == other.typeId;
  }

  @override
  int get hashCode => typeId;
}
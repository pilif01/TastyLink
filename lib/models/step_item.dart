import 'package:hive/hive.dart';

part 'step_item.g.dart';

@HiveType(typeId: 1)
class StepItem extends HiveObject {
  @HiveField(0)
  final int index;

  @HiveField(1)
  final String text;

  @HiveField(2)
  final int? durationSec;

  @HiveField(3)
  final String? imageUrl;

  @HiveField(4)
  final String? notes;

  StepItem({
    required this.index,
    required this.text,
    this.durationSec,
    this.imageUrl,
    this.notes,
  });

  factory StepItem.fromMap(Map<String, dynamic> map) {
    return StepItem(
      index: map['index'] ?? 0,
      text: map['text'] ?? '',
      durationSec: map['durationSec'],
      imageUrl: map['imageUrl'],
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'index': index,
      'text': text,
      'durationSec': durationSec,
      'imageUrl': imageUrl,
      'notes': notes,
    };
  }

  StepItem copyWith({
    int? index,
    String? text,
    int? durationSec,
    String? imageUrl,
    String? notes,
  }) {
    return StepItem(
      index: index ?? this.index,
      text: text ?? this.text,
      durationSec: durationSec ?? this.durationSec,
      imageUrl: imageUrl ?? this.imageUrl,
      notes: notes ?? this.notes,
    );
  }

  Duration? get duration {
    return durationSec != null ? Duration(seconds: durationSec!) : null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StepItem &&
        other.index == index &&
        other.text == text &&
        other.durationSec == durationSec &&
        other.imageUrl == imageUrl &&
        other.notes == notes;
  }

  @override
  int get hashCode {
    return index.hashCode ^
        text.hashCode ^
        durationSec.hashCode ^
        imageUrl.hashCode ^
        notes.hashCode;
  }

  @override
  String toString() {
    return 'Step $index: $text';
  }
}

import 'dart:convert';

enum HabitPriority { low, medium, high }

class Habit {
  final String id;
  final String title;
  final HabitPriority priority;
  int streak;
  bool isCompleted;
  final List<String> completedDates;

  Habit({
    required this.id,
    required this.title,
    this.priority = HabitPriority.medium,
    this.streak = 0,
    this.isCompleted = false,
    List<String>? completedDates,
  }) : completedDates = completedDates ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'priority': priority.index,
      'streak': streak,
      'isCompleted': isCompleted,
      'completedDates': completedDates,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'],
      title: map['title'],
      priority: HabitPriority.values[map['priority'] ?? 1],
      streak: map['streak'] ?? 0,
      isCompleted: map['isCompleted'] ?? false,
      completedDates: List<String>.from(map['completedDates'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());
  factory Habit.fromJson(String source) => Habit.fromMap(json.decode(source));
}

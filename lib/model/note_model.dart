class Note {
  int? id;
  String? title;
  DateTime? date;
  String? priority;
  int? status;

  Note({this.title, this.date, this.priority, this.status});

  Note.withId({this.id, this.title, this.date, this.priority, this.status});

  //Note :>

  // To store Note object inside a database we need to change Note to a Map

  // Convert a Note instance into a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date?.toIso8601String(),
      'priority': priority,
      'status': status,
    };
  }

  // Convert a map into a Note Object instance
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note.withId(
      id: map['id'],
      title: map['title'],
      date: map['date'] != null ? DateTime.parse(map['date']) : null,
      priority: map['priority'],
      status: map['status'],
    );
  }
}

import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class FamilyMember {
  final String id;
  String name;
  String role;
  String? birthday;
  String color;
  String? favColor;
  String? favFood;
  String? favUlam;
  String? favSnack;
  String? favDrink;
  String? allergens;
  String? illnesses;
  double? weight;
  double? height;
  int points;

  FamilyMember({
    String? id,
    required this.name,
    required this.role,
    this.birthday,
    this.color = '#7B1FA2',
    this.favColor,
    this.favFood,
    this.favUlam,
    this.favSnack,
    this.favDrink,
    this.allergens,
    this.illnesses,
    this.weight,
    this.height,
    this.points = 0,
  }) : id = id ?? _uuid.v4();

  int get age {
    if (birthday == null) return 0;
    final birth = DateTime.parse(birthday!);
    final now = DateTime.now();
    int age = now.year - birth.year;
    if (now.month < birth.month || (now.month == birth.month && now.day < birth.day)) {
      age--;
    }
    return age;
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'role': role, 'birthday': birthday,
    'color': color, 'favColor': favColor, 'favFood': favFood,
    'favUlam': favUlam, 'favSnack': favSnack, 'favDrink': favDrink,
    'allergens': allergens, 'illnesses': illnesses,
    'weight': weight, 'height': height, 'points': points,
  };

  factory FamilyMember.fromJson(Map<String, dynamic> json) => FamilyMember(
    id: json['id'], name: json['name'], role: json['role'],
    birthday: json['birthday'], color: json['color'] ?? '#7B1FA2',
    favColor: json['favColor'], favFood: json['favFood'],
    favUlam: json['favUlam'], favSnack: json['favSnack'],
    favDrink: json['favDrink'], allergens: json['allergens'],
    illnesses: json['illnesses'], weight: json['weight']?.toDouble(),
    height: json['height']?.toDouble(), points: json['points'] ?? 0,
  );
}

class Income {
  final String id;
  String source;
  double amount;
  String date;
  String frequency;
  String? notes;

  Income({
    String? id,
    required this.source,
    required this.amount,
    required this.date,
    this.frequency = 'monthly',
    this.notes,
  }) : id = id ?? _uuid.v4();

  Map<String, dynamic> toJson() => {
    'id': id, 'source': source, 'amount': amount,
    'date': date, 'frequency': frequency, 'notes': notes,
  };

  factory Income.fromJson(Map<String, dynamic> json) => Income(
    id: json['id'], source: json['source'], amount: json['amount']?.toDouble(),
    date: json['date'], frequency: json['frequency'], notes: json['notes'],
  );
}

class Expense {
  final String id;
  String name;
  double amount;
  String date;
  String type;
  String category;
  String? notes;

  Expense({
    String? id,
    required this.name,
    required this.amount,
    required this.date,
    this.type = 'variable',
    this.category = 'other',
    this.notes,
  }) : id = id ?? _uuid.v4();

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'amount': amount,
    'date': date, 'type': type, 'category': category, 'notes': notes,
  };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    id: json['id'], name: json['name'], amount: json['amount']?.toDouble(),
    date: json['date'], type: json['type'], category: json['category'],
    notes: json['notes'],
  );
}

class SavingsGoal {
  final String id;
  String name;
  double target;
  double current;
  String type;
  String? date;

  SavingsGoal({
    String? id,
    required this.name,
    required this.target,
    this.current = 0,
    this.type = 'short',
    this.date,
  }) : id = id ?? _uuid.v4();

  double get progress => target > 0 ? (current / target).clamp(0, 1) : 0;

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'target': target,
    'current': current, 'type': type, 'date': date,
  };

  factory SavingsGoal.fromJson(Map<String, dynamic> json) => SavingsGoal(
    id: json['id'], name: json['name'], target: json['target']?.toDouble(),
    current: json['current']?.toDouble() ?? 0, type: json['type'],
    date: json['date'],
  );
}

class Bill {
  final String id;
  String name;
  double amount;
  String dueDate;
  String category;
  String repeat;
  String status;
  String? notes;

  Bill({
    String? id,
    required this.name,
    required this.amount,
    required this.dueDate,
    this.category = 'other',
    this.repeat = 'monthly',
    this.status = 'pending',
    this.notes,
  }) : id = id ?? _uuid.v4();

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'amount': amount,
    'dueDate': dueDate, 'category': category, 'repeat': repeat,
    'status': status, 'notes': notes,
  };

  factory Bill.fromJson(Map<String, dynamic> json) => Bill(
    id: json['id'], name: json['name'], amount: json['amount']?.toDouble(),
    dueDate: json['dueDate'], category: json['category'],
    repeat: json['repeat'], status: json['status'], notes: json['notes'],
  );
}

class Chore {
  final String id;
  String name;
  int points;
  String? assigneeId;
  String dueDate;
  String repeat;
  String type;
  String priority;
  String status;
  String? description;

  Chore({
    String? id,
    required this.name,
    this.points = 10,
    this.assigneeId,
    required this.dueDate,
    this.repeat = 'weekly',
    this.type = 'regular',
    this.priority = 'medium',
    this.status = 'pending',
    this.description,
  }) : id = id ?? _uuid.v4();

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'points': points,
    'assigneeId': assigneeId, 'dueDate': dueDate, 'repeat': repeat,
    'type': type, 'priority': priority, 'status': status,
    'description': description,
  };

  factory Chore.fromJson(Map<String, dynamic> json) => Chore(
    id: json['id'], name: json['name'], points: json['points'] ?? 10,
    assigneeId: json['assigneeId'], dueDate: json['dueDate'],
    repeat: json['repeat'], type: json['type'],
    priority: json['priority'] ?? 'medium', status: json['status'],
    description: json['description'],
  );
}

class CalendarEvent {
  final String id;
  String title;
  String date;
  String? time;
  String color;
  String type;
  String? notes;

  CalendarEvent({
    String? id,
    required this.title,
    required this.date,
    this.time,
    this.color = '#7B1FA2',
    this.type = 'event',
    this.notes,
  }) : id = id ?? _uuid.v4();

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'date': date,
    'time': time, 'color': color, 'type': type, 'notes': notes,
  };

  factory CalendarEvent.fromJson(Map<String, dynamic> json) => CalendarEvent(
    id: json['id'], title: json['title'], date: json['date'],
    time: json['time'], color: json['color'] ?? '#7B1FA2',
    type: json['type'] ?? 'event', notes: json['notes'],
  );
}

class Meal {
  final String id;
  String day;
  String type;
  String name;

  Meal({
    String? id,
    required this.day,
    required this.type,
    required this.name,
  }) : id = id ?? _uuid.v4();

  Map<String, dynamic> toJson() => {
    'id': id, 'day': day, 'type': type, 'name': name,
  };

  factory Meal.fromJson(Map<String, dynamic> json) => Meal(
    id: json['id'], day: json['day'], type: json['type'], name: json['name'],
  );
}

class InventoryItem {
  final String id;
  String name;
  String category;
  String quantity;
  String? expiry;
  String? quality;
  String? status;
  String? link;

  InventoryItem({
    String? id,
    required this.name,
    required this.category,
    this.quantity = '1',
    this.expiry,
    this.quality,
    this.status,
    this.link,
  }) : id = id ?? _uuid.v4();

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'category': category,
    'quantity': quantity, 'expiry': expiry, 'quality': quality,
    'status': status, 'link': link,
  };

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
    id: json['id'], name: json['name'], category: json['category'],
    quantity: json['quantity'] ?? '1', expiry: json['expiry'],
    quality: json['quality'], status: json['status'], link: json['link'],
  );
}

class Task {
  final String id;
  String title;
  String type;
  String? time;
  String? day;
  bool completed;

  Task({
    String? id,
    required this.title,
    this.type = 'priority',
    this.time,
    this.day,
    this.completed = false,
  }) : id = id ?? _uuid.v4();

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'type': type,
    'time': time, 'day': day, 'completed': completed,
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'], title: json['title'], type: json['type'],
    time: json['time'], day: json['day'], completed: json['completed'] ?? false,
  );
}

class Reward {
  final String id;
  String name;
  int points;
  String? description;

  Reward({
    String? id,
    required this.name,
    this.points = 50,
    this.description,
  }) : id = id ?? _uuid.v4();

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'points': points, 'description': description,
  };

  factory Reward.fromJson(Map<String, dynamic> json) => Reward(
    id: json['id'], name: json['name'], points: json['points'] ?? 50,
    description: json['description'],
  );
}

class Goal {
  final String id;
  String title;
  String period;
  String? date;
  bool completed;

  Goal({
    String? id,
    required this.title,
    this.period = 'weekly',
    this.date,
    this.completed = false,
  }) : id = id ?? _uuid.v4();

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'period': period,
    'date': date, 'completed': completed,
  };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
    id: json['id'], title: json['title'], period: json['period'],
    date: json['date'], completed: json['completed'] ?? false,
  );
}

class JournalEntry {
  final String id;
  String date;
  List<String> gratitude;
  String moodAm;
  String moodPm;
  String? emotions;
  String? notes;

  JournalEntry({
    String? id,
    required this.date,
    this.gratitude = const [],
    this.moodAm = 'neutral',
    this.moodPm = 'neutral',
    this.emotions,
    this.notes,
  }) : id = id ?? _uuid.v4();

  Map<String, dynamic> toJson() => {
    'id': id, 'date': date, 'gratitude': gratitude,
    'moodAm': moodAm, 'moodPm': moodPm, 'emotions': emotions, 'notes': notes,
  };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
    id: json['id'], date: json['date'],
    gratitude: List<String>.from(json['gratitude'] ?? []),
    moodAm: json['moodAm'] ?? 'neutral', moodPm: json['moodPm'] ?? 'neutral',
    emotions: json['emotions'], notes: json['notes'],
  );
}

class UtilityEntry {
  final String id;
  String month;
  String type;
  double? prevReading;
  double? currReading;
  double? rate;
  double expected;
  double actual;

  UtilityEntry({
    String? id,
    required this.month,
    required this.type,
    this.prevReading,
    this.currReading,
    this.rate,
    this.expected = 0,
    this.actual = 0,
  }) : id = id ?? _uuid.v4();

  double get usage => (currReading ?? 0) - (prevReading ?? 0);
  double get diff => actual - expected;

  Map<String, dynamic> toJson() => {
    'id': id, 'month': month, 'type': type,
    'prevReading': prevReading, 'currReading': currReading,
    'rate': rate, 'expected': expected, 'actual': actual,
  };

  factory UtilityEntry.fromJson(Map<String, dynamic> json) => UtilityEntry(
    id: json['id'], month: json['month'], type: json['type'],
    prevReading: json['prevReading']?.toDouble(),
    currReading: json['currReading']?.toDouble(),
    rate: json['rate']?.toDouble(),
    expected: json['expected']?.toDouble() ?? 0,
    actual: json['actual']?.toDouble() ?? 0,
  );
}

class Pet {
  final String id;
  String name;
  String species;
  String? breed;
  String? birthday;
  String sex;
  String? allergens;
  String? illnesses;
  String color;

  Pet({
    String? id,
    required this.name,
    this.species = 'Dog',
    this.breed,
    this.birthday,
    this.sex = 'male',
    this.allergens,
    this.illnesses,
    this.color = '#4CAF50',
  }) : id = id ?? _uuid.v4();

  int get age {
    if (birthday == null) return 0;
    final birth = DateTime.parse(birthday!);
    final now = DateTime.now();
    return now.year - birth.year;
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'species': species, 'breed': breed,
    'birthday': birthday, 'sex': sex, 'allergens': allergens,
    'illnesses': illnesses, 'color': color,
  };

  factory Pet.fromJson(Map<String, dynamic> json) => Pet(
    id: json['id'], name: json['name'], species: json['species'],
    breed: json['breed'], birthday: json['birthday'], sex: json['sex'],
    allergens: json['allergens'], illnesses: json['illnesses'],
    color: json['color'] ?? '#4CAF50',
  );
}

class Habit {
  final String id;
  String name;
  String frequency;
  List<String> completedDays;

  Habit({
    String? id,
    required this.name,
    this.frequency = 'daily',
    this.completedDays = const [],
  }) : id = id ?? _uuid.v4();

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'frequency': frequency,
    'completedDays': completedDays,
  };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
    id: json['id'], name: json['name'], frequency: json['frequency'],
    completedDays: List<String>.from(json['completedDays'] ?? []),
  );
}

class Creation {
  final String id;
  String type;
  String title;
  String? description;
  bool published;

  Creation({
    String? id,
    required this.type,
    required this.title,
    this.description,
    this.published = false,
  }) : id = id ?? _uuid.v4();

  Map<String, dynamic> toJson() => {
    'id': id, 'type': type, 'title': title,
    'description': description, 'published': published,
  };

  factory Creation.fromJson(Map<String, dynamic> json) => Creation(
    id: json['id'], type: json['type'], title: json['title'],
    description: json['description'], published: json['published'] ?? false,
  );
}

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String _getString(String key, String def) =>
      _prefs.getString(key) ?? def;
  static List<dynamic> _getList(String key) =>
      jsonDecode(_prefs.getString(key) ?? '[]');

  static void _setList(String key, List list) {
    _prefs.setString(key, jsonEncode(list));
  }

    static List<Map<String, dynamic>> getFinanceItems(String key) {
        return List<Map<String, dynamic>>.from(_getList(key));
    }

    static Future<void> saveFinanceItems(
            String key, List<Map<String, dynamic>> items) async {
        await _prefs.setString(key, jsonEncode(items));
    }

  // Auth
  static Map<String, dynamic>? getCurrentUser() {
    final data = _getString('currentUser', '{}');
    final json = jsonDecode(data);
    return json.isNotEmpty ? json : null;
  }

  static Future<void> setCurrentUser(Map<String, dynamic> user) async {
    await _prefs.setString('currentUser', jsonEncode(user));
  }

  static Future<void> clearCurrentUser() async {
    await _prefs.remove('currentUser');
  }

  static Map<String, dynamic>? authenticate(String email, String password) {
    final normalizedEmail = email.trim().toLowerCase();
    for (final user in getUsers()) {
      final storedEmail = (user['email'] as String? ?? '').trim().toLowerCase();
      if (storedEmail == normalizedEmail && user['password'] == password) {
        return user;
      }
    }
    return null;
  }

  static bool emailExists(String email) {
    final normalizedEmail = email.trim().toLowerCase();
    return getUsers().any((user) =>
        (user['email'] as String? ?? '').trim().toLowerCase() ==
        normalizedEmail);
  }

  static List<Map<String, dynamic>> getUsers() {
    return List<Map<String, dynamic>>.from(_getList('users'));
  }

  static Future<void> saveUsers(List<Map<String, dynamic>> users) async {
    await _prefs.setString('users', jsonEncode(users));
  }

  // Generic CRUD
  static List<T> getAll<T>(
      String key, T Function(Map<String, dynamic>) fromJson) {
    final list = _getList(key);
    return list.map<T>((e) => fromJson(e as Map<String, dynamic>)).toList();
  }

  static void saveAll<T>(
      String key, List<T> items, Map<String, dynamic> Function(T) toJson) {
    _setList(key, items.map((e) => toJson(e)).toList());
  }

  // Members
  static List<FamilyMember> getMembers() =>
      getAll('members', (j) => FamilyMember.fromJson(j));
  static void saveMembers(List<FamilyMember> items) =>
      saveAll('members', items, (e) => e.toJson());

  // Income
  static List<Income> getIncome() =>
      getAll('income', (j) => Income.fromJson(j));
  static void saveIncome(List<Income> items) =>
      saveAll('income', items, (e) => e.toJson());

  // Expenses
  static List<Expense> getExpenses() =>
      getAll('expenses', (j) => Expense.fromJson(j));
  static void saveExpenses(List<Expense> items) =>
      saveAll('expenses', items, (e) => e.toJson());

  // Savings
  static List<SavingsGoal> getSavings() =>
      getAll('savings', (j) => SavingsGoal.fromJson(j));
  static void saveSavings(List<SavingsGoal> items) =>
      saveAll('savings', items, (e) => e.toJson());

  // Bills
  static List<Bill> getBills() => getAll('bills', (j) => Bill.fromJson(j));
  static void saveBills(List<Bill> items) =>
      saveAll('bills', items, (e) => e.toJson());

  // Chores
  static List<Chore> getChores() => getAll('chores', (j) => Chore.fromJson(j));
  static void saveChores(List<Chore> items) =>
      saveAll('chores', items, (e) => e.toJson());

  // Events
  static List<CalendarEvent> getEvents() =>
      getAll('events', (j) => CalendarEvent.fromJson(j));
  static void saveEvents(List<CalendarEvent> items) =>
      saveAll('events', items, (e) => e.toJson());

  // Meals
  static List<Meal> getMeals() => getAll('meals', (j) => Meal.fromJson(j));
  static void saveMeals(List<Meal> items) =>
      saveAll('meals', items, (e) => e.toJson());

  // Inventory
  static List<InventoryItem> getGroceries() =>
      getAll('groceries', (j) => InventoryItem.fromJson(j));
  static void saveGroceries(List<InventoryItem> items) =>
      saveAll('groceries', items, (e) => e.toJson());

  static List<InventoryItem> getMarketItems() =>
      getAll('marketItems', (j) => InventoryItem.fromJson(j));
  static void saveMarketItems(List<InventoryItem> items) =>
      saveAll('marketItems', items, (e) => e.toJson());

  static List<InventoryItem> getOnlineItems() =>
      getAll('onlineItems', (j) => InventoryItem.fromJson(j));
  static void saveOnlineItems(List<InventoryItem> items) =>
      saveAll('onlineItems', items, (e) => e.toJson());

  // Tasks
  static List<Task> getTasks() => getAll('tasks', (j) => Task.fromJson(j));
  static void saveTasks(List<Task> items) =>
      saveAll('tasks', items, (e) => e.toJson());

  // Rewards
  static List<Reward> getRewards() =>
      getAll('rewards', (j) => Reward.fromJson(j));
  static void saveRewards(List<Reward> items) =>
      saveAll('rewards', items, (e) => e.toJson());

  // Goals
  static List<Goal> getGoals() => getAll('goals', (j) => Goal.fromJson(j));
  static void saveGoals(List<Goal> items) =>
      saveAll('goals', items, (e) => e.toJson());

  // Journals
  static List<JournalEntry> getJournals() =>
      getAll('journals', (j) => JournalEntry.fromJson(j));
  static void saveJournals(List<JournalEntry> items) =>
      saveAll('journals', items, (e) => e.toJson());

  // Utilities
  static List<UtilityEntry> getUtilities() =>
      getAll('utilities', (j) => UtilityEntry.fromJson(j));
  static void saveUtilities(List<UtilityEntry> items) =>
      saveAll('utilities', items, (e) => e.toJson());

  // Pets
  static List<Pet> getPets() => getAll('pets', (j) => Pet.fromJson(j));
  static void savePets(List<Pet> items) =>
      saveAll('pets', items, (e) => e.toJson());

  // Habits
  static List<Habit> getHabits() => getAll('habits', (j) => Habit.fromJson(j));
  static void saveHabits(List<Habit> items) =>
      saveAll('habits', items, (e) => e.toJson());

  // Creations
  static List<Creation> getCreations() =>
      getAll('creations', (j) => Creation.fromJson(j));
  static void saveCreations(List<Creation> items) =>
      saveAll('creations', items, (e) => e.toJson());

  // Penalties
  static List<Map<String, dynamic>> getPenalties() {
    return List<Map<String, dynamic>>.from(_getList('penalties'));
  }

  static void savePenalties(List<Map<String, dynamic>> items) =>
      _setList('penalties', items);

  // Redemptions
  static List<Map<String, dynamic>> getRedemptions() {
    return List<Map<String, dynamic>>.from(_getList('redemptions'));
  }

  static void saveRedemptions(List<Map<String, dynamic>> items) =>
      _setList('redemptions', items);
}

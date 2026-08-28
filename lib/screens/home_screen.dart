import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _subIndex = 0;
  static const tabs = ['Cleaning', 'Meals', 'Chores & Rewards', 'Inventory', 'Maintenance'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 58,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            itemCount: tabs.length,
            separatorBuilder: (context, index) => const SizedBox(width: 7),
            itemBuilder: (_, index) => ChoiceChip(
              label: Text(tabs[index]),
              selected: _subIndex == index,
              onSelected: (_) => setState(() => _subIndex = index),
              selectedColor: AppColors.primary,
              backgroundColor: Colors.white,
              showCheckmark: false,
              labelStyle: TextStyle(
                color: _subIndex == index ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        Expanded(child: _buildPage()),
      ],
    );
  }

  Widget _buildPage() {
    switch (_subIndex) {
      case 0:
        return _buildCleaning();
      case 1:
        return _buildMeals();
      case 2:
        return _buildChoresRewards();
      case 3:
        return _modulePlaceholder('Inventory', 'Track groceries, market items, and online shopping.');
      default:
        return _modulePlaceholder('Maintenance', 'Keep recurring home maintenance tasks visible.');
    }
  }

  Widget _buildCleaning() {
    final tasks = StorageService.getTasks();
    final cleaning = tasks.where((task) => task.type == 'cleaning').toList();
    return _scroll([
      _header('Cleaning Tracker', 'A clear rhythm for daily, weekly, and monthly cleaning.'),
      _actionRow('Cleaning tasks', 'Add task', () => _showAddCleaningTask()),
      _cleaningGroup('Daily must clean', cleaning.where((task) => task.day == 'Daily').toList()),
      _cleaningGroup('Weekly cleaning rotation', cleaning.where((task) => task.day == 'Weekly').toList()),
      _cleaningGroup('Monthly cleanup', cleaning.where((task) => task.day == 'Monthly').toList()),
    ]);
  }

  Widget _cleaningGroup(String title, List<Task> tasks) {
    return _card(title, tasks.isEmpty
        ? _empty('No tasks yet', 'Add a task to build this cleaning list.')
        : Column(children: tasks.map((task) => _taskTile(task)).toList()));
  }

  Widget _taskTile(Task task) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      value: task.completed,
      onChanged: (value) {
        task.completed = value ?? false;
        StorageService.saveTasks(StorageService.getTasks());
        setState(() {});
      },
      title: Text(task.title, style: GoogleFonts.fredoka(fontSize: 16, color: AppColors.textPrimary)),
      subtitle: Text(task.time ?? 'No reminder set', style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textMuted)),
      secondary: IconButton(
        tooltip: 'Remove task',
        icon: const Icon(Icons.delete_outline, color: AppColors.overdue),
        onPressed: () {
          final tasks = StorageService.getTasks()..removeWhere((item) => item.id == task.id);
          StorageService.saveTasks(tasks);
          setState(() {});
        },
      ),
      activeColor: AppColors.paid,
    );
  }

  Widget _buildMeals() {
    final meals = StorageService.getMeals();
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return _scroll([
      _header('Meal Planner', 'Plan breakfast, lunch, and dinner for the week.'),
      _actionRow('Weekly rotation', 'Add meal', () => _showAddMeal()),
      _card('This week', Column(
        children: days.map((day) {
          final dayMeals = meals.where((meal) => meal.day == day).toList();
          return _mealDay(day, dayMeals);
        }).toList(),
      )),
      _card('Meal requests', _empty('No requests yet', 'Family members can request a meal and a date here.')),
    ]);
  }

  Widget _mealDay(String day, List<Meal> meals) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 82, child: Text(day, style: GoogleFonts.fredoka(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
          Expanded(
            child: meals.isEmpty
                ? Text('No meals planned', style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textMuted))
                : Wrap(spacing: 6, runSpacing: 6, children: meals.map((meal) => Chip(
                    avatar: Icon(meal.type == 'Breakfast' ? Icons.wb_sunny : meal.type == 'Lunch' ? Icons.lunch_dining : Icons.nightlight,
                        size: 15, color: AppColors.primary),
                    label: Text('${meal.type}: ${meal.name}'),
                  )).toList()),
          ),
        ],
      ),
    );
  }

  Widget _buildChoresRewards() {
    final chores = StorageService.getChores();
    final rewards = StorageService.getRewards();
    final pending = chores.where((chore) => chore.status == 'pending').length;
    final completed = chores.where((chore) => chore.status == 'completed').length;
    final points = chores.where((chore) => chore.status == 'completed').fold(0, (sum, chore) => sum + chore.points);
    return _scroll([
      _header('Chore & Reward Dashboard', 'Progress for kids, teens, and parents in one place.'),
      _summaryGrid([
        _summary('Pending chores', '$pending', Icons.pending_actions, AppColors.pending),
        _summary('Completed', '$completed', Icons.check_circle_outline, AppColors.paid),
        _summary('Points accumulated', '$points', Icons.stars, Colors.orange),
        _summary('Rewards shelf', '${rewards.length}', Icons.card_giftcard, AppColors.primary),
      ]),
      _actionRow('Family chores', 'Add chore', () => _showAddChore()),
      _card('Today\'s progress', chores.isEmpty
          ? _empty('No chores yet', 'Parents can add recurring chores with points and deadlines.')
          : Column(children: chores.map(_choreTile).toList())),
      _card('Parents dashboard', Column(children: [
        _moduleRow(Icons.fact_check_outlined, 'Action items', '$pending chores waiting for progress or approval.'),
        _moduleRow(Icons.swap_horiz, 'Do this, not that', 'Give bonus points or record a penalty.'),
        _moduleRow(Icons.warning_amber_outlined, 'Penalties to pay', 'Skipped and late chores can be reviewed here.'),
      ])),
      _card('Rewards shelf', rewards.isEmpty
          ? _empty('No rewards yet', 'Add rewards that family members can redeem with points.')
          : Column(children: rewards.map((reward) => _rewardTile(reward)).toList())),
    ]);
  }

  Widget _choreTile(Chore chore) {
    final isHigh = chore.priority == 'high';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: (isHigh ? AppColors.overdue : AppColors.primary).withValues(alpha: .12),
        child: Icon(isHigh ? Icons.priority_high : Icons.cleaning_services, color: isHigh ? AppColors.overdue : AppColors.primary),
      ),
      title: Text(chore.name, style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
      subtitle: Text('${chore.points} points · Due ${chore.dueDate} · ${chore.repeat}', style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textMuted)),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          chore.status = value;
          StorageService.saveChores(StorageService.getChores());
          setState(() {});
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'completed', child: Text('Done')),
          PopupMenuItem(value: 'skipped', child: Text('Skip')),
          PopupMenuItem(value: 'pending', child: Text('Pending')),
        ],
      ),
    );
  }

  Widget _rewardTile(Reward reward) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.card_giftcard, color: AppColors.primary),
      title: Text(reward.name, style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
      subtitle: Text(reward.description ?? 'Family reward', style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textMuted)),
      trailing: Text('${reward.points} pts', style: GoogleFonts.fredoka(color: AppColors.primary)),
    );
  }

  Widget _scroll(List<Widget> children) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children.expand((item) => [item, const SizedBox(height: 16)]).toList()),
      );

  Widget _header(String title, String subtitle) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.fredoka(fontSize: 27, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        Text(subtitle, style: GoogleFonts.nunito(color: AppColors.textMuted)),
      ]);

  Widget _actionRow(String title, String action, VoidCallback onPressed) => Row(children: [
        Expanded(child: Text(title, style: GoogleFonts.fredoka(fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
        ElevatedButton.icon(onPressed: onPressed, icon: const Icon(Icons.add, size: 17), label: Text(action)),
      ]);

  Widget _card(String title, Widget child) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          child,
        ]),
      );

  Widget _empty(String title, String detail) => Row(children: [
        const Icon(Icons.add_circle_outline, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
          Text(detail, style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textMuted)),
        ])),
      ]);

  Widget _summaryGrid(List<Widget> children) => LayoutBuilder(builder: (_, constraints) {
        final columns = constraints.maxWidth > 650 ? 4 : 2;
        final width = (constraints.maxWidth - (columns - 1) * 10) / columns;
        return Wrap(spacing: 10, runSpacing: 10, children: children.map((item) => SizedBox(width: width, child: item)).toList());
      });

  Widget _summary(String label, String value, IconData icon, Color color) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.fredoka(fontSize: 23, fontWeight: FontWeight.w700, color: color)),
          Text(label, style: GoogleFonts.nunito(fontSize: 11, color: AppColors.textSecondary)),
        ]),
      );

  Widget _moduleRow(IconData icon, String title, String detail) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(backgroundColor: AppColors.primaryLight, child: Icon(icon, color: AppColors.primary)),
        title: Text(title, style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
        subtitle: Text(detail, style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textMuted)),
      );

  Widget _modulePlaceholder(String title, String subtitle) => _scroll([
        _header(title, subtitle),
        _card(title, _empty('Module ready to customize', 'Add your first item to begin.')),
      ]);

  void _showAddCleaningTask() {
    final title = TextEditingController();
    String cadence = 'Daily';
    _formDialog('Add cleaning task', [TextField(controller: title, decoration: const InputDecoration(labelText: 'Task name')),
      DropdownButtonFormField<String>(initialValue: cadence, decoration: const InputDecoration(labelText: 'Rotation'), items: const ['Daily', 'Weekly', 'Monthly'].map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(), onChanged: (value) => cadence = value ?? 'Daily')], () {
      if (title.text.trim().isEmpty) return;
      final tasks = StorageService.getTasks()..add(Task(title: title.text.trim(), type: 'cleaning', day: cadence, time: 'Reminder to be set'));
      StorageService.saveTasks(tasks);
      setState(() {});
    });
  }

  void _showAddMeal() {
    final name = TextEditingController();
    String day = 'Monday';
    String type = 'Dinner';
    _formDialog('Add weekly meal', [TextField(controller: name, decoration: const InputDecoration(labelText: 'Meal name')),
      DropdownButtonFormField<String>(initialValue: day, decoration: const InputDecoration(labelText: 'Day'), items: const ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'].map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(), onChanged: (value) => day = value ?? 'Monday'),
      DropdownButtonFormField<String>(initialValue: type, decoration: const InputDecoration(labelText: 'Meal type'), items: const ['Breakfast', 'Lunch', 'Dinner'].map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(), onChanged: (value) => type = value ?? 'Dinner')], () {
      if (name.text.trim().isEmpty) return;
      final meals = StorageService.getMeals()..add(Meal(day: day, type: type, name: name.text.trim()));
      StorageService.saveMeals(meals);
      setState(() {});
    });
  }

  void _showAddChore() {
    final name = TextEditingController();
    final points = TextEditingController(text: '10');
    String priority = 'medium';
    _formDialog('Add chore', [TextField(controller: name, decoration: const InputDecoration(labelText: 'Chore name')),
      TextField(controller: points, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Points')),
      DropdownButtonFormField<String>(initialValue: priority, decoration: const InputDecoration(labelText: 'Priority'), items: const ['low', 'medium', 'high'].map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(), onChanged: (value) => priority = value ?? 'medium')], () {
      final value = int.tryParse(points.text) ?? 10;
      if (name.text.trim().isEmpty) return;
      final chores = StorageService.getChores()..add(Chore(name: name.text.trim(), points: value, priority: priority, dueDate: DateTime.now().toIso8601String().split('T').first));
      StorageService.saveChores(chores);
      setState(() {});
    });
  }

  void _formDialog(String title, List<Widget> fields, VoidCallback onSave) {
    showDialog(context: context, builder: (dialogContext) => AlertDialog(title: Text(title, style: GoogleFonts.fredoka(fontWeight: FontWeight.w700)), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: fields)), actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')), ElevatedButton(onPressed: () { onSave(); Navigator.pop(dialogContext); }, child: const Text('Save'))]));
  }
}

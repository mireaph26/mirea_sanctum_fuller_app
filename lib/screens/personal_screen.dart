import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class PersonalScreen extends StatefulWidget {
  const PersonalScreen({super.key});

  @override
  State<PersonalScreen> createState() => _PersonalScreenState();
}

class _PersonalScreenState extends State<PersonalScreen> {
  int tab = 0;
  static const tabs = ['Dashboard', 'My Goals', 'Journal', 'Planner', 'Study'];

  @override
  Widget build(BuildContext context) => Column(children: [
        SizedBox(height: 58, child: ListView.separated(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), itemCount: tabs.length, separatorBuilder: (context, index) => const SizedBox(width: 7), itemBuilder: (_, index) => ChoiceChip(label: Text(tabs[index]), selected: tab == index, onSelected: (_) => setState(() => tab = index), selectedColor: AppColors.primary, backgroundColor: Colors.white, showCheckmark: false, labelStyle: TextStyle(color: tab == index ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.w700)))),
        Expanded(child: _page()),
      ]);

  Widget _page() {
    switch (tab) {
      case 1: return _goals();
      case 2: return _journal();
      case 3: return _planner();
      case 4: return _planner(study: true);
      default: return _dashboard();
    }
  }

  Widget _dashboard() {
    final goals = StorageService.getGoals();
    final habits = StorageService.getHabits();
    return _scroll([
      _header('Personal Dashboard', 'Private goals, reflections, discipline, and planning.'),
      _grid([
        _stat('Weekly goals', '${goals.where((item) => item.period == 'weekly').length}', Icons.flag_outlined, AppColors.primary),
        _stat('Monthly goals', '${goals.where((item) => item.period == 'monthly').length}', Icons.calendar_month, Colors.orange),
        _stat('Daily habits', '${habits.length}', Icons.local_fire_department, AppColors.accent),
      ]),
      _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('My goals', style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)), const SizedBox(height: 10), goals.isEmpty ? _empty('No goals yet', 'Add a goal to create your private progress board.') : Column(children: goals.take(4).map(_goalTile).toList())])),
      _card(_row(Icons.menu_book, 'Daily journal', 'Capture gratitude, mood, emotions, and notes.')),
      _card(_row(Icons.schedule, 'Time management', 'Plan daily non-negotiables, priorities, and weekly schedules.')),
      _card(_row(Icons.account_balance_wallet, 'Financial discipline', 'Keep a private personal finance reflection ready to submit as a report.')),
    ]);
  }

  Widget _goals() {
    final goals = StorageService.getGoals();
    return _scroll([_header('My Goals', 'Weekly and monthly targets with streak-friendly check-ins.'), _action('Goals', 'Add goal', _addGoal), _card(goals.isEmpty ? _empty('No goals yet', 'Create your first weekly or monthly goal.') : Column(children: goals.map(_goalTile).toList()))]);
  }

  Widget _goalTile(Goal goal) => CheckboxListTile(contentPadding: EdgeInsets.zero, value: goal.completed, onChanged: (value) { goal.completed = value ?? false; StorageService.saveGoals(StorageService.getGoals()); setState(() {}); }, title: Text(goal.title, style: GoogleFonts.fredoka(fontSize: 16, color: AppColors.textPrimary)), subtitle: Text('${goal.period} ${goal.date == null ? '' : '· ${goal.date}'}', style: GoogleFonts.nunito(color: AppColors.textMuted)), activeColor: AppColors.paid);

  Widget _journal() {
    final entries = StorageService.getJournals();
    return _scroll([_header('Daily Journal', 'A private space for gratitude, mood, and reflection.'), _action('Journal entries', 'Write entry', _addJournal), _card(entries.isEmpty ? _empty('No entries yet', 'Write three gratitudes and name how you feel today.') : Column(children: entries.map((entry) => _row(Icons.edit_note, entry.date, '${entry.moodAm} morning · ${entry.moodPm} night\n${entry.notes ?? 'Gratitude entry'}')).toList()))]);
  }

  Widget _planner({bool study = false}) {
    final plans = StorageService.getFinanceItems(study ? 'studyPlans' : 'personalPlans');
    return _scroll([_header(study ? 'Study Planner' : 'Time Management', study ? 'Plan classes, study sessions, and essentials.' : 'Plan non-negotiables, priorities, and daily schedules.'), _action(study ? 'Study schedule' : 'Today\'s schedule', 'Add plan', () => _addPlan(study)), _card(plans.isEmpty ? _empty('Nothing planned yet', 'Add a plan to make this space your daily template.') : Column(children: plans.map((plan) => _row(study ? Icons.school_outlined : Icons.schedule, plan['date']?.toString() ?? 'Plan', '${plan['title'] ?? ''}\n${plan['notes'] ?? ''}')).toList()))]);
  }

  Widget _scroll(List<Widget> children) => SingleChildScrollView(padding: const EdgeInsets.fromLTRB(20, 18, 20, 32), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children.expand((item) => [item, const SizedBox(height: 16)]).toList()));
  Widget _header(String title, String subtitle) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: GoogleFonts.fredoka(fontSize: 27, fontWeight: FontWeight.w700, color: AppColors.textPrimary)), const SizedBox(height: 4), Text(subtitle, style: GoogleFonts.nunito(color: AppColors.textMuted))]);
  Widget _action(String title, String label, VoidCallback onPressed) => Row(children: [Expanded(child: Text(title, style: GoogleFonts.fredoka(fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.textPrimary))), ElevatedButton.icon(onPressed: onPressed, icon: const Icon(Icons.add, size: 17), label: Text(label))]);
  Widget _card(Widget child) => Container(width: double.infinity, padding: const EdgeInsets.all(17), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: child);
  Widget _empty(String title, String detail) => Row(children: [const Icon(Icons.add_circle_outline, color: AppColors.primary), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: GoogleFonts.nunito(fontWeight: FontWeight.w800)), Text(detail, style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textMuted))]))]);
  Widget _row(IconData icon, String title, String detail) => ListTile(contentPadding: EdgeInsets.zero, leading: CircleAvatar(backgroundColor: AppColors.primaryLight, child: Icon(icon, color: AppColors.primary)), title: Text(title, style: GoogleFonts.nunito(fontWeight: FontWeight.w800)), subtitle: Text(detail, style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textMuted)));
  Widget _grid(List<Widget> items) => LayoutBuilder(builder: (_, constraints) { final width = (constraints.maxWidth - 20) / 3; return Wrap(spacing: 10, children: items.map((item) => SizedBox(width: width, child: item)).toList()); });
  Widget _stat(String label, String value, IconData icon, Color color) => Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: color), const SizedBox(height: 6), Text(value, style: GoogleFonts.fredoka(fontSize: 23, color: color)), Text(label, style: GoogleFonts.nunito(fontSize: 11, color: AppColors.textSecondary))]));

  void _form(String title, List<Widget> fields, VoidCallback save) => showDialog(context: context, builder: (dialogContext) => AlertDialog(title: Text(title, style: GoogleFonts.fredoka(fontWeight: FontWeight.w700)), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: fields)), actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')), ElevatedButton(onPressed: () { save(); Navigator.pop(dialogContext); }, child: const Text('Save'))]));
  void _addGoal() { final title = TextEditingController(); String period = 'weekly'; _form('Add goal', [TextField(controller: title, decoration: const InputDecoration(labelText: 'Goal')), DropdownButtonFormField<String>(initialValue: period, decoration: const InputDecoration(labelText: 'Period'), items: const ['daily', 'weekly', 'monthly'].map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(), onChanged: (value) => period = value ?? 'weekly')], () { if (title.text.trim().isEmpty) return; final goals = StorageService.getGoals()..add(Goal(title: title.text.trim(), period: period)); StorageService.saveGoals(goals); setState(() {}); }); }
  void _addJournal() { final notes = TextEditingController(); final gratitude = [TextEditingController(), TextEditingController(), TextEditingController()]; String moodAm = 'neutral'; String moodPm = 'neutral'; _form('Daily journal', [...gratitude.asMap().entries.map((entry) => TextField(controller: entry.value, decoration: InputDecoration(labelText: 'Gratitude ${entry.key + 1}'))), TextField(controller: notes, maxLines: 4, decoration: const InputDecoration(labelText: 'Reflection')), DropdownButtonFormField<String>(initialValue: moodAm, decoration: const InputDecoration(labelText: 'Morning mood'), items: const ['happy', 'calm', 'neutral', 'sad', 'anxious'].map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(), onChanged: (value) => moodAm = value ?? 'neutral'), DropdownButtonFormField<String>(initialValue: moodPm, decoration: const InputDecoration(labelText: 'Night mood'), items: const ['happy', 'calm', 'neutral', 'sad', 'anxious'].map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(), onChanged: (value) => moodPm = value ?? 'neutral')], () { final entries = StorageService.getJournals()..add(JournalEntry(date: DateTime.now().toIso8601String().split('T').first, gratitude: gratitude.map((item) => item.text.trim()).where((item) => item.isNotEmpty).toList(), moodAm: moodAm, moodPm: moodPm, notes: notes.text.trim())); StorageService.saveJournals(entries); setState(() {}); }); }
  void _addPlan(bool study) { final title = TextEditingController(); final notes = TextEditingController(); _form(study ? 'Add study plan' : 'Add schedule item', [TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')), TextField(controller: notes, decoration: const InputDecoration(labelText: 'Notes'))], () { final key = study ? 'studyPlans' : 'personalPlans'; final plans = StorageService.getFinanceItems(key)..add({'title': title.text.trim(), 'notes': notes.text.trim(), 'date': DateTime.now().toIso8601String().split('T').first}); StorageService.saveFinanceItems(key, plans); setState(() {}); }); }
}

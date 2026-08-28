import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  int _subIndex = 0;
  static const tabs = ['Profiles', 'Calendar', 'Health', 'Emergency', 'Pets', 'Newborn'];

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        height: 58,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          itemCount: tabs.length,
          separatorBuilder: (context, index) => const SizedBox(width: 7),
          itemBuilder: (_, index) => ChoiceChip(
            label: Text(tabs[index]), selected: _subIndex == index,
            onSelected: (_) => setState(() => _subIndex = index),
            selectedColor: AppColors.primary, backgroundColor: Colors.white, showCheckmark: false,
            labelStyle: TextStyle(color: _subIndex == index ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.w700),
          ),
        ),
      ),
      Expanded(child: _page()),
    ]);
  }

  Widget _page() {
    switch (_subIndex) {
      case 0: return _profiles();
      case 1: return _calendar();
      case 4: return _pets();
      case 5: return _newborn();
      default: return _placeholder(tabs[_subIndex], 'This family space is ready for your household records.');
    }
  }

  Widget _profiles() {
    final members = StorageService.getMembers();
    return _scroll([
      _header('Family Profiles', 'A shared reflection of everyone in your household.'),
      _action('Family members', 'Add member', _addMember),
      _card(members.isEmpty ? _empty('No profiles yet', 'Add each family member to begin.') : Column(children: members.map(_memberTile).toList())),
    ]);
  }

  Widget _memberTile(FamilyMember member) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(backgroundColor: AppColors.primaryLight, child: Text(member.name.isEmpty ? '?' : member.name[0].toUpperCase(), style: GoogleFonts.fredoka(color: AppColors.primaryDark))),
      title: Text(member.name, style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.w700)),
      subtitle: Text('${member.role} · ${member.age > 0 ? '${member.age} years old' : 'Birthday not set'}', style: GoogleFonts.nunito(color: AppColors.textMuted)),
      trailing: Text('${member.points} pts', style: GoogleFonts.fredoka(color: AppColors.primary)),
    );
  }

  Widget _calendar() {
    final events = StorageService.getEvents();
    return _scroll([
      _header('Family Calendar', 'Events, reminders, and notes in one shared view.'),
      Row(children: [
        Expanded(child: ElevatedButton.icon(onPressed: _addEvent, icon: const Icon(Icons.add), label: const Text('Add event'))),
        const SizedBox(width: 10),
        Expanded(child: OutlinedButton.icon(onPressed: () => _openCalendar('Google Calendar'), icon: const Icon(Icons.event), label: const Text('Google'))),
      ]),
      OutlinedButton.icon(onPressed: () => _openCalendar('Apple Calendar'), icon: const Icon(Icons.calendar_month), label: const Text('Open calendar settings')),
        _card(events.isEmpty
          ? _empty('No events yet', 'Add reminders, appointments, or family notes.')
          : Column(
            children: events
              .map((event) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_note, color: AppColors.primary),
                title: Text(event.title, style: GoogleFonts.fredoka(fontSize: 16)),
                subtitle: Text(
                  '${event.date}${event.time == null ? '' : ' · ${event.time}'}${event.notes == null ? '' : '\n${event.notes}'}',
                  style: GoogleFonts.nunito(color: AppColors.textMuted)),
                ))
              .toList())),
    ]);
  }

  Widget _pets() {
    final pets = StorageService.getPets();
    return _scroll([
      _header('Pets Care', 'Profiles, feeding, grooming, health, and expenses.'),
      _action('Pet profiles', 'Add pet', _addPet),
      _card(pets.isEmpty ? _empty('No pets yet', 'Create a profile for feeding and care records.') : Column(children: pets.map((pet) => _petTile(pet)).toList())),
      _card(_moduleRow(Icons.restaurant, 'Feeding schedules', 'Track food brand, type, and daily feeding times.')),
      _card(_moduleRow(Icons.content_cut, 'Grooming and care', 'Record groomer, bath schedule, flea treatment, and products.')),
      _card(_moduleRow(Icons.receipt_long, 'Pet expenses', 'Foods, vet visits, medication, vitamins, and grooming products.')),
    ]);
  }

  Widget _petTile(Pet pet) {
    return ListTile(contentPadding: EdgeInsets.zero, leading: CircleAvatar(backgroundColor: _color(pet.color), child: Icon(pet.species.toLowerCase() == 'cat' ? Icons.pets : Icons.directions_run, color: Colors.white)), title: Text(pet.name, style: GoogleFonts.fredoka(fontSize: 17, fontWeight: FontWeight.w700)), subtitle: Text('${pet.species} · ${pet.breed ?? 'Breed not set'} · ${pet.age} years old\n${pet.sex} · ${pet.allergens ?? 'No allergens recorded'}', style: GoogleFonts.nunito(color: AppColors.textMuted)));
  }

  Widget _newborn() {
    final logs = StorageService.getFinanceItems('newbornLogs');
    return _scroll([
      _header('Newborn Care', 'Gentle tracking for feeding, sleep, growth, and diapers.'),
      _action('Today\'s care log', 'Add log', _addNewbornLog),
      _card(logs.isEmpty ? _empty('No logs yet', 'Parents can add a feeding, sleep, growth, diaper, or doctor note.') : Column(children: logs.map((log) => _moduleRow(Icons.child_care, log['type']?.toString() ?? 'Care log', '${log['date'] ?? ''} · ${log['note'] ?? ''}')).toList())),
      _card(_moduleRow(Icons.show_chart, 'Sleep pattern', 'Track naps, night sleep, wake windows, and quality.')),
      _card(_moduleRow(Icons.monitor_weight, 'Growth records', 'Record weight, height, and head circumference over time.')),
      _card(_moduleRow(Icons.vaccines, 'Vaccination and doctor visits', 'Schedule immunizations, visits, reactions, and notes.')),
    ]);
  }

  Widget _scroll(List<Widget> children) => SingleChildScrollView(padding: const EdgeInsets.fromLTRB(20, 18, 20, 32), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children.expand((item) => [item, const SizedBox(height: 16)]).toList()));
  Widget _header(String title, String subtitle) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: GoogleFonts.fredoka(fontSize: 27, fontWeight: FontWeight.w700, color: AppColors.textPrimary)), const SizedBox(height: 4), Text(subtitle, style: GoogleFonts.nunito(color: AppColors.textMuted))]);
  Widget _action(String title, String label, VoidCallback onPressed) => Row(children: [Expanded(child: Text(title, style: GoogleFonts.fredoka(fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),), ElevatedButton.icon(onPressed: onPressed, icon: const Icon(Icons.add, size: 17), label: Text(label))]);
  Widget _card(Widget child) => Container(width: double.infinity, padding: const EdgeInsets.all(17), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: child);
  Widget _empty(String title, String detail) => Row(children: [const Icon(Icons.add_circle_outline, color: AppColors.primary), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: GoogleFonts.nunito(fontWeight: FontWeight.w800)), Text(detail, style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textMuted))]))]);
  Widget _moduleRow(IconData icon, String title, String detail) => ListTile(contentPadding: EdgeInsets.zero, leading: CircleAvatar(backgroundColor: AppColors.primaryLight, child: Icon(icon, color: AppColors.primary)), title: Text(title, style: GoogleFonts.nunito(fontWeight: FontWeight.w800)), subtitle: Text(detail, style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textMuted)));
  Widget _placeholder(String title, String detail) => _scroll([_header(title, detail), _card(_empty('Module ready', 'Add your first record to begin.'))]);
  Color _color(String hex) { final value = int.tryParse(hex.replaceFirst('#', ''), radix: 16) ?? 0xFF7B1FA2; return Color(0xFF000000 | value); }

  void _form(String title, List<Widget> fields, VoidCallback save) => showDialog(context: context, builder: (dialogContext) => AlertDialog(title: Text(title, style: GoogleFonts.fredoka(fontWeight: FontWeight.w700)), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: fields)), actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')), ElevatedButton(onPressed: () { save(); Navigator.pop(dialogContext); }, child: const Text('Save'))]));

  void _addMember() { final name = TextEditingController(); final role = TextEditingController(); _form('Add family member', [TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')), TextField(controller: role, decoration: const InputDecoration(labelText: 'Role'))], () { if (name.text.trim().isEmpty) return; final list = StorageService.getMembers()..add(FamilyMember(name: name.text.trim(), role: role.text.trim().isEmpty ? 'Family member' : role.text.trim())); StorageService.saveMembers(list); setState(() {}); }); }
  void _addEvent() { final title = TextEditingController(); final date = TextEditingController(text: DateTime.now().toIso8601String().split('T').first); final notes = TextEditingController(); _form('Add family event', [TextField(controller: title, decoration: const InputDecoration(labelText: 'Event')), TextField(controller: date, decoration: const InputDecoration(labelText: 'Date')), TextField(controller: notes, decoration: const InputDecoration(labelText: 'Notes'))], () { if (title.text.trim().isEmpty) return; final list = StorageService.getEvents()..add(CalendarEvent(title: title.text.trim(), date: date.text.trim(), notes: notes.text.trim())); StorageService.saveEvents(list); setState(() {}); }); }
  void _addPet() { final name = TextEditingController(); final species = TextEditingController(text: 'Dog'); final breed = TextEditingController(); final birthday = TextEditingController(); _form('Add pet profile', [TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')), TextField(controller: species, decoration: const InputDecoration(labelText: 'Species')), TextField(controller: breed, decoration: const InputDecoration(labelText: 'Breed')), TextField(controller: birthday, decoration: const InputDecoration(labelText: 'Birthday (YYYY-MM-DD)'))], () { if (name.text.trim().isEmpty) return; final list = StorageService.getPets()..add(Pet(name: name.text.trim(), species: species.text.trim(), breed: breed.text.trim().isEmpty ? null : breed.text.trim(), birthday: birthday.text.trim().isEmpty ? null : birthday.text.trim())); StorageService.savePets(list); setState(() {}); }); }
  void _addNewbornLog() { final type = TextEditingController(text: 'Feeding'); final note = TextEditingController(); _form('Add newborn log', [TextField(controller: type, decoration: const InputDecoration(labelText: 'Log type')), TextField(controller: note, decoration: const InputDecoration(labelText: 'Details'))], () { final logs = StorageService.getFinanceItems('newbornLogs')..add({'type': type.text.trim(), 'note': note.text.trim(), 'date': DateTime.now().toIso8601String()}); StorageService.saveFinanceItems('newbornLogs', logs); setState(() {}); }); }
  Future<void> _openCalendar(String calendar) async { final uri = Uri.parse(calendar == 'Google Calendar' ? 'https://calendar.google.com/calendar/u/0/r' : 'calshow://'); await launchUrl(uri, mode: LaunchMode.externalApplication); }
}

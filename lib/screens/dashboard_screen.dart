import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import '../models/models.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _subIndex = 0;
  final _subPages = [
    'Overview',
    'Chores',
    'Finance',
    'Calendar',
    'Health',
    'Notifications'
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 72,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFF2D9E3))),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            itemCount: _subPages.length,
            itemBuilder: (ctx, i) => Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Center(
                child: ChoiceChip(
                  label: Text(_subPages[i]),
                  selected: _subIndex == i,
                  onSelected: (_) => setState(() => _subIndex = i),
                  showCheckmark: false,
                  selectedColor: AppColors.primary,
                  backgroundColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                  side: BorderSide.none,
                  shape: const StadiumBorder(),
                  labelStyle: TextStyle(
                    color:
                        _subIndex == i ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: _subIndex == 0
              ? _buildOverview()
              : _subIndex == 1
                  ? _buildChores()
                  : _subIndex == 2
                      ? _buildFinance()
                      : _subIndex == 3
                          ? _buildCalendar()
                          : _subIndex == 4
                              ? _buildHealth()
                              : _buildNotifications(),
        ),
      ],
    );
  }

  Widget _buildOverview() {
    final chores =
        StorageService.getChores().where((c) => c.status == 'pending').length;
    final members = StorageService.getMembers();
    final totalPoints = members.fold(0, (s, m) => s + m.points);
    final events = StorageService.getEvents();
    final income = StorageService.getIncome().fold(0.0, (s, i) => s + i.amount);
    final expenses =
        StorageService.getExpenses().fold(0.0, (s, e) => s + e.amount);
    final now = DateTime.now();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Dashboard",
                    style: GoogleFonts.fredoka(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_dayName(now.weekday)}, ${_monthName(now.month)} ${now.day}, ${now.year}',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 28),
          _statsRow([
            _statCard("Today's Tasks", '$chores', 'remaining'),
            _statCard(
                'Wallet Balance',
                '₱${(income - expenses).toStringAsFixed(2)}',
                'remaining this month',
                Colors.green,
                const Color(0xFFD9F1DC)),
            _statCard('Redeemable Points', '$totalPoints', 'pts available',
                Colors.orange, const Color(0xFFFFE7BD)),
            _statCard(
                'Upcoming Events',
                '${events.where((e) => _isUpcoming(e.date, now)).length}',
                'this week'),
          ]),
          const SizedBox(height: 32),
          _card('Cleaning Schedule', _cleaningGrid()),
          const SizedBox(height: 16),
          _card('Chore List', _choreList()),
          const SizedBox(height: 16),
          _card('Upcoming Events', _eventList()),
        ],
      ),
    );
  }

  Widget _buildChores() {
    final chores = StorageService.getChores();
    final pending = chores.where((c) => c.status == 'pending').length;
    final completed = chores.where((c) => c.status == 'completed').length;
    final members = StorageService.getMembers();
    final totalPoints = members.fold(0, (s, m) => s + m.points);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _statsRow([
            _statCard('Total', '${chores.length}', ''),
            _statCard('Completed', '$completed', '', Colors.green),
            _statCard('Pending', '$pending', '', Colors.orange),
            _statCard('Points', '$totalPoints', 'earned', Colors.purple),
          ]),
          const SizedBox(height: 16),
          _card('High Priority', _priorityChores(chores)),
        ],
      ),
    );
  }

  Widget _buildFinance() {
    final income = StorageService.getIncome().fold(0.0, (s, i) => s + i.amount);
    final expenses =
        StorageService.getExpenses().fold(0.0, (s, e) => s + e.amount);
    final pendingBills = StorageService.getBills()
        .where((b) => b.status == 'pending')
        .fold(0.0, (s, b) => s + b.amount);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _statsRow([
            _statCard(
                'Income', '₱${income.toStringAsFixed(0)}', '', Colors.green),
            _statCard(
                'Expenses', '₱${expenses.toStringAsFixed(0)}', '', Colors.red),
            _statCard(
                'Balance', '₱${(income - expenses).toStringAsFixed(0)}', ''),
            _statCard('Bills Due', '₱${pendingBills.toStringAsFixed(0)}', '',
                Colors.orange),
          ]),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Center(child: Text('Calendar View', style: GoogleFonts.nunito()));
  }

  Widget _buildHealth() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _card(
              'Health Reminders',
              Column(
                children: [
                  _healthItem(Icons.water_drop, 'Drink water', 'Every 2 hrs'),
                  _healthItem(
                      Icons.fitness_center, 'Stretch break', 'Every 1 hr'),
                  _healthItem(Icons.bedtime, 'Sleep by 10pm', 'Tonight'),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildNotifications() {
    return Center(
        child: Text('No new notifications',
            style: GoogleFonts.nunito(color: AppColors.textMuted)));
  }

  // Helpers
  String _dayName(int d) => [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
      ][d - 1];
  String _monthName(int m) => [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ][m - 1];

  Widget _statsRow(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 700) {
          return Wrap(
            spacing: 8,
            runSpacing: 12,
            children: children
                .map((child) => SizedBox(
                    width: (constraints.maxWidth - 8) / 2, child: child))
                .toList(),
          );
        }
        return Row(children: children.map((e) => Expanded(child: e)).toList());
      },
    );
  }

  Widget _statCard(String label, String value, String sub,
      [Color? valueColor, Color? backgroundColor]) {
    return _HoverTile(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        constraints: const BoxConstraints(minHeight: 150),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(),
                style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary)),
            const SizedBox(height: 6),
            Text(value,
                style: GoogleFonts.fredoka(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColors.textPrimary,
                )),
            if (sub.isNotEmpty)
              Text(sub,
                  style: GoogleFonts.nunito(
                      fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _card(String title, Widget child) {
    return _HoverTile(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: GoogleFonts.fredoka(
                    fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }

  Widget _cleaningGrid() {
    final chores =
        StorageService.getChores().where((c) => c.repeat != 'none').toList();
    if (chores.isEmpty) {
      return const Text('No cleaning tasks scheduled.',
          style: TextStyle(color: AppColors.textMuted));
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chores
          .take(4)
          .map((c) => Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.repeat.toUpperCase(),
                        style: GoogleFonts.fredoka(
                            fontSize: 11, color: AppColors.primary)),
                    Text(c.name, style: GoogleFonts.nunito(fontSize: 13)),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _choreList() {
    final chores = StorageService.getChores()
        .where((c) => c.status == 'pending')
        .take(5)
        .toList();
    if (chores.isEmpty) {
      return const Text('No chores assigned.',
          style: TextStyle(color: AppColors.textMuted));
    }
    return Column(
      children: chores.map((c) {
        final member = StorageService.getMembers()
            .where((m) => m.id == c.assigneeId)
            .firstOrNull;
        return ListTile(
          leading: CircleAvatar(
              backgroundColor: Color(
                  int.parse('0xFF${(member?.color ?? '#999').substring(1)}')),
              radius: 12),
          title: Text(c.name, style: GoogleFonts.nunito(fontSize: 14)),
          trailing: Text('${c.points} pts',
              style:
                  GoogleFonts.fredoka(fontSize: 12, color: AppColors.accent)),
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }

  Widget _eventList() {
    final events = StorageService.getEvents()
        .where((e) => _isUpcoming(e.date, DateTime.now()))
        .take(3)
        .toList();
    if (events.isEmpty) {
      return const Text('No upcoming events.',
          style: TextStyle(color: AppColors.textMuted));
    }
    return Column(
      children: events
          .map((e) => ListTile(
                leading: CircleAvatar(
                    backgroundColor:
                        Color(int.parse('0xFF${e.color.substring(1)}')),
                    radius: 8),
                title: Text(e.title, style: GoogleFonts.nunito(fontSize: 14)),
                subtitle: Text(_formatEventDate(e.date),
                    style: GoogleFonts.nunito(
                        fontSize: 12, color: AppColors.textMuted)),
                contentPadding: EdgeInsets.zero,
              ))
          .toList(),
    );
  }

  bool _isUpcoming(String date, DateTime now) {
    final parsedDate = DateTime.tryParse(date);
    return parsedDate != null && !parsedDate.isBefore(now);
  }

  String _formatEventDate(String date) {
    final parsedDate = DateTime.tryParse(date);
    if (parsedDate == null) return date;
    return '${_monthName(parsedDate.month)} ${parsedDate.day}, ${parsedDate.year}';
  }

  Widget _priorityChores(List<Chore> chores) {
    final high = chores
        .where((c) => c.priority == 'high' && c.status == 'pending')
        .toList();
    if (high.isEmpty) {
      return const Text('No high priority chores.',
          style: TextStyle(color: AppColors.textMuted));
    }
    return Column(
      children: high
          .map((c) => ListTile(
                title: Text(c.name, style: GoogleFonts.nunito()),
                trailing: Text(c.points.toString(),
                    style: GoogleFonts.fredoka(color: AppColors.overdue)),
                contentPadding: EdgeInsets.zero,
              ))
          .toList(),
    );
  }

  Widget _healthItem(IconData icon, String title, String time) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primaryLight,
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
      title: Text(title, style: GoogleFonts.nunito(fontSize: 14)),
      trailing: Text(time,
          style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textMuted)),
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _HoverTile extends StatefulWidget {
  const _HoverTile({required this.child});

  final Widget child;

  @override
  State<_HoverTile> createState() => _HoverTileState();
}

class _HoverTileState extends State<_HoverTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.025 : 1,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color:
                    AppColors.primary.withValues(alpha: _isHovered ? 0.16 : 0),
                blurRadius: _isHovered ? 18 : 0,
                spreadRadius: _isHovered ? 1 : 0,
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

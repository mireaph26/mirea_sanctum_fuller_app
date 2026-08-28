import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/storage_service.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  int _subIndex = 0;
  int _overviewPeriod = 0;
  int _periodOffset = 0;
  final _subPages = [
    'Overview',
    'Scheduled Payments',
    'Budget',
    'Daily Tracker',
    'Accounts',
    'Categories',
    'Savings',
    'Sinking Funds',
    'Emergency & Debt Funds',
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
          child: _buildPage(),
        ),
      ],
    );
  }

  Widget _buildPage() {
    switch (_subIndex) {
      case 1:
        return _buildScheduledPayments();
      case 2:
        return _buildBudget();
      case 3:
        return _buildDailyTracker();
      case 4:
        return _buildAccounts();
      case 5:
        return _buildCategories();
      case 6:
        return _buildSavings();
      case 7:
        return _buildFundPage('Sinking Funds',
            'Set aside money for planned occasions and purchases.');
      case 8:
        return _buildFundPage('Emergency & Debt Funds',
            'Separate emergency reserves from debt repayments.');
      case 9:
        return _buildInflow();
      case 10:
        return _buildOutflow();
      default:
        return _buildOverview();
    }
  }

  Widget _buildOverview() {
    final income = StorageService.getIncome();
    final expenses = StorageService.getExpenses();
    final selectedIncome = income.where(_inSelectedPeriod).toList();
    final selectedExpenses = expenses.where(_expenseInSelectedPeriod).toList();
    final incomeTotal = selectedIncome.fold(0.0, (sum, item) => sum + item.amount);
    final expenseTotal = selectedExpenses.fold(0.0, (sum, item) => sum + item.amount);
    final savings = StorageService.getSavings();
    final savedTotal = savings.fold(0.0, (sum, item) => sum + item.current);

    return _pageScroll(
      children: [
        _pageHeader('Finance Overview', 'Your household money at a glance'),
        _periodTabs(),
        _periodNavigator(),
        _summaryGrid([
          _summaryCard(
              'Money Inflow',
              _money(incomeTotal),
              '${income.length} income source${income.length == 1 ? '' : 's'}',
              Colors.green),
          _summaryCard(
              'Money Outflow',
              _money(expenseTotal),
              '${expenses.length} expense${expenses.length == 1 ? '' : 's'}',
              Colors.red),
          _summaryCard('Available Balance', _money(incomeTotal - expenseTotal),
              'inflow minus outflow', AppColors.primary),
          _summaryCard(
              'Savings Progress',
              _money(savedTotal),
              '${savings.length} active goal${savings.length == 1 ? '' : 's'}',
              Colors.orange),
        ]),
              _cashflowChart(incomeTotal, expenseTotal),
              _addTransactionButton(),
        _moduleCard('Track every part of your plan', [
          _moduleRow(Icons.calendar_month, 'Monthly overview',
              'Review recurring income, expenses, and bills.'),
          _moduleRow(Icons.event_note, 'Yearly overview',
              'See the bigger picture across all twelve months.'),
          _moduleRow(Icons.view_week, 'Weekly overview',
              'Check what is coming up and adjust your spending.'),
          _moduleRow(Icons.today, 'Daily finance tracker',
              'Record today\'s money in and money out.'),
        ]),
      ],
    );
  }

  Widget _buildInflow() {
    final items = StorageService.getIncome();
    return _pageScroll(children: [
      _pageHeader(
          'Money Inflow', 'Rename income sources and track what comes in'),
      _sectionCard(
          'Income sources',
          items.isEmpty
              ? _emptyState('No income sources yet',
                  'Add Salary, freelance work, or another inflow.')
              : Column(
                  children: items
                      .map((item) => _financeRow(
                          Icons.arrow_downward,
                          item.source,
                          item.frequency,
                          item.amount,
                          Colors.green))
                      .toList())),
    ]);
  }

  Widget _buildScheduledPayments() {
    final bills = StorageService.getBills();
    return _pageScroll(children: [
      _pageHeader('Scheduled Payments', 'Bills, reminders, repetitions, and due dates'),
      Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton.icon(
          onPressed: _showAddBill,
          icon: const Icon(Icons.add),
          label: const Text('Add payment'),
        ),
      ),
      _sectionCard(
        'Bills',
        bills.isEmpty
            ? _emptyState('No scheduled payments', 'Add electricity, water, internet, or another bill.')
            : Column(children: bills.map((bill) => _billTile(bill)).toList()),
      ),
    ]);
  }

  Widget _billTile(Bill bill) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: AppColors.pending.withValues(alpha: .14),
        child: const Icon(Icons.event_repeat, color: AppColors.pending),
      ),
      title: Text(bill.name, style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
      subtitle: Text('Due ${bill.dueDate} · Repeats ${bill.repeat}',
          style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textMuted)),
      trailing: Text(_money(bill.amount),
          style: GoogleFonts.fredoka(fontSize: 16, color: AppColors.pending)),
    );
  }

  Widget _buildBudget() {
    final budgets = StorageService.getFinanceItems('financeBudgets');
    return _pageScroll(children: [
      _pageHeader('Budget', 'Set limits by time period and spending category'),
      Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton.icon(
          onPressed: _showAddBudget,
          icon: const Icon(Icons.add),
          label: const Text('Create budget'),
        ),
      ),
      _sectionCard(
        'Your budgets',
        budgets.isEmpty
            ? _emptyState('No budgets yet', 'Create a category limit for the month or year.')
            : Column(children: budgets.map((budget) {
                final amount = (budget['amount'] as num?)?.toDouble() ?? 0;
                return _financeRow(Icons.pie_chart_outline, budget['name']?.toString() ?? 'Budget',
                    '${budget['period'] ?? 'Monthly'} · ${budget['category'] ?? 'All categories'}', amount, AppColors.primary);
              }).toList()),
      ),
    ]);
  }

  Widget _buildDailyTracker() {
    final selectedDate = DateTime.now().add(Duration(days: _periodOffset));
    final day = selectedDate.toIso8601String().split('T').first;
    final incomes = StorageService.getIncome().where((item) => item.date == day).toList();
    final expenses = StorageService.getExpenses().where((item) => item.date == day).toList();
    final inTotal = incomes.fold(0.0, (sum, item) => sum + item.amount);
    final outTotal = expenses.fold(0.0, (sum, item) => sum + item.amount);
    return _pageScroll(children: [
      _pageHeader('Operations', 'Review and add your daily money flow'),
      _dayNavigator(),
      _summaryGrid([
        _summaryCard('Spent today', _money(outTotal), '${expenses.length} entries', Colors.red),
        _summaryCard('Received today', _money(inTotal), '${incomes.length} entries', Colors.green),
        _summaryCard('Net today', _money(inTotal - outTotal), 'money in minus out', AppColors.primary),
      ]),
      _addTransactionButton(initialDate: day),
      _sectionCard('Today\'s activity', Column(
        children: [
          ...incomes.map((item) => _financeRow(Icons.arrow_downward, item.source, 'Money in', item.amount, Colors.green)),
          ...expenses.map((item) => _financeRow(Icons.arrow_upward, item.name, item.category, item.amount, Colors.red)),
          if (incomes.isEmpty && expenses.isEmpty) _emptyState('Nothing recorded today', 'Add your first transaction above.'),
        ],
      )),
    ]);
  }

  Widget _dayNavigator() {
    final date = DateTime.now().add(Duration(days: _periodOffset));
    final label = '${_monthName(date.month)} ${date.day}, ${date.year}';
    return Row(
      children: [
        IconButton(
          tooltip: 'Previous day',
          onPressed: () => setState(() => _periodOffset--),
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Center(
            child: Text(label,
                style: GoogleFonts.fredoka(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ),
        ),
        IconButton(
          tooltip: 'Next day',
          onPressed: () => setState(() => _periodOffset++),
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _buildAccounts() {
    final accounts = StorageService.getFinanceItems('financeAccounts');
    return _pageScroll(children: [
      _pageHeader('Accounts', 'Organize cash, e-wallets, and money transfers'),
      Align(alignment: Alignment.centerRight, child: ElevatedButton.icon(onPressed: _showAddAccount, icon: const Icon(Icons.add), label: const Text('Add account'))),
      _sectionCard('Money accounts', accounts.isEmpty
          ? _emptyState('No accounts yet', 'Add Cash, bank, or an e-wallet account.')
          : Column(children: accounts.map((item) => _financeRow(Icons.account_balance_wallet, item['name']?.toString() ?? 'Account', item['type']?.toString() ?? 'Account', (item['amount'] as num?)?.toDouble() ?? 0, AppColors.primary)).toList())),
    ]);
  }

  Widget _buildCategories() {
    final categories = StorageService.getFinanceItems('financeCategories');
    return _pageScroll(children: [
      _pageHeader('Categories', 'Choose a category for every money flow'),
      Align(alignment: Alignment.centerRight, child: ElevatedButton.icon(onPressed: _showAddCategory, icon: const Icon(Icons.add), label: const Text('Add category'))),
      _categoryGrid(categories),
    ]);
  }

  Widget _categoryGrid(List<Map<String, dynamic>> customCategories) {
    final categories = <Map<String, dynamic>>[
      {'name': 'Sari-sari Store', 'icon': Icons.point_of_sale, 'color': const Color(0xFF9B5DE5)},
      {'name': 'Meal', 'icon': Icons.restaurant, 'color': const Color(0xFFB7B66A)},
      {'name': 'Palengke', 'icon': Icons.shopping_basket, 'color': const Color(0xFFA44CC4)},
      {'name': 'Grocery', 'icon': Icons.shopping_cart, 'color': const Color(0xFFB73CDE)},
      {'name': 'Luho', 'icon': Icons.local_drink, 'color': const Color(0xFFE8792E)},
      {'name': 'Entertainments', 'icon': Icons.movie, 'color': const Color(0xFF5669E8)},
      {'name': 'Transport', 'icon': Icons.directions_bus, 'color': const Color(0xFF168AD1)},
      {'name': 'General', 'icon': Icons.spa, 'color': const Color(0xFF70905D)},
      {'name': 'Pets', 'icon': Icons.pets, 'color': const Color(0xFF77AD54)},
      {'name': 'Family', 'icon': Icons.group, 'color': const Color(0xFFE4512B)},
      {'name': 'Bills', 'icon': Icons.lightbulb_outline, 'color': const Color(0xFFF5B522)},
      {'name': 'Food Staple', 'icon': Icons.local_dining, 'color': const Color(0xFF63A77D)},
      ...customCategories.map((item) => {
            'name': item['name']?.toString() ?? 'Custom',
            'icon': Icons.label_outline,
            'color': AppColors.primary,
          }),
    ];
    return _sectionCard('Expense categories', LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 500 ? 2 : 3;
        final width = (constraints.maxWidth - ((columns - 1) * 10)) / columns;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: categories.map((item) => SizedBox(
            width: width,
            child: InkWell(
              onTap: () => _showAddTransaction(initialCategory: item['name'] as String),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE1DCE8)),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(children: [
                  CircleAvatar(
                    radius: 19,
                    backgroundColor: (item['color'] as Color).withValues(alpha: .12),
                    child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 19),
                  ),
                  const SizedBox(width: 9),
                  Expanded(child: Text(item['name'] as String, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700))),
                ]),
              ),
            ),
          )).toList(),
        );
      },
    ));
  }

  Widget _buildOutflow() {
    final items = StorageService.getExpenses();
    final fixed = items.where((item) => item.type == 'fixed').toList();
    final variable = items.where((item) => item.type != 'fixed').toList();
    return _pageScroll(children: [
      _pageHeader(
          'Money Outflow', 'See fixed and variable expenses separately'),
      _sectionCard('Fixed Expenses',
          _expenseGroup(fixed, 'No fixed expenses recorded.')),
      _sectionCard('Variable Expenses',
          _expenseGroup(variable, 'No variable expenses recorded.')),
      _sectionCard('Bills', _billGroup()),
    ]);
  }

  Widget _buildSavings() {
    final items = StorageService.getSavings();
    return _pageScroll(children: [
      _pageHeader('Savings', 'Rename goals and organize them by timeline'),
      _sectionCard(
          'Savings goals',
          items.isEmpty
              ? _emptyState('No savings goals yet',
                  'Add long-term and short-term targets.')
              : Column(
                  children: items.map((item) => _savingsRow(item)).toList())),
      _moduleCard('Suggested categories', [
        _moduleRow(Icons.hourglass_top, 'Long term',
            'College, a home, or another distant target.'),
        _moduleRow(Icons.flag, 'Short term',
            'Near-term purchases and upcoming priorities.'),
        _moduleRow(Icons.event, 'Target date',
            'Keep a deadline visible for every goal.'),
      ]),
    ]);
  }

  Widget _buildFundPage(String title, String subtitle) {
    return _pageScroll(children: [
      _pageHeader(title, subtitle),
      _sectionCard(
          title,
          _emptyState('No funds created yet',
              'Add a fund and categorize it so it is easy to manage.')),
      _moduleCard('Examples to get started', [
        _moduleRow(
            Icons.card_giftcard,
            title == 'Sinking Funds' ? 'Birthday' : 'Medical Crisis',
            title == 'Sinking Funds' ? 'Planned occasion' : 'Emergency'),
        _moduleRow(
            Icons.account_balance,
            title == 'Sinking Funds' ? 'Travel' : 'Bank Loan',
            title == 'Sinking Funds' ? 'Planned purchase' : 'Debt'),
      ]),
    ]);
  }

  Widget _pageScroll({required List<Widget> children}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children
            .expand((child) => [child, const SizedBox(height: 20)])
            .toList(),
      ),
    );
  }

  Widget _pageHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: GoogleFonts.fredoka(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        Text(subtitle, style: GoogleFonts.nunito(color: AppColors.textMuted)),
      ],
    );
  }

  Widget _periodTabs() {
    const periods = ['Monthly', 'Yearly', 'Weekly', 'Daily'];
    return Wrap(
      spacing: 8,
      children: List.generate(
        periods.length,
        (index) => ChoiceChip(
          label: Text(periods[index]),
          selected: _overviewPeriod == index,
          onSelected: (_) => setState(() => _overviewPeriod = index),
          showCheckmark: false,
          selectedColor: AppColors.primary,
          backgroundColor: Colors.white,
          side: const BorderSide(color: AppColors.border),
          labelStyle: TextStyle(
              color: _overviewPeriod == index
                  ? Colors.white
                  : AppColors.textSecondary,
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _periodNavigator() {
    return Row(
      children: [
        IconButton(
          tooltip: 'Previous period',
          onPressed: () => setState(() => _periodOffset--),
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Center(
            child: Text(
              _selectedPeriodLabel(),
              style: GoogleFonts.fredoka(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary),
            ),
          ),
        ),
        IconButton(
          tooltip: 'Next period',
          onPressed: () => setState(() => _periodOffset++),
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  String _selectedPeriodLabel() {
    final now = DateTime.now();
    if (_overviewPeriod == 0) {
      final date = DateTime(now.year, now.month + _periodOffset);
      return '${_monthName(date.month)} ${date.year}';
    }
    if (_overviewPeriod == 1) return '${now.year + _periodOffset}';
    if (_overviewPeriod == 2) {
      final date = now.add(Duration(days: _periodOffset * 7));
      final start = date.subtract(Duration(days: date.weekday - 1));
      final end = start.add(const Duration(days: 6));
      return '${_monthName(start.month)} ${start.day} - ${_monthName(end.month)} ${end.day}';
    }
    return '${_monthName(now.month)} ${now.day + _periodOffset}, ${now.year}';
  }

  bool _inSelectedPeriod(Income item) => _dateInSelectedPeriod(item.date);
  bool _expenseInSelectedPeriod(Expense item) => _dateInSelectedPeriod(item.date);

  bool _dateInSelectedPeriod(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) return false;
    final now = DateTime.now();
    if (_overviewPeriod == 0) {
      final target = DateTime(now.year, now.month + _periodOffset);
      return date.year == target.year && date.month == target.month;
    }
    if (_overviewPeriod == 1) return date.year == now.year + _periodOffset;
    if (_overviewPeriod == 2) {
      final shifted = now.add(Duration(days: _periodOffset * 7));
      final start = DateTime(shifted.year, shifted.month, shifted.day)
          .subtract(Duration(days: shifted.weekday - 1));
      final end = start.add(const Duration(days: 7));
      return !date.isBefore(start) && date.isBefore(end);
    }
    final target = now.add(Duration(days: _periodOffset));
    return date.year == target.year && date.month == target.month && date.day == target.day;
  }

  String _monthName(int month) => const [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ][month - 1];

  Widget _cashflowChart(double income, double expenses) {
    final maxValue = [income, expenses, 1].reduce((a, b) => a > b ? a : b);
    return _sectionCard('Cash flow', SizedBox(
      height: 190,
      child: BarChart(
        BarChartData(
          maxY: maxValue * 1.25,
          minY: 0,
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    value == 0 ? 'Money in' : 'Money out',
                    style: GoogleFonts.nunito(fontSize: 11, color: AppColors.textMuted),
                  ),
                ),
              ),
            ),
          ),
          barGroups: [
            _barGroup(0, income, Colors.green),
            _barGroup(1, expenses, Colors.red),
          ],
        ),
      ),
    ));
  }

  BarChartGroupData _barGroup(int index, double amount, Color color) {
    return BarChartGroupData(
      x: index,
      barRods: [
        BarChartRodData(
          toY: amount,
          width: 42,
          color: color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        ),
      ],
    );
  }

  Widget _addTransactionButton({String? initialDate}) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.add, size: 18),
        label: Text('Add transaction', style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
        onPressed: () => _showAddTransaction(initialDate: initialDate),
      ),
    );
  }

  Widget _summaryGrid(List<Widget> cards) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900 ? 4 : 2;
        final width = (constraints.maxWidth - ((columns - 1) * 12)) / columns;
        return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: cards
                .map((card) => SizedBox(width: width, child: card))
                .toList());
      },
    );
  }

  Widget _summaryCard(String label, String value, String detail, Color color) {
    return Container(
      constraints: const BoxConstraints(minHeight: 136),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color == Colors.green
            ? const Color(0xFFD9F1DC)
            : color == Colors.orange
                ? const Color(0xFFFFE7BD)
                : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 8)
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(),
            style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary)),
        const SizedBox(height: 12),
        Text(value,
            style: GoogleFonts.fredoka(
                fontSize: 25, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 6),
        Text(detail,
            style:
                GoogleFonts.nunito(fontSize: 11, color: AppColors.textMuted)),
      ]),
    );
  }

  Widget _sectionCard(String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: GoogleFonts.fredoka(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        const SizedBox(height: 14),
        child,
      ]),
    );
  }

  Widget _moduleCard(String title, List<Widget> children) {
    return _sectionCard(title, Column(children: children));
  }

  Widget _moduleRow(IconData icon, String title, String detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(children: [
        CircleAvatar(
            backgroundColor: AppColors.primaryLight,
            radius: 17,
            child: Icon(icon, size: 17, color: AppColors.primary)),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
          Text(detail,
              style:
                  GoogleFonts.nunito(fontSize: 12, color: AppColors.textMuted)),
        ])),
      ]),
    );
  }

  Widget _financeRow(
      IconData icon, String title, String detail, double amount, Color color) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: .12),
          child: Icon(icon, color: color, size: 18)),
      title:
          Text(title, style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
      subtitle: Text(detail,
          style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textMuted)),
      trailing: Text(_money(amount),
          style: GoogleFonts.fredoka(
              fontSize: 17, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Widget _expenseGroup(List<Expense> items, String emptyMessage) {
    if (items.isEmpty) {
      return _emptyState(emptyMessage, 'Record an expense to see it here.');
    }
    return Column(
        children: items
            .map((item) => _financeRow(Icons.arrow_upward, item.name,
                item.category, item.amount, Colors.red))
            .toList());
  }

  Widget _billGroup() {
    final bills = StorageService.getBills();
    if (bills.isEmpty) {
      return _emptyState(
          'No bills recorded.', 'Add recurring bills to keep them visible.');
    }
    return Column(
        children: bills
            .map((bill) => _financeRow(Icons.receipt_long, bill.name,
                'Due ${bill.dueDate}', bill.amount, Colors.orange))
            .toList());
  }

  void _showAddBill() {
    final name = TextEditingController();
    final amount = TextEditingController();
    final dueDate = TextEditingController(text: DateTime.now().toIso8601String().split('T').first);
    String repeat = 'Monthly';
    _showFinanceForm(
      title: 'Add scheduled payment',
      fields: [
        _FinanceField('Name', name, hint: 'Electric Bill'),
        _FinanceField('Amount', amount, hint: '0.00', number: true),
        _FinanceField('Due date', dueDate, hint: 'YYYY-MM-DD'),
      ],
      extra: DropdownButtonFormField<String>(
        initialValue: repeat,
        decoration: const InputDecoration(labelText: 'Repeat'),
        items: const ['Never', 'Weekly', 'Monthly', 'Yearly']
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: (value) => repeat = value ?? 'Monthly',
      ),
      onSave: () {
        final value = double.tryParse(amount.text.trim());
        if (name.text.trim().isEmpty || value == null || value <= 0) return false;
        final bills = StorageService.getBills();
        bills.add(Bill(name: name.text.trim(), amount: value, dueDate: dueDate.text.trim(), repeat: repeat.toLowerCase()));
        StorageService.saveBills(bills);
        setState(() {});
        return true;
      },
    );
  }

  void _showAddBudget() {
    final name = TextEditingController();
    final amount = TextEditingController();
    final category = TextEditingController();
    String period = 'Monthly';
    _showFinanceForm(
      title: 'Create budget',
      fields: [
        _FinanceField('Budget name', name, hint: 'Household food'),
        _FinanceField('Amount', amount, hint: '0.00', number: true),
        _FinanceField('Category or subcategory', category, hint: 'Food'),
      ],
      extra: DropdownButtonFormField<String>(
        initialValue: period,
        decoration: const InputDecoration(labelText: 'Time period'),
        items: const ['Weekly', 'Monthly', 'Yearly']
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: (value) => period = value ?? 'Monthly',
      ),
      onSave: () {
        final value = double.tryParse(amount.text.trim());
        if (name.text.trim().isEmpty || value == null || value <= 0) return false;
        final budgets = StorageService.getFinanceItems('financeBudgets');
        budgets.add({'name': name.text.trim(), 'amount': value, 'category': category.text.trim(), 'period': period});
        StorageService.saveFinanceItems('financeBudgets', budgets);
        setState(() {});
        return true;
      },
    );
  }

  void _showAddAccount() {
    final name = TextEditingController();
    final amount = TextEditingController();
    String type = 'Cash';
    _showFinanceForm(
      title: 'Add account',
      fields: [
        _FinanceField('Account name', name, hint: 'Cash or E-wallet'),
        _FinanceField('Starting balance', amount, hint: '0.00', number: true),
      ],
      extra: DropdownButtonFormField<String>(
        initialValue: type,
        decoration: const InputDecoration(labelText: 'Account type'),
        items: const ['Cash', 'E-wallet', 'Bank', 'Other']
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: (value) => type = value ?? 'Cash',
      ),
      onSave: () {
        final value = double.tryParse(amount.text.trim()) ?? 0;
        if (name.text.trim().isEmpty) return false;
        final accounts = StorageService.getFinanceItems('financeAccounts');
        accounts.add({'name': name.text.trim(), 'amount': value, 'type': type});
        StorageService.saveFinanceItems('financeAccounts', accounts);
        setState(() {});
        return true;
      },
    );
  }

  void _showAddCategory() {
    final name = TextEditingController();
    final subcategory = TextEditingController();
    String type = 'Expense';
    _showFinanceForm(
      title: 'Add category',
      fields: [
        _FinanceField('Category name', name, hint: 'Household'),
        _FinanceField('Subcategory', subcategory, hint: 'Optional'),
      ],
      extra: DropdownButtonFormField<String>(
        initialValue: type,
        decoration: const InputDecoration(labelText: 'Money flow type'),
        items: const ['Income', 'Expense']
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: (value) => type = value ?? 'Expense',
      ),
      onSave: () {
        if (name.text.trim().isEmpty) return false;
        final categories = StorageService.getFinanceItems('financeCategories');
        categories.add({'name': name.text.trim(), 'subcategory': subcategory.text.trim(), 'type': type});
        StorageService.saveFinanceItems('financeCategories', categories);
        setState(() {});
        return true;
      },
    );
  }

  void _showFinanceForm({
    required String title,
    required List<_FinanceField> fields,
    required bool Function() onSave,
    Widget? extra,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title, style: GoogleFonts.fredoka(fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...fields.map((field) => TextField(
                    controller: field.controller,
                    keyboardType: field.number ? const TextInputType.numberWithOptions(decimal: true) : null,
                    decoration: InputDecoration(labelText: field.label, hintText: field.hint),
                  )),
              if (extra != null) ...[const SizedBox(height: 12), extra],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (onSave()) Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _savingsRow(SavingsGoal item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text(item.name,
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w700))),
          Text('${(item.progress * 100).round()}%',
              style: GoogleFonts.fredoka(color: AppColors.primary)),
        ]),
        const SizedBox(height: 7),
        ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
                value: item.progress,
                minHeight: 9,
                color: AppColors.primaryLight,
                backgroundColor: AppColors.border)),
        const SizedBox(height: 4),
        Text(
            '${_money(item.current)} of ${_money(item.target)} · ${item.type == 'long' ? 'Long term' : 'Short term'}${item.date == null ? '' : ' · ${item.date}'}',
            style:
                GoogleFonts.nunito(fontSize: 11, color: AppColors.textMuted)),
      ]),
    );
  }

  Widget _emptyState(String title, String detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        const Icon(Icons.add_circle_outline, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
          Text(detail,
              style:
                  GoogleFonts.nunito(fontSize: 12, color: AppColors.textMuted)),
        ])),
      ]),
    );
  }

  void _showAddTransaction({String? initialCategory, String? initialDate}) {
      final nameController = TextEditingController();
      final amountController = TextEditingController();
    final noteController = TextEditingController();
      String transactionType = 'expense';
      String category = initialCategory ?? 'Other';
    String? account;
      String? errorText;

      showDialog(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (dialogContext, setDialogState) => AlertDialog(
            title: Text('Add transaction', style: GoogleFonts.fredoka(
                fontSize: 22, fontWeight: FontWeight.w700)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'expense', label: Text('Money out'), icon: Icon(Icons.arrow_upward)),
                      ButtonSegment(value: 'income', label: Text('Money in'), icon: Icon(Icons.arrow_downward)),
                    ],
                    selected: {transactionType},
                    onSelectionChanged: (value) => setDialogState(() => transactionType = value.first),
                  ),
                  const SizedBox(height: 18),
                  DropdownButtonFormField<String>(
                    initialValue: account,
                    decoration: const InputDecoration(
                      labelText: 'Account',
                      hintText: 'Cash or E-wallet',
                    ),
                    items: [
                      const DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                      ...StorageService.getFinanceItems('financeAccounts').map(
                        (item) => DropdownMenuItem(
                          value: item['name']?.toString(),
                          child: Text(item['name']?.toString() ?? 'Account'),
                        ),
                      ),
                    ],
                    onChanged: (value) => setDialogState(() => account = value),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name', hintText: 'e.g., Groceries'),
                  ),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Amount', prefixText: '₱ '),
                  ),
                  const SizedBox(height: 10),
                  _numberPad(amountController, setDialogState),
                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(
                      labelText: 'Note',
                      hintText: 'Optional note',
                    ),
                  ),
                  if (transactionType == 'expense') ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: <String>{category, 'Food', 'Bills', 'Transport', 'Shopping', 'Health', 'Other'}.toList()
                          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                          .toList(),
                      onChanged: (value) => setDialogState(() => category = value ?? 'Other'),
                    ),
                  ],
                  if (errorText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(errorText!, style: const TextStyle(color: AppColors.overdue)),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(amountController.text.trim());
                  if (nameController.text.trim().isEmpty || amount == null || amount <= 0) {
                    setDialogState(() => errorText = 'Enter a name and a valid amount.');
                    return;
                  }
                  final date = initialDate ?? DateTime.now().toIso8601String().split('T').first;
                  if (transactionType == 'income') {
                    final items = StorageService.getIncome();
                    items.add(Income(
                      source: nameController.text.trim(),
                      amount: amount,
                      date: date,
                      notes: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
                    ));
                    StorageService.saveIncome(items);
                  } else {
                    final items = StorageService.getExpenses();
                    items.add(Expense(
                      name: nameController.text.trim(),
                      amount: amount,
                      date: date,
                      category: category.toLowerCase(),
                      notes: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
                    ));
                    StorageService.saveExpenses(items);
                  }
                  Navigator.pop(dialogContext);
                  setState(() {});
                },
                child: const Text('Save transaction'),
              ),
            ],
          ),
        ),
      );
  }

  Widget _numberPad(
      TextEditingController controller, StateSetter setDialogState) {
    final keys = ['÷', '7', '8', '9', '×', '4', '5', '6', '-', '1', '2', '3', '+', '₱', '0', '.', '⌫'];
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
      childAspectRatio: 1.8,
      children: keys.map((key) {
        final isAction = key == '⌫';
        return OutlinedButton(
          onPressed: () {
            if (key == '⌫') {
              if (controller.text.isNotEmpty) {
                controller.text = controller.text.substring(0, controller.text.length - 1);
              }
            } else if (RegExp(r'^[0-9.]$').hasMatch(key)) {
              controller.text += key;
            }
            setDialogState(() {});
          },
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.zero,
            foregroundColor: isAction ? AppColors.overdue : AppColors.textPrimary,
            side: const BorderSide(color: AppColors.border),
          ),
          child: Text(key, style: GoogleFonts.fredoka(fontSize: 15, fontWeight: FontWeight.w700)),
        );
      }).toList(),
    );
  }

  String _money(double amount) => '₱${amount.toStringAsFixed(2)}';
}

class _FinanceField {
  const _FinanceField(this.label, this.controller, {this.hint, this.number = false});
  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool number;
}

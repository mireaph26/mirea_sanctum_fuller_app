import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class LifestyleScreen extends StatefulWidget {
  const LifestyleScreen({super.key});

  @override
  State<LifestyleScreen> createState() => _LifestyleScreenState();
}

class _LifestyleScreenState extends State<LifestyleScreen> {
  int _subIndex = 0;
  final _subPages = ['Personal', 'Habits', 'Meals', 'Creations'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _subPages.length,
            itemBuilder: (ctx, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(_subPages[i]),
                selected: _subIndex == i,
                onSelected: (_) => setState(() => _subIndex = i),
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: _subIndex == i ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Text(_subPages[_subIndex], style: GoogleFonts.fredoka(fontSize: 18, color: AppColors.textMuted)),
          ),
        ),
      ],
    );
  }
}

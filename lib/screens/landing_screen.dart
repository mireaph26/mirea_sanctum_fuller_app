import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import 'main_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.background,
              Color(0xFFF3E8FF),
              Color(0xFFE8F0FE)
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset('assets/logo.png',
                                width: 40, height: 40),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Mirea Sanctum',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.dancingScript(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () => _showLoginDialog(context),
                      child: const Text('Sign in'),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = MediaQuery.sizeOf(context).width >= 900;
                      final titleSize = isWide ? 48.0 : 34.0;
                      final content = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white70,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: Colors.purple.shade100),
                            ),
                            child: Text(
                              'HOUSEHOLD OS · PARENT · TEEN · CHILD',
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            'The heart of magic,\nyour family\'s digital sanctuary',
                            style: GoogleFonts.fredoka(
                              fontSize: titleSize,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF4B2C5E),
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'A family hub that grows with you',
                            style: GoogleFonts.fredoka(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF9A6FB3),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Track finances, split bills, assign chores, and celebrate wins together. Roles for parents, teens, and children keep everyone in their lane — while the whole family stays in the loop.',
                            style: GoogleFonts.nunito(
                              fontSize: 15,
                              color: const Color(0xFF4B2C5E),
                              height: 1.7,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Harmony at home, powered by MireaPh',
                            style: GoogleFonts.fredoka(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF4B2C5E),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Wrap(
                            spacing: 16,
                            runSpacing: 12,
                            children: [
                              ElevatedButton(
                                onPressed: () => _showRegisterDialog(context),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 18),
                                ),
                                child: const Text('Create our household'),
                              ),
                              OutlinedButton(
                                onPressed: () => _showLoginDialog(context),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 18),
                                ),
                                child: const Text('I have an invite code'),
                              ),
                            ],
                          ),
                        ],
                      );
                      final preview = Container(
                        width: double.infinity,
                        height: 270,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F0FF),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.purple.shade100, blurRadius: 30)
                          ],
                        ),
                        child: _buildDevicePreview(),
                      );
                      if (!isWide) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            content,
                            const SizedBox(height: 32),
                            preview
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(child: content),
                          const SizedBox(width: 48),
                          Expanded(child: preview),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDevicePreview() {
    return Stack(
      children: [
        Positioned(
          left: 18,
          right: 48,
          bottom: 18,
          height: 202,
          child: _buildLaptop(),
        ),
        Positioned(
          top: 22,
          right: 18,
          bottom: 12,
          width: 92,
          child: _buildPhone(),
        ),
      ],
    );
  }

  Widget _buildLaptop() {
    return Column(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFF3D3150),
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(color: Color(0x332D004B), blurRadius: 12),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              child: _buildLaptopScreen(),
            ),
          ),
        ),
        Container(
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: const Color(0xFFB5A8C5),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildLaptopScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Icon(Icons.auto_awesome, size: 10, color: Colors.white),
            ),
            const SizedBox(width: 5),
            Text(
              'Mirea Sanctum',
              style: GoogleFonts.fredoka(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            const Icon(Icons.notifications_none, size: 13, color: AppColors.textMuted),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Good morning, family',
          style: GoogleFonts.fredoka(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 7),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _miniFeatureCard('3', 'Tasks left', const Color(0xFFFFE8BD))),
              const SizedBox(width: 6),
              Expanded(child: _miniFeatureCard('₱12.4k', 'Wallet', const Color(0xFFDDF3E2))),
              const SizedBox(width: 6),
              Expanded(child: _miniFeatureCard('86%', 'Harmony', const Color(0xFFFDE0EA))),
            ],
          ),
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            Expanded(child: _miniList('Kitchen reset', 'Completed', AppColors.paid)),
            const SizedBox(width: 12),
            Expanded(child: _miniList('Family dinner', 'Tonight, 7:00 PM', AppColors.primary)),
          ],
        ),
      ],
    );
  }

  Widget _buildPhone() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFF30253D),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x442D004B), blurRadius: 14, offset: Offset(0, 8)),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9FF),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 24,
                height: 3,
                decoration: BoxDecoration(
                  color: const Color(0xFFB5A8C5),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 11),
            Text('My space', style: GoogleFonts.fredoka(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            _phoneTile(Icons.check_circle, 'Chores', '2 done', AppColors.paid),
            const SizedBox(height: 5),
            _phoneTile(Icons.account_balance_wallet, 'Wallet', '₱420', AppColors.primary),
            const SizedBox(height: 5),
            _phoneTile(Icons.favorite, 'Wellbeing', 'Great', AppColors.accent),
            const Spacer(),
            const Divider(height: 10),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(Icons.home_filled, size: 13, color: AppColors.primary),
                Icon(Icons.calendar_month, size: 13, color: AppColors.textMuted),
                Icon(Icons.person_outline, size: 13, color: AppColors.textMuted),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniFeatureCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.fredoka(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.nunito(fontSize: 7, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _miniList(String title, String detail, Color color) {
    return Row(
      children: [
        Icon(Icons.circle, size: 7, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.nunito(fontSize: 8, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              Text(detail, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.nunito(fontSize: 7, color: AppColors.textMuted)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _phoneTile(IconData icon, String title, String detail, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Row(
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.nunito(fontSize: 7, fontWeight: FontWeight.w800, color: AppColors.textPrimary))),
          Text(detail, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.nunito(fontSize: 6, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  void _showLoginDialog(BuildContext context) {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String? errorText;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 430,
              maxHeight: MediaQuery.sizeOf(ctx).height * 0.92,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 22, 28, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'Welcome back',
                          style: GoogleFonts.fredoka(
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(ctx),
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE2EC),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Icon(Icons.close,
                              size: 20, color: AppColors.accent),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _registerLabel('Email'),
                  _registerField(
                    controller: emailCtrl,
                    hintText: 'you@email.com',
                    keyboardType: TextInputType.emailAddress,
                    errorText: errorText,
                  ),
                  const SizedBox(height: 19),
                  _registerLabel('Password'),
                  _registerField(
                    controller: passCtrl,
                    hintText: 'Enter password or Sanctum Pin',
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
              onPressed: () async {
                final email = emailCtrl.text.trim().toLowerCase();
                if (email.isEmpty || passCtrl.text.isEmpty) {
                  setDialogState(
                      () => errorText = 'Enter your email and password.');
                  return;
                }
                try {
                  final response = await Supabase.instance.client.auth
                      .signInWithPassword(
                          email: email, password: passCtrl.text);
                  if (response.session == null) {
                    setDialogState(() => errorText =
                        'Please verify your email before signing in.');
                    return;
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => const MainScreen()));
                  }
                } on AuthException catch (error) {
                  setDialogState(() => errorText = error.message);
                } catch (_) {
                  setDialogState(
                      () => errorText = 'Unable to sign in right now.');
                }
              },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        backgroundColor: const Color(0xFF3B005D),
                      ),
                      child: Text(
                        'Sign in',
                        style: GoogleFonts.fredoka(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showRegisterDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final houseCtrl = TextEditingController();
    String role = 'Mom';
    String? errorText;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 430,
              maxHeight: MediaQuery.sizeOf(ctx).height * 0.92,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 22, 28, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'Create your household',
                          style: GoogleFonts.fredoka(
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(ctx),
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE2EC),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Icon(Icons.close,
                              size: 20, color: AppColors.accent),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _registerLabel('Your Name'),
                  _registerField(
                    controller: nameCtrl,
                    hintText: 'e.g., Maria Reyes',
                  ),
                  const SizedBox(height: 19),
                  _registerLabel('Email'),
                  _registerField(
                    controller: emailCtrl,
                    hintText: 'you@email.com',
                    keyboardType: TextInputType.emailAddress,
                    errorText: errorText,
                  ),
                  const SizedBox(height: 19),
                  _registerLabel('Password'),
                  _registerField(
                    controller: passCtrl,
                    hintText: 'Min 8 characters',
                    obscureText: true,
                  ),
                  const SizedBox(height: 19),
                  _registerLabel('Household Name'),
                  _registerField(
                    controller: houseCtrl,
                    hintText: 'e.g., Reyes Family',
                  ),
                  const SizedBox(height: 19),
                  _registerLabel('Role'),
                  DropdownButtonFormField<String>(
                    initialValue: role,
                    style: GoogleFonts.fredoka(
                        fontSize: 15, color: AppColors.textPrimary),
                    items: const [
                      DropdownMenuItem(value: 'Mom', child: Text('Mom')),
                      DropdownMenuItem(value: 'Dad', child: Text('Dad')),
                      DropdownMenuItem(value: 'Guardian', child: Text('Guardian')),
                      DropdownMenuItem(value: 'Ate', child: Text('Ate')),
                      DropdownMenuItem(value: 'Kuya', child: Text('Kuya')),
                      DropdownMenuItem(value: 'Baby', child: Text('Baby')),
                      DropdownMenuItem(value: 'Babysitter', child: Text('Babysitter')),
                      DropdownMenuItem(value: 'House Help', child: Text('House Help')),
                    ],
                    onChanged: (v) => setDialogState(() => role = v ?? 'Mom'),
                    decoration: _registerDecoration(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final email = emailCtrl.text.trim().toLowerCase();
                final password = passCtrl.text;
                final household = houseCtrl.text.trim();
                if (name.isEmpty ||
                    household.isEmpty ||
                    password.length < 8 ||
                    !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                  setDialogState(() => errorText =
                      'Enter valid details. Password must be at least 8 characters.');
                  return;
                }
                try {
                  final response = await Supabase.instance.client.auth.signUp(
                    email: email,
                    password: password,
                    emailRedirectTo: kIsWeb ? Uri.base.origin : null,
                    data: {
                      'name': name,
                      'household': household,
                      'role': role,
                    },
                  );
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                  if (response.session == null) {
                    _showEmailConfirmationDialog(context, email);
                    return;
                  }
                  if (context.mounted) {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => const MainScreen()));
                  }
                } on AuthException catch (error) {
                  setDialogState(() => errorText = error.message);
                } catch (_) {
                  setDialogState(() =>
                      errorText = 'Unable to create your account right now.');
                }
              },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        backgroundColor: const Color(0xFF3B005D),
                      ),
                      child: Text(
                        'Create household',
                        style: GoogleFonts.fredoka(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEmailConfirmationDialog(BuildContext context, String email) {
    bool isSending = false;
    String? message;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Check your email',
                        style: GoogleFonts.fredoka(
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(ctx),
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE2EC),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Icon(Icons.close,
                            size: 20, color: AppColors.accent),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'We sent a confirmation code to $email. Confirm your email to enter your household.',
                  style: GoogleFonts.fredoka(
                    fontSize: 15,
                    height: 1.45,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    message!,
                    style: GoogleFonts.fredoka(
                      fontSize: 13,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: isSending
                        ? null
                        : () async {
                            setDialogState(() {
                              isSending = true;
                              message = null;
                            });
                            try {
                              await Supabase.instance.client.auth.resend(
                                type: OtpType.signup,
                                email: email,
                              );
                              setDialogState(() => message =
                                  'A new confirmation email has been sent.');
                            } on AuthException catch (error) {
                              setDialogState(() => message = error.message);
                            } catch (_) {
                              setDialogState(() => message =
                                  'Unable to resend the email right now.');
                            } finally {
                              if (ctx.mounted) {
                                setDialogState(() => isSending = false);
                              }
                            }
                          },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: Text(
                      isSending ? 'Sending...' : 'Did not receive email',
                      style: GoogleFonts.fredoka(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: const Color(0xFF3B005D),
                    ),
                    child: Text(
                      'I confirmed my email',
                      style: GoogleFonts.fredoka(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _registerLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 1, bottom: 9),
      child: Text(
        label,
        style: GoogleFonts.fredoka(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _registerField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? errorText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: GoogleFonts.fredoka(fontSize: 15, color: AppColors.textPrimary),
      decoration: _registerDecoration(hintText: hintText, errorText: errorText),
    );
  }

  InputDecoration _registerDecoration({String? hintText, String? errorText}) {
    return InputDecoration(
      hintText: hintText,
      errorText: errorText,
      hintStyle: GoogleFonts.fredoka(fontSize: 15, color: AppColors.textMuted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFEADFF0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFEADFF0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.overdue),
      ),
    );
  }
}

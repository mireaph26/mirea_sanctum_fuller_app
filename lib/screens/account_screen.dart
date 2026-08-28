import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import 'landing_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  static const avatarPaths = [
    'assets/avatars/avatar_moon.svg',
    'assets/avatars/avatar_bunny.svg',
    'assets/avatars/avatar_cream_cat.svg',
    'assets/avatars/avatar_gray_cat.svg',
    'assets/avatars/avatar_white_cat.svg',
    'assets/avatars/avatar_happy_cat.svg',
    'assets/avatars/avatar_sleepy_cat.svg',
    'assets/avatars/avatar_big_eyes.svg',
  ];
  static const roles = [
    'Mom',
    'Dad',
    'Guardian',
    'Ate',
    'Kuya',
    'Baby',
    'Babysitter',
    'House Help',
  ];

  late final TextEditingController nameController;
  late final TextEditingController householdController;
  String selectedRole = 'Mom';
  String? selectedAvatar;
  Uint8List? customAvatar;
  bool isSaving = false;
  String? saveMessage;

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    final metadata = user?.userMetadata ?? <String, dynamic>{};
    nameController = TextEditingController(text: metadata['name']?.toString() ?? '');
    householdController = TextEditingController(
      text: metadata['household']?.toString() ?? 'Your household');
    final savedRole = metadata['role']?.toString();
    selectedRole = roles.firstWhere(
      (role) => role.toLowerCase() == savedRole?.toLowerCase(),
      orElse: () => 'Mom',
    );
    selectedAvatar = metadata['avatar']?.toString();
    final avatarData = metadata['avatarData']?.toString();
    if (avatarData != null) {
      try {
        customAvatar = base64Decode(avatarData);
      } catch (_) {
        customAvatar = null;
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    householdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final metadata = user?.userMetadata ?? <String, dynamic>{};
    final name = nameController.text.trim().isEmpty
      ? 'Mirea member'
      : nameController.text.trim();
    final email = user?.email ?? 'No email connected';
    final inviteCode = metadata['inviteCode']?.toString() ??
        (user == null ? 'MIREA-FAMILY' : _inviteCodeForUser(user.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Account',
          style: GoogleFonts.fredoka(fontSize: 21, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _profileAvatar(name),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: GoogleFonts.fredoka(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                email,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _sectionTitle('App theme'),
                  _themePicker(),
                  const SizedBox(height: 20),
                  _sectionTitle('Profile picture'),
                  _avatarPicker(),
                  const SizedBox(height: 20),
                  _sectionTitle('Personal details'),
                  _detailCard([
                    _accountField(
                      icon: Icons.person_outline,
                      label: 'Name',
                      controller: nameController,
                      hint: 'Your name',
                      onChanged: (_) => setState(() {}),
                    ),
                    _accountField(
                      icon: Icons.alternate_email,
                      label: 'Email',
                      initialValue: email,
                      readOnly: true,
                    ),
                    _roleField(),
                    if (saveMessage != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            saveMessage!,
                            style: GoogleFonts.fredoka(
                              fontSize: 13,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isSaving ? null : _savePersonalDetails,
                          child: Text(
                            isSaving ? 'Saving...' : 'Save personal details',
                            style: GoogleFonts.fredoka(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _sectionTitle('Household'),
                  _detailCard([
                    _accountField(
                      icon: Icons.home_outlined,
                      label: 'Household name',
                      controller: householdController,
                      hint: 'Your household',
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: isSaving ? null : _saveHouseholdName,
                          child: Text(
                            isSaving ? 'Saving...' : 'Save household name',
                            style: GoogleFonts.fredoka(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    _detailRow(Icons.group_outlined, 'Membership', 'Active member'),
                    _inviteCodeRow(inviteCode),
                  ]),
                  const SizedBox(height: 20),
                  _sectionTitle('Account access'),
                  _detailCard([
                    _detailRow(Icons.verified_user_outlined, 'Email status',
                        user?.emailConfirmedAt == null ? 'Pending verification' : 'Verified'),
                    _detailRow(Icons.lock_outline, 'Password', '••••••••'),
                  ]),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: Text(
                        'Sign out',
                        style: GoogleFonts.fredoka(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onPressed: () async {
                        await Supabase.instance.client.auth.signOut();
                        if (!context.mounted) return;
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LandingScreen()),
                          (_) => false,
                        );
                      },
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

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.fredoka(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _detailCard(List<Widget> rows) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: rows),
    );
  }

  Widget _themePicker() {
    final options = [
      (AppThemeVariant.sanctum, 'Sanctum', AppColors.primary, 'Warm and magical'),
      (AppThemeVariant.midnight, 'Midnight', const Color(0xFF197C86), 'Navy and teal'),
      (AppThemeVariant.whiteMinimal, 'White Minimal', const Color(0xFF252B33), 'Clean and simple'),
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: options.map((option) {
          final selected = appThemeController.variant == option.$1;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => appThemeController.setVariant(option.$1),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: selected ? option.$3.withValues(alpha: .1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? option.$3 : const Color(0xFFEADFF0),
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: option.$3,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(option.$2, style: GoogleFonts.fredoka(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          Text(option.$4, style: GoogleFonts.nunito(fontSize: 11, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    if (selected) Icon(Icons.check_circle, color: option.$3),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _accountField({
    required IconData icon,
    required String label,
    TextEditingController? controller,
    String? initialValue,
    String? hint,
    bool readOnly = false,
    ValueChanged<String>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: TextFormField(
        controller: controller,
        initialValue: controller == null ? initialValue : null,
        readOnly: readOnly,
        onChanged: onChanged,
        style: GoogleFonts.fredoka(fontSize: 15, color: AppColors.textPrimary),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.primary),
          labelText: label,
          hintText: hint,
          labelStyle: GoogleFonts.nunito(fontSize: 12, color: AppColors.textMuted),
          hintStyle: GoogleFonts.fredoka(fontSize: 15, color: AppColors.textMuted),
          filled: true,
          fillColor: readOnly ? const Color(0xFFF7F3F9) : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFEADFF0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFEADFF0)),
          ),
        ),
      ),
    );
  }

  Widget _roleField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: DropdownButtonFormField<String>(
        initialValue: selectedRole,
        style: GoogleFonts.fredoka(fontSize: 15, color: AppColors.textPrimary),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.primary),
          labelText: 'Role',
          labelStyle: GoogleFonts.nunito(fontSize: 12, color: AppColors.textMuted),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFEADFF0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFEADFF0)),
          ),
        ),
        items: roles
            .map((role) => DropdownMenuItem(value: role, child: Text(role)))
            .toList(),
        onChanged: (role) {
          if (role != null) setState(() => selectedRole = role);
        },
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        label,
        style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textMuted),
      ),
      subtitle: Text(
        value,
        style: GoogleFonts.fredoka(fontSize: 15, color: AppColors.textPrimary),
      ),
    );
  }

  Future<void> _savePersonalDetails() async {
    final user = Supabase.instance.client.auth.currentUser;
    final name = nameController.text.trim();
    if (user == null || name.isEmpty) {
      setState(() => saveMessage = 'Please enter your name.');
      return;
    }
    setState(() {
      isSaving = true;
      saveMessage = null;
    });
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {
          'name': name,
          'role': selectedRole,
          'household': householdController.text.trim(),
          'inviteCode': _inviteCodeForUser(user.id),
          'avatarData': customAvatar == null ? null : base64Encode(customAvatar!),
          'avatar': selectedAvatar,
        }),
      );
      if (mounted) setState(() => saveMessage = 'Personal details updated.');
    } on AuthException catch (error) {
      if (mounted) setState(() => saveMessage = error.message);
    } catch (_) {
      if (mounted) setState(() => saveMessage = 'Unable to save your details right now.');
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  Future<void> _saveHouseholdName() async {
    final user = Supabase.instance.client.auth.currentUser;
    final household = householdController.text.trim();
    if (user == null || household.isEmpty) {
      setState(() => saveMessage = 'Please enter a household name.');
      return;
    }
    setState(() {
      isSaving = true;
      saveMessage = null;
    });
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'household': household}),
      );
      if (mounted) setState(() => saveMessage = 'Household name updated.');
    } on AuthException catch (error) {
      if (mounted) setState(() => saveMessage = error.message);
    } catch (_) {
      if (mounted) setState(() => saveMessage = 'Unable to save the household name right now.');
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  String _inviteCodeForUser(String userId) {
    final prefixLength = userId.length < 6 ? userId.length : 6;
    return 'MIREA-${userId.substring(0, prefixLength).toUpperCase()}';
  }

  Widget _inviteCodeRow(String inviteCode) {
    return ListTile(
      leading: const Icon(Icons.key_outlined, color: AppColors.primary),
      title: Text(
        'Household invite code',
        style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textMuted),
      ),
      subtitle: Text(
        inviteCode,
        style: GoogleFonts.fredoka(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: IconButton(
        tooltip: 'Copy invite code',
        icon: const Icon(Icons.copy_outlined, color: AppColors.primary),
        onPressed: () async {
          await Clipboard.setData(ClipboardData(text: inviteCode));
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invite code copied.')),
          );
        },
      ),
    );
  }

  Widget _profileAvatar(String name) {
    if (customAvatar != null) {
      return ClipOval(
        child: Image.memory(customAvatar!, width: 68, height: 68, fit: BoxFit.cover),
      );
    }
    if (selectedAvatar != null && avatarPaths.contains(selectedAvatar)) {
      return ClipOval(
        child: SvgPicture.asset(selectedAvatar!, width: 68, height: 68),
      );
    }
    return CircleAvatar(
      radius: 34,
      backgroundColor: AppColors.primaryLight,
      child: Text(
        name.trim().isEmpty ? 'M' : name.trim()[0].toUpperCase(),
        style: GoogleFonts.fredoka(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }

  Widget _avatarPicker() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          ...avatarPaths.map((path) {
            final selected = selectedAvatar == path;
            return InkWell(
              onTap: () => setState(() {
                selectedAvatar = path;
                customAvatar = null;
              }),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppColors.primary : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: SvgPicture.asset(path, width: 58, height: 58),
                ),
              ),
            );
          }),
          InkWell(
            onTap: _pickPicture,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFF3E8FF),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryLight),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_a_photo_outlined,
                      size: 20, color: AppColors.primaryDark),
                  Text('Add picture',
                      style: GoogleFonts.fredoka(
                          fontSize: 8, color: AppColors.primaryDark)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickPicture() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      maxHeight: 600,
      imageQuality: 85,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() {
      customAvatar = bytes;
      selectedAvatar = null;
    });
  }
}

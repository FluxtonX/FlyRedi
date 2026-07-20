import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/skeleton_box.dart';
import '../widgets/traveller_bottom_nav.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../presentation/providers/profile_provider.dart';
import '../presentation/providers/claim_provider.dart';
import 'personal_information_screen.dart';
import 'privacy_security_screen.dart';
import '../../../core/theme/theme_provider.dart';
import '../models/claim_model.dart';
import '../../../config/app_router.dart';

class ProfileScreen extends StatefulWidget {
  final bool showBottomNav;

  const ProfileScreen({
    super.key,
    this.showBottomNav = true,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
    });
  }

  Future<void> _loadProfileData() async {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    final uid = auth.user?.id;
    if (uid == null) return;

    try {
      await Future.wait([
        auth.refreshProfile(),
        context.read<ProfileProvider>().loadStats(uid),
        context.read<ClaimProvider>().loadClaims(),
      ]);
    } catch (e) {
      if (mounted) {
        if (!_isFirstLoad) {
          _showSnackBar('Could not refresh profile.', isError: true);
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFirstLoad = false;
        });
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: Theme.of(context).colorScheme.onSurface,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        backgroundColor:
            isError ? const Color(0xFFE11D48) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showEditProfileSheet() {
    final auth = context.read<AuthProvider>();
    final profileProvider = context.read<ProfileProvider>();
    final user = auth.user;
    if (user == null) return;

    final nameCtrl = TextEditingController(text: user.displayName);
    final phoneCtrl = TextEditingController(text: user.phoneNumber);
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Profile',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Icon(Icons.close,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.54)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _sheetField(nameCtrl, 'Full Name', Icons.person_outline),
                const SizedBox(height: 14),
                _sheetField(phoneCtrl, 'Phone Number', Icons.phone_outlined,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 28),
                isSaving
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFFFFC229)),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () async {
                          setModalState(() => isSaving = true);
                          try {
                            final success = await profileProvider.updateProfile(
                              displayName: nameCtrl.text.trim(),
                              phoneNumber: phoneCtrl.text.trim(),
                            );
                            if (success) {
                              if (ctx.mounted) Navigator.pop(ctx);
                              _showSnackBar('Profile updated successfully!');
                            } else {
                              _showSnackBar(
                                  profileProvider.errorMessage ??
                                      'Failed to update profile.',
                                  isError: true);
                            }
                          } catch (_) {
                            _showSnackBar('Failed to update profile.',
                                isError: true);
                          } finally {
                            if (ctx.mounted) {
                              setModalState(() => isSaving = false);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Save Changes',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _sheetField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54)),
        prefixIcon: Icon(icon,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
            size: 20),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFFC229), width: 1.5),
        ),
      ),
    );
  }

  Future<void> _toggleNotifications(bool value) async {
    final profileProvider = context.read<ProfileProvider>();
    final auth = context.read<AuthProvider>();
    final currentProfile = auth.user;
    if (currentProfile == null) return;

    try {
      await profileProvider.updateNotifications(enabled: value);
      await auth.refreshProfile();
      _showSnackBar(
          value ? 'Notifications enabled.' : 'Notifications disabled.');
    } catch (_) {
      _showSnackBar('Failed to update notifications.', isError: true);
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Log Out',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to log out?',
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.54))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AuthProvider>().logout();
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRouter.login,
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Log Out',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() {
    bool isDeleting = false;

    showModalBottomSheet(
      context: context,
      isDismissible: !isDeleting,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: const Color(0xFFE11D48).withOpacity(0.18),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Drag handle ──────────────────────────────────────────
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.15),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Danger icon ──────────────────────────────────────────
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: const RadialGradient(colors: [
                        Color(0x33E11D48),
                        Color(0x00E11D48),
                      ]),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFFE11D48).withOpacity(0.3),
                          width: 1.5),
                    ),
                    child: const Icon(
                      Icons.delete_forever_rounded,
                      color: Color(0xFFE11D48),
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Title ────────────────────────────────────────────────
                  const Text(
                    'Delete Account',
                    style: TextStyle(
                      color: Color(0xFFE11D48),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Your account will be permanently removed along with all your flights, trips, and personal data.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.55),
                        fontSize: 13.5,
                        height: 1.55,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // ── Warning card ─────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE11D48).withOpacity(0.07),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: const Color(0xFFE11D48).withOpacity(0.2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: Color(0xFFE11D48), size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'This action is irreversible and cannot be undone.',
                              style: TextStyle(
                                color: const Color(0xFFE11D48).withOpacity(0.85),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Buttons ──────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Delete button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: isDeleting
                                ? null
                                : () async {
                                    setSheetState(() => isDeleting = true);

                                    final success = await context
                                        .read<ProfileProvider>()
                                        .deleteAccount();

                                    if (!ctx.mounted) return;

                                    if (success) {
                                      Navigator.of(ctx).pop();
                                      if (mounted) {
                                        Navigator.of(context)
                                            .pushNamedAndRemoveUntil(
                                          AppRouter.login,
                                          (route) => false,
                                        );
                                      }
                                    } else {
                                      Navigator.of(ctx).pop();
                                      _showSnackBar(
                                        'Failed to delete account. Please try again.',
                                        isError: true,
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE11D48),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  const Color(0xFFE11D48).withOpacity(0.7),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: isDeleting
                                ? const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'Deleting...',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  )
                                : const Text(
                                    'Yes, Delete My Account',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Cancel button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: TextButton(
                            onPressed:
                                isDeleting ? null : () => Navigator.pop(ctx),
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.12),
                                ),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.65),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Safe area bottom padding ──────────────────────────────
                  SizedBox(
                      height: MediaQuery.of(ctx).padding.bottom + 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final hasUser = auth.user != null;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'Profile',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 22,
                fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          if (hasUser)
            IconButton(
              onPressed: _showEditProfileSheet,
              icon: const Icon(Icons.edit_outlined, color: Color(0xFFFFC229)),
              tooltip: 'Edit profile',
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: widget.showBottomNav
          ? const TravellerBottomNav(activeIndex: 4)
          : null,
    );
  }

  Widget _buildBody() {
    final auth = context.watch<AuthProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final claimProvider = context.watch<ClaimProvider>();

    final isLoading = _isFirstLoad &&
        (auth.isLoading ||
            profileProvider.isLoading ||
            claimProvider.isLoading);

    if (isLoading) {
      return _buildProfileSkeleton();
    }

    final profile = auth.user;
    final stats = profileProvider.stats;

    if (profile == null || stats == null) {
      if (profile == null) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFC229)),
          ),
        );
      }
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: Color(0xFFE11D48), size: 60),
              const SizedBox(height: 16),
              Text('Failed to load profile',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                  profileProvider.errorMessage ??
                      'An error occurred while loading profile data.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.54),
                      fontSize: 14)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadProfileData,
                icon: const Icon(Icons.refresh_rounded, color: Colors.black),
                label: const Text('Retry',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProfileData,
      color: const Color(0xFFFFC229),
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Profile Card ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border:
                    Border.all(color: Theme.of(context).colorScheme.outline),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Color(0xFFFFC229).withOpacity(0.15),
                        child: Text(
                          profile.initials,
                          style: const TextStyle(
                            color: Color(0xFFFFC229),
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _showEditProfileSheet,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFC229),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit,
                                size: 12, color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profile.displayName.isNotEmpty
                        ? profile.displayName
                        : profile.email,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.email,
                    style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                        fontSize: 13),
                  ),
                  if (profile.phoneNumber.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      profile.phoneNumber,
                      style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.35),
                          fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 14),
                  // Plan badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: profile.plan == 'Free'
                          ? Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.06)
                          : const Color(0xFFFFC229).withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: profile.plan == 'Free'
                            ? Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.1)
                            : const Color(0xFFFFC229).withOpacity(0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          profile.plan == 'Free'
                              ? Icons.person_outline
                              : Icons.star_rounded,
                          size: 14,
                          color: profile.plan == 'Free'
                              ? Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.5)
                              : const Color(0xFFFFC229),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          profile.plan == 'Plus'
                              ? 'Plus Member'
                              : '${profile.plan} Plan',
                          style: TextStyle(
                            color: profile.plan == 'Free'
                                ? Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.5)
                                : const Color(0xFFFFC229),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Notifications Toggle ─────────────────────────────────────
            _sectionLabel('Preferences'),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: Theme.of(context).colorScheme.outline),
              ),
              child: Row(
                children: [
                  Icon(Icons.notifications_none,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                      size: 18),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text('Push Notifications',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 13)),
                  ),
                  Switch(
                    value: profile.notificationsEnabled,
                    activeColor: const Color(0xFFFFC229),
                    onChanged: _toggleNotifications,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Account Section ──────────────────────────────────────────
            _sectionLabel('Account'),
            const SizedBox(height: 14),
            _buildSettingsItem(
              icon: Icons.person_outline,
              title: 'Personal Information',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PersonalInformationScreen(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _sectionLabel('Security'),
            const SizedBox(height: 14),
            _buildSettingsItem(
              icon: Icons.shield_outlined,
              title: 'Account Security',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PrivacySecurityScreen(),
                ),
              ),
            ),
            // ── Past Claims History ──────────────────────────────────────────
            const SizedBox(height: 24),
            _sectionLabel('Past Claims History'),
            const SizedBox(height: 14),
            _buildPastClaimsSection(claimProvider.claims),

            // ── Help & Support ──────────────────────────────────────────────
            const SizedBox(height: 24),
            _sectionLabel('Help & Support'),
            const SizedBox(height: 14),
            _buildHelpSupportSection(),

            const SizedBox(height: 24),
            _sectionLabel('Preferences'),
            const SizedBox(height: 14),
            _buildThemeSwitcherTile(),

            const SizedBox(height: 24),

            // ── Log Out Button ────────────────────────────────────────────
            _sectionLabel('Actions'),
            const SizedBox(height: 14),
            _buildSettingsItem(
              icon: Icons.logout,
              title: 'Log Out',
              titleColor: Theme.of(context).colorScheme.error,
              iconColor: Theme.of(context).colorScheme.error,
              onTap: _logout,
            ),
            const SizedBox(height: 10),
            _buildSettingsItem(
              icon: Icons.delete_forever_outlined,
              title: 'Delete Account',
              titleColor: const Color(0xFFE11D48),
              iconColor: const Color(0xFFE11D48),
              onTap: _deleteAccount,
            ),

            const SizedBox(height: 32),

            // ── Footer ────────────────────────────────────────────────────
            Text(
              'FLYREDI v1.0.0',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.18),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.6),
            ),
            const SizedBox(height: 4),
            Text(
              'Powered by Sentinel™, BorderReady™ & Resolution Assistant™',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.14),
                  fontSize: 8),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSkeleton() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: const Column(
              children: [
                SkeletonBox(width: 80, height: 80, radius: 40),
                SizedBox(height: 16),
                SkeletonBox(width: 160, height: 22, radius: 12),
                SizedBox(height: 8),
                SkeletonBox(width: 210, height: 16, radius: 10),
                SizedBox(height: 16),
                SkeletonBox(width: 100, height: 30, radius: 20),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: const SkeletonBox(height: 100, radius: 20)),
              const SizedBox(width: 10),
              Expanded(child: const SkeletonBox(height: 100, radius: 20)),
              const SizedBox(width: 10),
              Expanded(child: const SkeletonBox(height: 100, radius: 20)),
            ],
          ),
          const SizedBox(height: 28),
          const SkeletonBox(width: 120, height: 18, radius: 10),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: const SkeletonBox(height: 104, radius: 18)),
              const SizedBox(width: 12),
              Expanded(child: const SkeletonBox(height: 104, radius: 18)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: const SkeletonBox(height: 104, radius: 18)),
              const SizedBox(width: 12),
              Expanded(child: const SkeletonBox(height: 104, radius: 18)),
            ],
          ),
          const SizedBox(height: 28),
          const SkeletonBox(width: 110, height: 18, radius: 10),
          const SizedBox(height: 14),
          const SkeletonBox(height: 62, radius: 16),
          const SizedBox(height: 14),
          const SkeletonBox(height: 62, radius: 16),
        ],
      ),
    );
  }

  Widget _buildThemeSwitcherTile() {
    final theme = context.watch<ThemeProvider>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Row(
        children: [
          Icon(
            theme.isDarkMode
                ? Icons.dark_mode_outlined
                : Icons.light_mode_outlined,
            color: const Color(0xFFFFC229),
            size: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text('Dark Mode',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
          ),
          Switch(
            value: theme.isDarkMode,
            activeColor: const Color(0xFFFFC229),
            onChanged: (val) => theme.toggleTheme(),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    Color? titleColor,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon,
                    color: iconColor ??
                        Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                    size: 18),
                const SizedBox(width: 14),
                Text(title,
                    style: TextStyle(
                        color: titleColor ??
                            Theme.of(context).colorScheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
              ],
            ),
            Icon(Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildPastClaimsSection(List<ClaimModel> claims) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: const Color(0xFFFFC229),
          collapsedIconColor:
              Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          leading: const Icon(Icons.luggage_outlined,
              size: 20, color: Color(0xFFFFC229)),
          title: Text(
            'View Past Claims History',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          childrenPadding:
              const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          children: claims.isEmpty
              ? [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'No past claims found.',
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                        fontSize: 13,
                      ),
                    ),
                  )
                ]
              : claims.map((claim) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildClaimHistoryItem(
                      'Flight ${claim.flightCode}',
                      claim.status,
                    ),
                  );
                }).toList(),
        ),
      ),
    );
  }

  Widget _buildClaimHistoryItem(String title, String status) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.check, color: Color(0xFF10B981), size: 16),
              ),
              const SizedBox(width: 14),
              Text(title,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          Text(status,
              style: const TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildHelpSupportSection() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: const Color(0xFFFFC229),
          collapsedIconColor:
              Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          leading: const Icon(Icons.help_outline,
              size: 20, color: Color(0xFFFFC229)),
          title: Text(
            'Help & Support (FAQ)',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          childrenPadding:
              const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          children: [
            _buildFaqItem('How do I claim baggage compensation?',
                'You can file a new claim directly from the "Claims" tab by providing your flight details and a picture of your baggage receipt. Our system will handle the rest.'),
            const SizedBox(height: 12),
            _buildFaqItem('What is the processing time?',
                'Typically, initial airline responses take between 14-30 days. However, our Resolution Assistant™ automatically follows up on your behalf to speed up the process.'),
            const SizedBox(height: 12),
            _buildFaqItem('Are there any hidden fees?',
                'No, our basic tracking is completely free. We only charge a small success fee if we successfully win compensation on your behalf.'),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          answer,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            fontSize: 12,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

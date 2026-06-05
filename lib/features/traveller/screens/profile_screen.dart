import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sky_rightz_360/core/constants/app_colors.dart';
import '../widgets/traveller_bottom_nav.dart';
import '../models/user_profile.dart';
import '../repositories/profile_repository.dart';
import '../../authentication/screens/sign_in_screen.dart';
import 'trips_overview_screen.dart';
import 'resolve_dashboard_screen.dart';
import 'border_ready_screen.dart';
import 'flight_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileRepository _repository = ProfileRepository();

  bool _isLoading = true;
  String? _errorMessage;

  UserProfile? _profile;
  ProfileStats? _stats;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // ─── Data Loading ─────────────────────────────────────────────────────────

  Future<void> _loadProfileData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final results = await Future.wait([
        _repository.getProfile(),
        _repository.getStats(),
      ]);
      if (mounted) {
        setState(() {
          _profile = results[0] as UserProfile;
          _stats = results[1] as ProfileStats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  // ─── Snackbar ─────────────────────────────────────────────────────────────

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        backgroundColor:
            isError ? const Color(0xFFE11D48) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ─── Edit Profile Sheet ───────────────────────────────────────────────────

  void _showEditProfileSheet() {
    if (_profile == null) return;
    final nameCtrl = TextEditingController(text: _profile!.displayName);
    final phoneCtrl = TextEditingController(text: _profile!.phoneNumber);
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0C162A),
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
                    const Text(
                      'Edit Profile',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: const Icon(Icons.close, color: Colors.white54),
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
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFFFC229)),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () async {
                          setModalState(() => isSaving = true);
                          try {
                            final updated = await _repository.updateProfile(
                              displayName: nameCtrl.text.trim(),
                              phoneNumber: phoneCtrl.text.trim(),
                            );
                            if (mounted) {
                              setState(() => _profile = updated);
                            }
                            if (ctx.mounted) Navigator.pop(ctx);
                            _showSnackBar('Profile updated successfully!');
                          } catch (_) {
                            _showSnackBar('Failed to update profile.', isError: true);
                          } finally {
                            if (ctx.mounted) setModalState(() => isSaving = false);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC229),
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
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        filled: true,
        fillColor: const Color(0xFF10284F),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFFFFC229), width: 1.5),
        ),
      ),
    );
  }

  // ─── Notification Toggle ──────────────────────────────────────────────────

  Future<void> _toggleNotifications(bool value) async {
    final prev = _profile!.notificationsEnabled;
    setState(() => _profile = _profile!.copyWith(notificationsEnabled: value));
    try {
      await _repository.updateNotifications(enabled: value);
      _showSnackBar(
          value ? 'Notifications enabled.' : 'Notifications disabled.');
    } catch (_) {
      if (mounted) setState(() => _profile = _profile!.copyWith(notificationsEnabled: prev));
      _showSnackBar('Failed to update notifications.', isError: true);
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────────

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0C162A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Out',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SignInScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              foregroundColor: Colors.white,
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

  // ─── Delete Account ───────────────────────────────────────────────────────

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0C162A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Account',
            style: TextStyle(
                color: Color(0xFFE11D48), fontWeight: FontWeight.bold)),
        content: const Text(
          'This will permanently delete your account and all data. This cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _repository.deleteAccount();
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignInScreen()),
                    (route) => false,
                  );
                }
              } catch (_) {
                _showSnackBar('Failed to delete account.', isError: true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'Profile',
            style: TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          if (_profile != null)
            IconButton(
              onPressed: _showEditProfileSheet,
              icon: const Icon(Icons.edit_outlined, color: Color(0xFFFFC229)),
              tooltip: 'Edit profile',
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: const TravellerBottomNav(activeIndex: 4),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(Color(0xFFFFC229)),
            ),
            SizedBox(height: 16),
            Text('Loading profile...',
                style: TextStyle(color: Colors.white70, fontSize: 16)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: Color(0xFFE11D48), size: 60),
              const SizedBox(height: 16),
              const Text('Failed to load profile',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(_errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white54, fontSize: 14)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadProfileData,
                icon: const Icon(Icons.refresh_rounded, color: Colors.black),
                label: const Text('Retry',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC229),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final profile = _profile!;
    final stats = _stats!;

    return RefreshIndicator(
      onRefresh: _loadProfileData,
      color: const Color(0xFFFFC229),
      backgroundColor: const Color(0xFF10284F),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Profile Card ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF0C162A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor:
                            const Color(0xFFFFC229).withOpacity(0.15),
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
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.email,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.4), fontSize: 13),
                  ),
                  if (profile.phoneNumber.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      profile.phoneNumber,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 14),
                  // Plan badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: profile.plan == 'Free'
                          ? Colors.white.withOpacity(0.06)
                          : const Color(0xFFFFC229).withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: profile.plan == 'Free'
                            ? Colors.white.withOpacity(0.1)
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
                              ? Colors.white54
                              : const Color(0xFFFFC229),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${profile.plan} Plan',
                          style: TextStyle(
                            color: profile.plan == 'Free'
                                ? Colors.white54
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

            // ── Stats Row ─────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.flight_takeoff_outlined,
                    value: '${stats.savedTrips}',
                    label: 'Trips\nMonitored',
                    color: const Color(0xFFFFC229),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.description_outlined,
                    value: '${stats.savedCases}',
                    label: 'Active\nClaims',
                    color: const Color(0xFF3B82F6),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.folder_zip_outlined,
                    value: '${stats.caseVaultItems}',
                    label: 'Vault\nItems',
                    color: const Color(0xFF10B981),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ── Quick Access ─────────────────────────────────────────────
            _sectionLabel('Quick Access'),
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.45,
              children: [
                _buildQuickAccessCard(
                  icon: Icons.shield_outlined,
                  title: 'Sentinel™\nMonitoring',
                  color: const Color(0xFFFFC229),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const FlightDetailScreen())),
                ),
                _buildQuickAccessCard(
                  icon: Icons.check_circle_outline,
                  title: 'BorderReady™',
                  color: const Color(0xFF10B981),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const BorderReadyScreen())),
                ),
                _buildQuickAccessCard(
                  icon: Icons.auto_awesome_outlined,
                  title: 'Resolution\nAssistant™',
                  color: const Color(0xFFFFC229),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const ResolveDashboardScreen())),
                ),
                _buildQuickAccessCard(
                  icon: Icons.flight_outlined,
                  title: 'My Trips',
                  color: const Color(0xFF3B82F6),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const TripsOverviewScreen())),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ── Notifications Toggle ─────────────────────────────────────
            _sectionLabel('Preferences'),
            const SizedBox(height: 14),
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF0C162A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.04)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_none,
                      color: Colors.white54, size: 18),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text('Push Notifications',
                        style:
                            TextStyle(color: Colors.white, fontSize: 13)),
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
              onTap: _showEditProfileSheet,
            ),
            const SizedBox(height: 10),
            _buildSettingsItem(
              icon: Icons.lock_outline,
              title: 'Privacy & Security',
            ),
            const SizedBox(height: 10),
            _buildSettingsItem(
              icon: Icons.help_outline,
              title: 'Help & Support',
            ),

            const SizedBox(height: 24),

            // ── Log Out Button ────────────────────────────────────────────
            _buildActionButton(
              icon: Icons.logout,
              label: 'Log Out',
              color: Colors.white.withOpacity(0.6),
              onTap: _logout,
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              icon: Icons.delete_forever_outlined,
              label: 'Delete Account',
              color: const Color(0xFFE11D48).withOpacity(0.8),
              onTap: _deleteAccount,
            ),

            const SizedBox(height: 32),

            // ── Footer ────────────────────────────────────────────────────
            Text(
              'SKYRIGHTZ360 v1.0.0',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.18),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.6),
            ),
            const SizedBox(height: 4),
            Text(
              'Powered by Sentinel™, BorderReady™ & Resolution Assistant™',
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: Colors.white.withOpacity(0.14), fontSize: 8),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ─── Reusable Widgets ────────────────────────────────────────────────────

  Widget _sectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
          color: Colors.white38,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0C162A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.35),
                  fontSize: 9,
                  height: 1.2)),
        ],
      ),
    );
  }

  Widget _buildQuickAccessCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0C162A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 22),
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    height: 1.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF0C162A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white54, size: 18),
                const SizedBox(width: 14),
                Text(title,
                    style: const TextStyle(color: Colors.white, fontSize: 13)),
              ],
            ),
            Icon(Icons.chevron_right,
                color: Colors.white.withOpacity(0.2), size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF0C162A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 10),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

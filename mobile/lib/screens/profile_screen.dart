import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../state/app_state.dart';

class ProfileScreen extends StatelessWidget {
  final Future<void> Function() onLogout;
  const ProfileScreen({super.key, required this.onLogout});

  static const _rows = <(IconData, String, String)>[
    (
      Icons.person_outline_rounded,
      'Personal Information',
      'Name, phone, address',
    ),
    (Icons.shield_outlined, 'Security', 'Security settings'),
    (Icons.devices_rounded, 'Devices', 'Devices using your account'),
    (Icons.notifications_none_rounded, 'Notifications', 'Alerts and reminders'),
    (Icons.help_outline_rounded, 'Help & Support', 'FAQs and contact'),
    (Icons.info_outline_rounded, 'About', 'AmanFlow demo v0.1.0'),
  ];

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AppState>().profile;
    if (profile == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text('Profile', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: cardDecoration(radius: 20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    profile.name[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.phone,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        'Customer ID: ${profile.customerCode}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            decoration: cardDecoration(),
            child: Column(
              children: [
                for (final r in _rows)
                  ListTile(
                    leading: Icon(r.$1, color: AppColors.primary),
                    title: Text(
                      r.$2,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      r.$3,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {},
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            key: const Key('profile-logout'),
            onPressed: onLogout,
            icon: const Icon(Icons.logout),
            label: const Text('Log out'),
          ),
        ],
      ),
    );
  }
}

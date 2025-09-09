import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../theme/app_theme.dart';

// State providers
final darkModeProvider = StateProvider<bool>((ref) => false);
final notificationsProvider = StateProvider<bool>((ref) => true);
final plannerRemindersProvider = StateProvider<bool>((ref) => true);
final cookingTimersProvider = StateProvider<bool>((ref) => true);
final socialBetaProvider = StateProvider<bool>((ref) => false);

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkMode = ref.watch(darkModeProvider);
    final notifications = ref.watch(notificationsProvider);
    final plannerReminders = ref.watch(plannerRemindersProvider);
    final cookingTimers = ref.watch(cookingTimersProvider);
    final socialBeta = ref.watch(socialBetaProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Setări'),
      ),
      body: ListView(
        children: [
          // Profile Section
          _buildProfileSection(context, ref),
          
          const Divider(),
          
          // Appearance Section
          _buildSectionHeader(context, 'Aspect'),
          SwitchListTile(
            title: const Text('Mod întunecat'),
            subtitle: const Text('Activează modul întunecat'),
            value: darkMode,
            onChanged: (value) {
              ref.read(darkModeProvider.notifier).state = value;
            },
          ),
          
          const Divider(),
          
          // Notifications Section
          _buildSectionHeader(context, 'Notificări'),
          SwitchListTile(
            title: const Text('Notificări'),
            subtitle: const Text('Primește notificări din aplicație'),
            value: notifications,
            onChanged: (value) {
              ref.read(notificationsProvider.notifier).state = value;
            },
          ),
          SwitchListTile(
            title: const Text('Memento planificare'),
            subtitle: const Text('Memento pentru planificarea meselor'),
            value: plannerReminders,
            onChanged: notifications ? (value) {
              ref.read(plannerRemindersProvider.notifier).state = value;
            } : null,
            secondary: const Icon(Icons.calendar_today),
          ),
          SwitchListTile(
            title: const Text('Cronometre gătit'),
            subtitle: const Text('Cronometre pentru gătit'),
            value: cookingTimers,
            onChanged: notifications ? (value) {
              ref.read(cookingTimersProvider.notifier).state = value;
            } : null,
            secondary: const Icon(Icons.timer),
          ),
          
          const Divider(),
          
          // Premium Section
          _buildPremiumSection(context, ref),
          
          const Divider(),
          
          // Social Section
          _buildSectionHeader(context, 'Social'),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Deschide Feed'),
            subtitle: const Text('Vezi activitatea prietenilor'),
            trailing: socialBeta ? const Icon(Icons.science) : null,
            onTap: socialBeta ? () {
              // Navigate to social feed
            } : null,
          ),
          
          const Divider(),
          
          // App Info Section
          _buildSectionHeader(context, 'Informații aplicație'),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final packageInfo = snapshot.data!;
                return ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('Versiune'),
                  subtitle: Text('${packageInfo.version} (${packageInfo.buildNumber})'),
                );
              }
              return const ListTile(
                leading: Icon(Icons.info),
                title: Text('Versiune'),
                subtitle: Text('Se încarcă...'),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Politica de confidențialitate'),
            onTap: () {
              // Open privacy policy
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Termeni și condiții'),
            onTap: () {
              // Open terms and conditions
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Ajutor și suport'),
            onTap: () {
              // Open help and support
            },
          ),
          
          const SizedBox(height: AppTheme.spacingXL),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 40,
            backgroundColor: theme.colorScheme.primary,
            child: Text(
              'U',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingM),
          
          // Display name
          Text(
            'Utilizator Demo',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingS),
          
          // Email
          Text(
            'user@example.com',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingL),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Navigate to public profile
                  },
                  icon: const Icon(Icons.public),
                  label: const Text('Profil public'),
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to edit profile
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Editează profil'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumSection(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.all(AppTheme.spacingM),
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentColor.withOpacity(0.1),
            AppTheme.primaryColor.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(
          color: AppTheme.accentColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                color: AppTheme.accentColor,
                size: 24,
              ),
              const SizedBox(width: AppTheme.spacingS),
              Text(
                'TastyLink Premium',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accentColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingS),
          
          Text(
            'Dezblochează funcții avansate și suportă dezvoltarea aplicației',
            style: theme.textTheme.bodyMedium,
          ),
          
          const SizedBox(height: AppTheme.spacingM),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPremiumFeature('Rețete nelimitate'),
                    _buildPremiumFeature('Fără reclame'),
                    _buildPremiumFeature('Funcții sociale avansate'),
                    _buildPremiumFeature('Suport priorititar'),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              ElevatedButton(
                onPressed: () {
                  // Navigate to premium purchase
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Încearcă Premium'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumFeature(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingXS),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: AppTheme.successColor,
            size: 16,
          ),
          const SizedBox(width: AppTheme.spacingS),
          Text(
            feature,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacingL,
        AppTheme.spacingL,
        AppTheme.spacingL,
        AppTheme.spacingS,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'AppSettings_Bloc.dart';
import 'AppSettings_Event.dart';
import 'AppSettings_State.dart';

class AppSettingsPageView extends StatefulWidget {
  const AppSettingsPageView({super.key});

  @override
  State<AppSettingsPageView> createState() => _AppSettingsPageViewState();
}

class _AppSettingsPageViewState extends State<AppSettingsPageView> {
  String _deletePassword = '';

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppSettingsBloc, AppSettingsState>(
      listener: (context, state) {
        if (state.isLoggedOut) {
          Navigator.of(context, rootNavigator: true)
              .pushNamedAndRemoveUntil('/', (route) => false);
          return;
        }
        if (state.error != null) {
          _showSnack(context, state.error!, isError: true);
          context.read<AppSettingsBloc>().add(const AppSettingsErrorDismissed());
        }
      },
      builder: (context, state) {
        if (!state.isInitialized && state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!state.isInitialized && state.error != null) {
          return _buildErrorView(context);
        }

        final sections = [
          _buildNotificationSection(context, state),
          const SizedBox(height: 24),
          _buildAppearanceSection(context, state),
          const SizedBox(height: 24),
          _buildAccountSection(context, state),
          const SizedBox(height: 24),
          _buildSupportSection(context, state),
          const SizedBox(height: 40),
        ];

        return _buildSettingsList(context, sections);
      },
    );
  }

  Widget _buildSettingsList(BuildContext context, List<Widget> sections) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < sections.length; i++)
              _StaggeredListItem(index: i, child: sections[i]),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Could not load settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () {
                context.read<AppSettingsBloc>().add(const AppSettingsRetryRequested());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection(BuildContext context, AppSettingsState state) {
    return _SettingsSection(
      title: 'Notifications',
      children: [
        _buildSwitchTile(
          context,
          icon: Icons.notifications_outlined,
          title: 'Push Notifications',
          subtitle: 'Receive push notifications',
          value: state.pushNotifications,
          onChanged: (v) {
            context.read<AppSettingsBloc>().add(PushNotificationToggled(v));
          },
        ),
        _SettingsDivider(),
        _buildSwitchTile(
          context,
          icon: Icons.receipt_long_outlined,
          title: 'Order Updates',
          subtitle: 'Order status and delivery updates',
          value: state.orderNotifications,
          onChanged: (v) {
            context.read<AppSettingsBloc>().add(OrderNotificationToggled(v));
          },
        ),
        _SettingsDivider(),
        _buildSwitchTile(
          context,
          icon: Icons.discount_outlined,
          title: 'Offers & Promotions',
          subtitle: 'Special deals and promotional offers',
          value: state.offerNotifications,
          onChanged: (v) {
            context.read<AppSettingsBloc>().add(OfferNotificationToggled(v));
          },
        ),
        _SettingsDivider(),
        _buildSwitchTile(
          context,
          icon: Icons.chat_outlined,
          title: 'Chat Messages',
          subtitle: 'New messages from sellers',
          value: state.chatNotifications,
          onChanged: (v) {
            context.read<AppSettingsBloc>().add(ChatNotificationToggled(v));
          },
        ),
        _SettingsDivider(),
        _buildSwitchTile(
          context,
          icon: Icons.volume_up_outlined,
          title: 'Notification Sound',
          subtitle: 'Play sound for notifications',
          value: state.notificationSound,
          onChanged: (v) {
            context.read<AppSettingsBloc>().add(NotificationSoundToggled(v));
          },
        ),
        _SettingsDivider(),
        _buildSwitchTile(
          context,
          icon: Icons.vibration_outlined,
          title: 'Vibration',
          subtitle: 'Vibrate on notifications',
          value: state.vibration,
          onChanged: (v) {
            context.read<AppSettingsBloc>().add(VibrationToggled(v));
          },
        ),
      ],
    );
  }

  Widget _buildAppearanceSection(BuildContext context, AppSettingsState state) {
    return _SettingsSection(
      title: 'Appearance',
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTileLabel(context, Icons.brightness_6_outlined, 'Theme'),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'light', label: Text('Light'), icon: Icon(Icons.light_mode_outlined)),
                  ButtonSegment(value: 'dark', label: Text('Dark'), icon: Icon(Icons.dark_mode_outlined)),
                  ButtonSegment(value: 'system', label: Text('System'), icon: Icon(Icons.settings_brightness_outlined)),
                ],
                selected: {state.theme},
                onSelectionChanged: (v) {
                  context.read<AppSettingsBloc>().add(ThemeChanged(v.first));
                },
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),
        _SettingsDivider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTileLabel(context, Icons.language_outlined, 'Language'),
              const SizedBox(height: 12),
              _buildLanguageDropdown(context, state),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageDropdown(BuildContext context, AppSettingsState state) {
    final languages = {
      'en': 'English',
      'ta': 'Tamil',
      'es': 'Spanish',
      'fr': 'French',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: languages.containsKey(state.language) ? state.language : 'en',
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: languages.entries.map((e) {
            return DropdownMenuItem(value: e.key, child: Text(e.value));
          }).toList(),
          onChanged: (v) {
            if (v != null) {
              context.read<AppSettingsBloc>().add(LanguageChanged(v));
            }
          },
        ),
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, AppSettingsState state) {
    return _SettingsSection(
      title: 'Account',
      children: [
        _buildDangerTile(
          context,
          icon: Icons.delete_forever_outlined,
          title: 'Delete Account',
          subtitle: 'Permanently delete your account and data',
          isLoading: state.isLoading,
          onTap: () => _showDeleteAccountDialog(context),
        ),
      ],
    );
  }

  Widget _buildSupportSection(BuildContext context, AppSettingsState state) {
    return _SettingsSection(
      title: 'Support',
      children: [
        _buildLinkTile(
          context,
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy',
          subtitle: 'How we handle your data',
          onTap: () => _openWebView(context, 'Privacy Policy'),
        ),
        _SettingsDivider(),
        _buildLinkTile(
          context,
          icon: Icons.description_outlined,
          title: 'Terms & Conditions',
          subtitle: 'Terms of service',
          onTap: () => _openWebView(context, 'Terms & Conditions'),
        ),
        _SettingsDivider(),
        _buildInfoTile(
          context,
          icon: Icons.info_outlined,
          title: 'App Version',
          subtitle: '1.0.0+1',
        ),
        _SettingsDivider(),
        _buildActionTile(
          context,
          icon: Icons.cleaning_services_outlined,
          title: 'Clear Cache',
          subtitle: 'Free up storage space',
          isLoading: state.isLoading,
          onTap: () {
            context.read<AppSettingsBloc>().add(const ClearCacheRequested());
          },
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildLinkTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: colorScheme.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_forever_outlined, size: 20, color: Colors.red),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: colorScheme.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
            else
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTileLabel(BuildContext context, IconData icon, String title) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    _deletePassword = '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This action is permanent. All your data will be deleted.',
                  style: TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                TextField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Enter password to confirm',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) {
                    setDialogState(() => _deletePassword = v);
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: _deletePassword.isEmpty
                ? null
                : () {
                    Navigator.pop(ctx);
                    context
                        .read<AppSettingsBloc>()
                        .add(DeleteAccountRequested(_deletePassword));
                  },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSnack(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _openWebView(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(title)),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Text(
                '$title\n\n'
                'Welcome to FoodGo. We are committed to protecting your privacy and providing a safe, seamless experience.\n\n'
                '1. Data Usage: Your personal information, saved addresses, and profile data are stored securely on Firebase cloud services and used solely to fulfill your food delivery orders.\n\n'
                '2. Account Security: You can update your profile, change address preferences, or delete your account at any time via App Settings.\n\n'
                '3. Contact Us: For support or questions regarding policies, reach out through the Help & Support section.',
                style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black87),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 10),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade500,
                  letterSpacing: 1.2,
                ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.withValues(alpha: 0.1),
      indent: 60,
      endIndent: 16,
    );
  }
}

class _StaggeredListItem extends StatefulWidget {
  final Widget child;
  final int index;

  const _StaggeredListItem({required this.child, required this.index});

  @override
  State<_StaggeredListItem> createState() => _StaggeredListItemState();
}

class _StaggeredListItemState extends State<_StaggeredListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: 80 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}



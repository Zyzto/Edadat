import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_settings_framework/flutter_settings_framework.dart';

/// Inline dummy dashboard used by the example account section.
class ExampleProfileDashboard extends ConsumerStatefulWidget {
  const ExampleProfileDashboard({
    super.key,
    required this.translate,
  });

  final String Function(String key) translate;

  @override
  ConsumerState<ExampleProfileDashboard> createState() =>
      _ExampleProfileDashboardState();
}

class _ExampleProfileDashboardState
    extends ConsumerState<ExampleProfileDashboard> {
  var _filter = 'all';
  var _backupOn = true;
  var _plusPlan = false;
  var _downloadsCleared = false;
  var _signinUnread = true;
  var _groupUnread = true;
  var _twoFactor = true;
  String? _recoveryEmail;
  var _phoneSession = true;
  var _tabletSession = true;
  var _browserSession = true;
  var _googleLinked = true;
  var _emailLinked = true;
  var _archivedRestored = false;

  String Function(String key) get _tr => widget.translate;

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> _confirm(String title) async {
    final t = _tr;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t('confirm')),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<void> _showText(String title, String body) {
    final t = _tr;
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t('confirm')),
          ),
        ],
      ),
    );
  }

  bool _show(String area) {
    if (_filter == 'all') return true;
    return switch (area) {
      'security' => _filter == 'security',
      'devices' => _filter == 'devices',
      _ => _filter == 'all',
    };
  }

  int get _sessionCount =>
      1 +
      (_phoneSession ? 1 : 0) +
      (_tabletSession ? 1 : 0) +
      (_browserSession ? 1 : 0);

  Widget _revokeButton(VoidCallback onPressed) {
    return IconButton(
      tooltip: _tr('session_sign_out_device'),
      style: IconButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.error,
      ),
      icon: const Icon(Icons.logout),
      onPressed: onPressed,
    );
  }

  Widget _sessionGroup(BuildContext context, {required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      ),
    );
  }

  Future<void> _revokeSession({
    required String nameKey,
    required VoidCallback apply,
  }) async {
    if (!await _confirm(_tr('session_revoke'))) return;
    apply();
    _snack(
      _tr('session_revoked_named').replaceAll('{device}', _tr(nameKey)),
    );
  }

  Future<void> _revokeAllOthers(void Function(VoidCallback fn) sync) async {
    if (!await _confirm(_tr('session_sign_out_all_confirm'))) return;
    sync(() {
      _phoneSession = false;
      _tabletSession = false;
      _browserSession = false;
    });
    _snack(_tr('session_revoked_all'));
  }

  Future<void> _openSessionsSheet() async {
    final t = _tr;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheet) {
            void sync(VoidCallback fn) {
              setState(fn);
              setSheet(() {});
            }

            final others = <Widget>[
              if (_phoneSession)
                ProfileSessionTile(
                  leading: const Icon(Icons.smartphone_outlined),
                  title: Text(t('session_phone')),
                  subtitle: Text(t('session_phone_sub')),
                  trailing: _revokeButton(
                    () => _revokeSession(
                      nameKey: 'session_phone',
                      apply: () => sync(() => _phoneSession = false),
                    ),
                  ),
                ),
              if (_tabletSession)
                ProfileSessionTile(
                  leading: const Icon(Icons.tablet_mac_outlined),
                  title: Text(t('session_tablet')),
                  subtitle: Text(t('session_tablet_sub')),
                  trailing: _revokeButton(
                    () => _revokeSession(
                      nameKey: 'session_tablet',
                      apply: () => sync(() => _tabletSession = false),
                    ),
                  ),
                ),
              if (_browserSession)
                ProfileSessionTile(
                  leading: const Icon(Icons.language),
                  title: Text(t('session_browser')),
                  subtitle: Text(t('session_browser_sub')),
                  trailing: _revokeButton(
                    () => _revokeSession(
                      nameKey: 'session_browser',
                      apply: () => sync(() => _browserSession = false),
                    ),
                  ),
                ),
            ];

            final theme = Theme.of(sheetContext);
            final labelStyle = theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurfaceVariant,
            );

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.68,
              minChildSize: 0.42,
              maxChildSize: 0.94,
              builder: (sheetContext, scrollController) {
                return Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t('header_sessions'),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              t('session_sheet_hint').replaceAll(
                                '{count}',
                                '$_sessionCount',
                              ),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
                              child: Text(
                                t('session_current'),
                                style: labelStyle,
                              ),
                            ),
                            _sessionGroup(
                              sheetContext,
                              children: [
                                ProfileSessionTile(
                                  leading: const Icon(Icons.laptop_outlined),
                                  title: Text(t('session_laptop')),
                                  subtitle: Text(t('session_laptop_sub')),
                                  current: true,
                                  badge: Text(t('session_current')),
                                  onTap: () =>
                                      _snack(t('session_current_hint')),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                              child: Text(t('session_others'), style: labelStyle),
                            ),
                            if (others.isEmpty)
                              _sessionGroup(
                                sheetContext,
                                children: [
                                  ProfilePlaceholder(
                                    kind: ProfilePlaceholderKind.empty,
                                    icon: const Icon(
                                      Icons.devices_other_outlined,
                                    ),
                                    title: Text(t('session_others_empty')),
                                    message: Text(
                                      t('session_others_empty_body'),
                                    ),
                                  ),
                                ],
                              )
                            else
                              _sessionGroup(sheetContext, children: others),
                          ],
                        ),
                      ),
                      SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (others.isNotEmpty) ...[
                                OutlinedButton(
                                  onPressed: () => _revokeAllOthers(sync),
                                  child: Text(t('session_sign_out_all')),
                                ),
                                const SizedBox(height: 8),
                              ],
                              FilledButton(
                                onPressed: () => Navigator.pop(sheetContext),
                                child: Text(t('session_done')),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = _tr;
    final unreadCount = (_signinUnread ? 1 : 0) + (_groupUnread ? 1 : 0);
    final deviceCount = _sessionCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_show('all') || _show('devices')) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _showText(t('hero_caption'), t('hero_footnote')),
              child: ProfileHeroMetric(
                caption: t('hero_caption'),
                status: t('hero_status'),
                value: t('hero_value'),
                footnote: t('hero_footnote'),
                tone: ProfileHeroTone.positive,
              ),
            ),
          ),
          ProfileKpiStrip(
            items: [
              ProfileKpiItem(
                icon: Icons.devices_outlined,
                label: t('kpi_devices'),
                value: '$deviceCount',
                onTap: () => setState(() => _filter = 'devices'),
              ),
              ProfileKpiItem(
                icon: Icons.star_outline,
                label: t('kpi_shortcuts'),
                value: '2',
                onTap: () => _snack(t('details')),
              ),
              ProfileKpiItem(
                icon: Icons.archive_outlined,
                label: t('kpi_archived'),
                value: _archivedRestored ? '1' : '0',
                onTap: () => _snack(t('header_archived')),
              ),
              ProfileKpiItem(
                icon: Icons.drafts_outlined,
                label: t('kpi_drafts'),
                value: '3',
                onTap: () => _snack(t('details')),
              ),
              ProfileKpiItem(
                icon: Icons.notifications_outlined,
                label: t('kpi_unread'),
                value: '$unreadCount',
                onTap: () => setState(() {
                  _signinUnread = false;
                  _groupUnread = false;
                  _filter = 'security';
                }),
              ),
            ],
          ),
        ],
        if (_show('all')) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: _DemoBudgetPanel(
              onTap: () => _showText(t('budget_photos'), t('budget_manage')),
              child: ProfileBudgetCard(
                title: Text(t('budget_photos')),
                caption: Text(t('budget_caption')),
                limit: SettingsLtr(child: Text(t('budget_limit_near'))),
                spent: SettingsLtr(child: Text(t('budget_spent_near'))),
                progress: 0.84,
                attention: ProfileBudgetAttention.near,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: _DemoBudgetPanel(
              onTap: () {
                setState(() => _downloadsCleared = true);
                _snack(t('budget_cleared'));
              },
              child: ProfileBudgetCard(
                title: Text(t('budget_downloads')),
                caption: Text(t('budget_caption')),
                limit: SettingsLtr(child: Text(t('budget_limit_over'))),
                spent: SettingsLtr(
                  child: Text(
                    _downloadsCleared
                        ? t('budget_spent_cleared')
                        : t('budget_spent_over'),
                  ),
                ),
                progress: _downloadsCleared ? 0.2 : 1.2,
                attention: _downloadsCleared
                    ? ProfileBudgetAttention.none
                    : ProfileBudgetAttention.over,
              ),
            ),
          ),
        ],
        if (_show('all') || _show('security')) ...[
          ProfileNotificationTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: const Icon(Icons.login_outlined, size: 18),
            ),
            title: Text(t('notif_signin')),
            subtitle: Text(t('notif_signin_body')),
            unread: _signinUnread,
            onTap: () {
              setState(() => _signinUnread = false);
              _snack(t('notif_marked'));
            },
          ),
          ProfileNotificationGroup(
            leading: CircleAvatar(
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Icon(Icons.shield_outlined, size: 18),
            ),
            title: Text(t('notif_grouped')),
            subtitle: Text(t('notif_grouped_sub')),
            unread: _groupUnread,
            footer: ListTile(
              dense: true,
              leading: const Icon(Icons.open_in_new, size: 18),
              title: Text(t('notif_footer')),
              onTap: () {
                setState(() => _groupUnread = false);
                _showText(t('header_security'), t('notif_footer'));
              },
            ),
            children: [
              ProfileNotificationTile(
                dense: true,
                title: Text(t('notif_child_a')),
                subtitle: Text(t('notif_child_a_body')),
                onTap: () {
                  setState(() => _groupUnread = false);
                  _snack(t('notif_open'));
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: ProfileStatusBanner(
              tone: _backupOn
                  ? ProfileBannerTone.success
                  : ProfileBannerTone.warning,
              title: Text(_backupOn ? t('banner_backup') : t('banner_off')),
              message: Text(
                _backupOn ? t('banner_backup_body') : t('banner_off_body'),
              ),
              action: TextButton(
                onPressed: () => setState(() => _backupOn = !_backupOn),
                child: Text(_backupOn ? t('banner_pause') : t('banner_resume')),
              ),
            ),
          ),
        ],
        if (_show('all')) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: ProfilePlanCard(
              name: Text(_plusPlan ? t('plan_plus') : t('plan_name')),
              status: Text(
                _plusPlan ? t('plan_plus_status') : t('plan_status'),
              ),
              footnote: Text(
                _plusPlan ? t('plan_plus_footnote') : t('plan_footnote'),
              ),
              action: FilledButton.tonal(
                onPressed: () => setState(() => _plusPlan = !_plusPlan),
                child: Text(t('plan_change')),
              ),
            ),
          ),
        ],
        ProfileChipRow(
          chips: [
            ProfileChip(
              label: Text(t('chip_all')),
              selected: _filter == 'all',
              onTap: () => setState(() => _filter = 'all'),
            ),
            ProfileChip(
              label: Text(t('chip_security')),
              selected: _filter == 'security',
              onTap: () => setState(() => _filter = 'security'),
            ),
            ProfileChip(
              label: Text(t('chip_devices')),
              selected: _filter == 'devices',
              onTap: () => setState(() => _filter = 'devices'),
            ),
          ],
        ),
        if (_show('all')) ...[
          const SizedBox(height: 12),
          ProfileStatGrid(
            items: [
              ProfileStatItem(
                icon: Icons.tune,
                label: Text(t('stat_settings')),
                value: const Text('12'),
              ),
              ProfileStatItem(
                icon: Icons.language,
                label: Text(t('stat_languages')),
                value: const Text('2'),
              ),
            ],
          ),
          ProfileCopyRow(
            label: Text(t('copy_account_id')),
            value: const SettingsLtr(child: Text('ada-1042')),
            copyTooltip: t('copy_tooltip'),
            onCopy: () {
              Clipboard.setData(const ClipboardData(text: 'ada-1042'));
              _snack(t('copied'));
            },
          ),
          ProfileSectionHeader(title: Text(t('header_activity'))),
          ProfileTimelineTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: Text(t('timeline_theme')),
            subtitle: Text(t('timeline_theme_body')),
            time: Text(t('timeline_theme_time')),
            onTap: () => _showText(t('timeline_theme'), t('timeline_theme_body')),
          ),
          ProfileTimelineTile(
            leading: const Icon(Icons.ios_share_outlined),
            title: Text(t('timeline_export')),
            subtitle: Text(t('timeline_export_body')),
            time: Text(t('timeline_export_time')),
            onTap: () =>
                _showText(t('timeline_export'), t('timeline_export_body')),
          ),
        ],
        if (_show('all') || _show('security')) ...[
          ProfileSectionHeader(title: Text(t('header_security'))),
          ProfileSecurityTile(
            leading: const Icon(Icons.phonelink_lock_outlined),
            title: Text(t('security_2fa')),
            subtitle: Text(_twoFactor ? t('security_2fa_on') : t('two_fa_off')),
            ok: _twoFactor,
            onTap: () async {
              final next = !_twoFactor;
              if (await _confirm(
                next ? t('two_fa_turn_on') : t('two_fa_turn_off'),
              )) {
                setState(() => _twoFactor = next);
              }
            },
          ),
          ProfileSecurityTile(
            leading: const Icon(Icons.mark_email_unread_outlined),
            title: Text(t('security_recovery')),
            subtitle: Text(_recoveryEmail ?? t('security_recovery_missing')),
            ok: _recoveryEmail != null,
            onTap: () async {
              final controller = TextEditingController(
                text: _recoveryEmail ?? '',
              );
              final next = await showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(t('recovery_prompt')),
                  content: TextField(
                    controller: controller,
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(hintText: t('recovery_hint')),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(t('cancel')),
                    ),
                    FilledButton(
                      onPressed: () =>
                          Navigator.pop(context, controller.text.trim()),
                      child: Text(t('confirm')),
                    ),
                  ],
                ),
              );
              controller.dispose();
              if (next != null && next.isNotEmpty) {
                setState(() => _recoveryEmail = next);
                _snack(t('recovery_saved'));
              }
            },
          ),
        ],
        if (_show('all') || _show('devices')) ...[
          ProfileSectionHeader(
            title: Text(t('header_sessions')),
            trailing: TextButton(
              onPressed: _openSessionsSheet,
              child: Text(t('session_see_all')),
            ),
          ),
          ProfileSessionTile(
            leading: const Icon(Icons.laptop_outlined),
            title: Text(t('session_laptop')),
            subtitle: Text(t('session_laptop_sub')),
            current: true,
            badge: Text(t('session_current')),
            onTap: _openSessionsSheet,
          ),
          if (_phoneSession)
            ProfileSessionTile(
              leading: const Icon(Icons.smartphone_outlined),
              title: Text(t('session_phone')),
              subtitle: Text(t('session_phone_sub')),
              trailing: _revokeButton(
                () => _revokeSession(
                  nameKey: 'session_phone',
                  apply: () => setState(() => _phoneSession = false),
                ),
              ),
              onTap: () => _openSessionsSheet(),
            ),
        ],
        if (_show('all') || _show('security')) ...[
          ProfileSectionHeader(title: Text(t('header_linked'))),
          ProfileLinkedAccountTile(
            leading: const Icon(Icons.g_mobiledata),
            title: Text(t('linked_google')),
            connected: _googleLinked,
            status: Text(
              _googleLinked ? t('linked_connected') : t('linked_disconnected'),
            ),
            onTap: () => setState(() => _googleLinked = !_googleLinked),
          ),
          ProfileLinkedAccountTile(
            leading: const Icon(Icons.mail_outline),
            title: Text(t('linked_email')),
            connected: _emailLinked,
            status: Text(
              _emailLinked ? t('linked_connected') : t('linked_disconnected'),
            ),
            onTap: () => setState(() => _emailLinked = !_emailLinked),
          ),
        ],
        if (_show('all')) ...[
          ProfileSectionHeader(title: Text(t('header_archived'))),
          if (!_archivedRestored)
            ProfilePlaceholder(
              kind: ProfilePlaceholderKind.empty,
              icon: const Icon(Icons.inventory_2_outlined),
              title: Text(t('empty_archived')),
              message: Text(t('empty_archived_body')),
              action: TextButton(
                onPressed: () => setState(() => _archivedRestored = true),
                child: Text(t('archived_restore')),
              ),
            )
          else
            ProfileActionTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: Text(t('archived_item')),
              subtitle: Text(t('archived_item_body')),
              onTap: () => setState(() => _archivedRestored = false),
            ),
          ProfileSectionHeader(title: Text(t('header_account_actions'))),
          ProfileActionTile(
            leading: const Icon(Icons.ios_share),
            title: Text(t('action_export')),
            onTap: () async {
              final payload = jsonEncode(ref.settings.controller.exportAll());
              await Clipboard.setData(ClipboardData(text: payload));
              if (mounted) _snack(t('copied'));
            },
          ),
          ProfileActionTile(
            leading: const Icon(Icons.logout),
            title: Text(t('action_sign_out')),
            destructive: true,
            onTap: () async {
              if (await _confirm(t('sign_out_confirm'))) {
                _snack(t('signed_out'));
              }
            },
          ),
        ],
      ],
    );
  }
}

class _DemoBudgetPanel extends StatelessWidget {
  const _DemoBudgetPanel({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final panel = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
      ),
      child: child,
    );
    if (onTap == null) return panel;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: panel,
      ),
    );
  }
}

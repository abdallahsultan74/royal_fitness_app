import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../../core/config/build_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/notifications_repository.dart';

class UserNotificationsPage extends StatefulWidget {
  const UserNotificationsPage({super.key});

  @override
  State<UserNotificationsPage> createState() => _UserNotificationsPageState();
}

class _UserNotificationsPageState extends State<UserNotificationsPage> {
  final _repo = NotificationsRepository();
  String _tab = 'inbox';

  /// One stream per tab — avoid creating new Realtime subscriptions on every build.
  late final Stream<List<UserNotificationItem>> _inboxStream = _repo.watchInbox();
  late final Stream<List<UserNotificationItem>> _sentStream = _repo.watchSent();

  // Reuse controllers across sheet openings; dispose with the page to avoid
  // "used after being disposed" during route teardown.
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _bodyCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _compose() async {
    final recipients = await _repo.listStaffRecipients();
    if (!mounted) return;

    String? selectedId;
    String roleFilter = 'admin';
    _titleCtrl.clear();
    _bodyCtrl.clear();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx2, setLocal) {
            final viewInsets = MediaQuery.viewInsetsOf(ctx2);
            final normalizedRole = roleFilter.trim().toLowerCase();
            final filtered = recipients.where((r) {
              final rr = (r['role']?.toString() ?? '').trim().toLowerCase();
              return rr == normalizedRole;
            }).toList();
            if (selectedId != null && !filtered.any((r) => r['id']?.toString() == selectedId)) {
              selectedId = null;
            }
            return Padding(
              padding: EdgeInsets.only(bottom: viewInsets.bottom),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Material(
                  color: AppColors.emeraldDark,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  clipBehavior: Clip.antiAlias,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.sizeOf(ctx2).height * 0.92,
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: AppColors.creamDim.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'notifications_compose'.tr(),
                                  style: const TextStyle(
                                    color: AppColors.textCream,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.of(ctx2).pop(),
                                icon: const Icon(Icons.close, color: AppColors.creamDim),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SegmentedButton<String>(
                            segments: [
                              ButtonSegment(value: 'admin', label: Text('notifications_role_admin'.tr())),
                              ButtonSegment(value: 'coach', label: Text('notifications_role_coach'.tr())),
                            ],
                            selected: {roleFilter},
                            onSelectionChanged: (s) => setLocal(() => roleFilter = s.first),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            key: ValueKey<String>(roleFilter),
                            initialValue: selectedId,
                            dropdownColor: AppColors.emeraldDark,
                            decoration: InputDecoration(
                              labelText: 'notifications_to'.tr(),
                              labelStyle: const TextStyle(color: AppColors.creamDim),
                            ),
                            items: filtered.map((r) {
                              final role = (r['role']?.toString() ?? 'staff');
                              final name = (r['name']?.toString() ?? r['email']?.toString() ?? 'Staff');
                              return DropdownMenuItem(
                                value: r['id']?.toString(),
                                child: Text('$name · $role', style: const TextStyle(color: AppColors.textCream)),
                              );
                            }).toList(),
                            onChanged: (v) => setLocal(() => selectedId = v),
                          ),
                          if (filtered.isEmpty) ...[
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'notifications_no_recipients'.tr(),
                                style: const TextStyle(color: AppColors.creamDim, fontSize: 12),
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          TextField(
                            controller: _titleCtrl,
                            style: const TextStyle(color: AppColors.textCream),
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'notifications_title_optional'.tr(),
                              labelStyle: const TextStyle(color: AppColors.creamDim),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _bodyCtrl,
                            style: const TextStyle(color: AppColors.textCream),
                            minLines: 3,
                            maxLines: 8,
                            textInputAction: TextInputAction.newline,
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(
                              labelText: 'notifications_message'.tr(),
                              labelStyle: const TextStyle(color: AppColors.creamDim),
                              alignLabelWithHint: true,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.of(ctx2).pop(),
                                  child: Text('common_cancel'.tr(), style: const TextStyle(color: AppColors.creamDim)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.accentGold,
                                    foregroundColor: AppColors.emeraldDark,
                                  ),
                                  onPressed: () async {
                                    if (selectedId == null) return;
                                    final body = _bodyCtrl.text.trim();
                                    if (body.isEmpty) return;
                                    try {
                                      await _repo.sendMessageToStaff(
                                        staffUserId: selectedId!,
                                        body: body,
                                        title: _titleCtrl.text,
                                      );
                                      if (!ctx2.mounted) return;
                                      Navigator.of(ctx2).pop();
                                      // SnackBar after sheet route is gone — avoids framework assertions during route teardown.
                                      SchedulerBinding.instance.addPostFrameCallback((_) {
                                        if (!mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('notifications_sent'.tr())),
                                        );
                                      });
                                    } catch (e) {
                                      if (!mounted) return;
                                      SchedulerBinding.instance.addPostFrameCallback((_) {
                                        if (!mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(e.toString())),
                                        );
                                      });
                                    }
                                  },
                                  child: Text('notifications_send'.tr()),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8 + MediaQuery.paddingOf(ctx2).bottom),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _list(Stream<List<UserNotificationItem>> stream) {
    return StreamBuilder<List<UserNotificationItem>>(
      stream: stream,
      builder: (context, snap) {
        final items = snap.data ?? const <UserNotificationItem>[];
        if (items.isEmpty) {
          return Center(
            child: Text('notifications_empty'.tr(), style: const TextStyle(color: AppColors.creamDim)),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final it = items[i];
            final unread = it.readAt == null;
            return InkWell(
              onTap: unread ? () => _repo.markRead(it.id) : null,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(0, 0, 0, 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: unread ? AppColors.accentGold.withValues(alpha: 0.35) : AppColors.glassBorder,
                  ),
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            it.title?.trim().isNotEmpty == true
                                ? it.title!
                                : (it.type == 'message' ? 'notifications_message_label'.tr() : 'notifications_notification_label'.tr()),
                            style: TextStyle(
                              color: AppColors.textCream,
                              fontWeight: unread ? FontWeight.w700 : FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          DateFormat('yyyy-MM-dd HH:mm').format(it.createdAt.toLocal()),
                          style: const TextStyle(color: AppColors.creamDim, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(it.body, style: const TextStyle(color: AppColors.creamDim, fontSize: 13)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final clientDelivery = BuildConfig.clientDelivery;
    final isInbox = _tab == 'inbox';
    return Scaffold(
      appBar: AppBar(
        title: Text('settings_notifications'.tr()),
        actions: [
          if (!clientDelivery && BuildConfig.staffMessagingEnabled)
            IconButton(
              onPressed: _compose,
              icon: const Icon(Icons.edit, color: AppColors.accentGold),
              tooltip: 'notifications_compose'.tr(),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'inbox', label: Text('notifications_inbox'.tr())),
                if (!clientDelivery) ButtonSegment(value: 'sent', label: Text('notifications_sent_tab'.tr())),
              ],
              selected: {_tab},
              onSelectionChanged: clientDelivery ? null : (s) => setState(() => _tab = s.first),
            ),
          ),
          Expanded(
            child: isInbox ? _list(_inboxStream) : _list(_sentStream),
          ),
        ],
      ),
    );
  }
}


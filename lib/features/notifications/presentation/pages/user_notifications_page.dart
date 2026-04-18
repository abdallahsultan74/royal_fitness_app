import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

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

  Future<void> _compose() async {
    final recipients = await _repo.listStaffRecipients();
    if (!mounted) return;

    String? selectedId;
    String roleFilter = 'admin';
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        final viewInsets = MediaQuery.of(ctx).viewInsets;
        return AnimatedPadding(
          padding: EdgeInsets.only(bottom: viewInsets.bottom),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: AlertDialog(
            backgroundColor: AppColors.emeraldDark,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            scrollable: true,
            title: Text('notifications_compose'.tr(), style: const TextStyle(color: AppColors.textCream)),
            content: StatefulBuilder(
              builder: (ctx2, setLocal) {
                final normalizedRole = roleFilter.trim().toLowerCase();
                final filtered = recipients.where((r) {
                  final rr = (r['role']?.toString() ?? '').trim().toLowerCase();
                  return rr == normalizedRole;
                }).toList();
                if (selectedId != null && !filtered.any((r) => r['id']?.toString() == selectedId)) {
                  selectedId = null;
                }
                return ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                        controller: titleCtrl,
                        style: const TextStyle(color: AppColors.textCream),
                        decoration: InputDecoration(
                          labelText: 'notifications_title_optional'.tr(),
                          labelStyle: const TextStyle(color: AppColors.creamDim),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: bodyCtrl,
                        style: const TextStyle(color: AppColors.textCream),
                        minLines: 3,
                        maxLines: 6,
                        decoration: InputDecoration(
                          labelText: 'notifications_message'.tr(),
                          labelStyle: const TextStyle(color: AppColors.creamDim),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('common_cancel'.tr(), style: const TextStyle(color: AppColors.creamDim)),
            ),
            TextButton(
              onPressed: () async {
                if (selectedId == null) return;
                final body = bodyCtrl.text.trim();
                if (body.isEmpty) return;
                try {
                  await _repo.sendMessageToStaff(
                    staffUserId: selectedId!,
                    body: body,
                    title: titleCtrl.text,
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('notifications_sent'.tr())),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
              child: Text('notifications_send'.tr(), style: const TextStyle(color: AppColors.accentGold)),
            ),
          ],
          ),
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
    final isInbox = _tab == 'inbox';
    return Scaffold(
      appBar: AppBar(
        title: Text('settings_notifications'.tr()),
        actions: [
          IconButton(
            onPressed: _compose,
            icon: const Icon(Icons.edit, color: AppColors.accentGold),
            tooltip: 'notifications_compose'.tr(),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'inbox', label: Text('notifications_inbox'.tr())),
                ButtonSegment(value: 'sent', label: Text('notifications_sent_tab'.tr())),
              ],
              selected: {_tab},
              onSelectionChanged: (s) => setState(() => _tab = s.first),
            ),
          ),
          Expanded(
            child: isInbox ? _list(_repo.watchInbox()) : _list(_repo.watchSent()),
          ),
        ],
      ),
    );
  }
}


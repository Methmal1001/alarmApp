import 'package:flutter/material.dart';
import '../models/clock_alarm.dart';
import 'confirm_delete_dialog.dart';

class ClockAlarmTile extends StatelessWidget {
  const ClockAlarmTile({
    super.key,
    required this.alarm,
    required this.onToggle,
    this.onTap,
    this.onDelete,
  });

  final ClockAlarm alarm;
  final ValueChanged<bool> onToggle;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeText =
        '${alarm.hour.toString().padLeft(2, '0')}:${alarm.minute.toString().padLeft(2, '0')}';
    final label = alarm.label.isEmpty ? 'Alarm at $timeText' : alarm.label;

    return Dismissible(
      key: ValueKey('alarm_${alarm.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => confirmDelete(context, itemLabel: label),
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.alarm_rounded, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          timeText,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${alarm.label.isEmpty ? "Alarm" : alarm.label} • ${alarm.repeatLabel()}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    color: Colors.grey.shade400,
                    onPressed: onTap,
                  ),
                  Switch(value: alarm.isActive, onChanged: onToggle),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

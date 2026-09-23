import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/clock_alarm.dart';
import '../state/app_state.dart';

class SetAlarmScreen extends StatefulWidget {
  const SetAlarmScreen({super.key, this.existing});

  final ClockAlarm? existing;

  @override
  State<SetAlarmScreen> createState() => _SetAlarmScreenState();
}

class _SetAlarmScreenState extends State<SetAlarmScreen> {
  late TimeOfDay _time;
  late TextEditingController _labelController;
  late Set<int> _repeatDays;

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _time = existing != null ? TimeOfDay(hour: existing.hour, minute: existing.minute) : TimeOfDay.now();
    _labelController = TextEditingController(text: existing?.label ?? '');
    _repeatDays = {...?existing?.repeatDays};
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  void _save() {
    final state = context.read<AppState>();
    final existing = widget.existing;
    final alarm = ClockAlarm(
      id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      label: _labelController.text.trim(),
      hour: _time.hour,
      minute: _time.minute,
      repeatDays: _repeatDays,
      isActive: existing?.isActive ?? true,
    );
    if (existing == null) {
      state.addAlarm(alarm);
    } else {
      state.updateAlarm(alarm);
    }
    Navigator.of(context).pop();
  }

  void _delete() {
    context.read<AppState>().removeAlarm(widget.existing!.id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'Set Alarm' : 'Edit Alarm'),
        actions: [
          if (widget.existing != null)
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: _delete),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: GestureDetector(
              onTap: _pickTime,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 28),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Text(
                      _time.format(context),
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('Tap to change time', style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _labelController,
            decoration: InputDecoration(
              labelText: 'Label',
              hintText: 'e.g. Wake up, Gym, Study',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Repeat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final weekday = index + 1;
              final selected = _repeatDays.contains(weekday);
              return GestureDetector(
                onTap: () => setState(() {
                  if (selected) {
                    _repeatDays.remove(weekday);
                  } else {
                    _repeatDays.add(weekday);
                  }
                }),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: selected ? theme.colorScheme.primary : Colors.white,
                  child: Text(
                    _dayLabels[index],
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _repeatDays.isEmpty ? 'Rings once' : 'Repeats on selected days',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12.5),
            ),
          ),
          const SizedBox(height: 32),
          FilledButton(
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            onPressed: _save,
            child: const Text('Save Alarm'),
          ),
        ],
      ),
    );
  }
}

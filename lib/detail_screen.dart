import 'package:flutter/material.dart';

import 'habit.dart';

class HabitDetailScreen extends StatefulWidget {
  final Habit habit;
  final VoidCallback onDelete;

  const HabitDetailScreen({
    super.key,
    required this.habit,
    required this.onDelete,
  });

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  static const int totalSeconds = 300; // 5-minute Pomodoro session
  bool _isRunning = false;

  // Stream requirement: Emits sequential integer values every 1 second
  Stream<int> _focusStream(int seconds) {
    return Stream.periodic(
      const Duration(seconds: 1),
      (tick) => seconds - (tick + 1),
    ).take(seconds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(widget.habit.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            tooltip: 'Delete Habit',
            onPressed: () {
              widget.onDelete();
              Navigator.pop(
                context,
              ); // Basic Navigation: Pop back to previous screen
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MetricBadge(
                  label: '🔥 ${widget.habit.streak} Day Streak',
                  color: Colors.orangeAccent,
                ),
                const SizedBox(width: 10),
                MetricBadge(
                  label: widget.habit.priority.name.toUpperCase(),
                  color: Colors.indigoAccent,
                ),
              ],
            ),
            const SizedBox(height: 32),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Monthly Completion (${DateTime.now().month}/${DateTime.now().year})',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildMonthGrid(),

            const SizedBox(height: 40),

            // Live Focus Timer using StreamBuilder
            if (!_isRunning) ...[
              const Text(
                'Focus Sprint',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Activate a 5-minute dedicated block for this habit.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, fontSize: 13),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => setState(() => _isRunning = true),
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Start Focus Block'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigoAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ] else ...[
              StreamBuilder<int>(
                stream: _focusStream(totalSeconds),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator(
                      color: Colors.indigoAccent,
                    );
                  }
                  final remaining = snapshot.data!;
                  final minutes = (remaining ~/ 60).toString().padLeft(2, '0');
                  final seconds = (remaining % 60).toString().padLeft(2, '0');
                  final progress = remaining / totalSeconds;

                  if (remaining <= 0) {
                    return const Text(
                      'Session Completed! 🎉',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 180,
                        height: 180,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 8,
                          backgroundColor: Colors.white12,
                          color: Colors.indigoAccent,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$minutes:$seconds',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'REMAINING',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => setState(() => _isRunning = false),
                child: const Text(
                  'Cancel Session',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMonthGrid() {
    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: List.generate(daysInMonth, (index) {
          final day = index + 1;
          final dateStr =
              '${now.year}-${now.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
          final bool isDone = widget.habit.completedDates.contains(dateStr);
          final bool isToday = day == now.day;

          return HeatmapCell(day: day, isDone: isDone, isToday: isToday);
        }),
      ),
    );
  }
}

// Stateless widget for badge display
class MetricBadge extends StatelessWidget {
  final String label;
  final Color color;

  const MetricBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// Stateless widget for rendering individual calendar blocks
class HeatmapCell extends StatelessWidget {
  final int day;
  final bool isDone;
  final bool isToday;

  const HeatmapCell({
    super.key,
    required this.day,
    required this.isDone,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Day $day: ${isDone ? "Completed" : "Not Done"}',
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isDone ? const Color(0xFF22C55E) : const Color(0xFF334155),
          borderRadius: BorderRadius.circular(4),
          border: isToday ? Border.all(color: Colors.white, width: 1.5) : null,
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: 9,
              color: isDone ? Colors.white : Colors.white38,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

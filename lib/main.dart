import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'habit.dart';
import 'detail_screen.dart';

void main() {
  runApp(const HabitPulseApp());
}

class HabitPulseApp extends StatelessWidget {
  const HabitPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HabitPulse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Colors.indigoAccent,
          surface: Color(0xFF1E293B),
        ),
      ),
      home: const MainGate(),
    );
  }
}

// Controls entry flow based on stored credentials
class MainGate extends StatefulWidget {
  const MainGate({super.key});

  @override
  State<MainGate> createState() => _MainGateState();
}

class _MainGateState extends State<MainGate> {
  String? _username;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('user_name');
      _isLoading = false;
    });
  }

  void _setUser(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    setState(() => _username = name);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _username == null
        ? OnboardingScreen(onSaved: _setUser)
        : DashboardScreen(username: _username!);
  }
}

// Onboarding: Sets up new account profile
class OnboardingScreen extends StatefulWidget {
  final Function(String) onSaved;
  const OnboardingScreen({super.key, required this.onSaved});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController();

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      widget.onSaved(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.bolt_rounded,
                size: 72,
                color: Colors.indigoAccent,
              ),
              const SizedBox(height: 16),
              const Text(
                'Welcome to HabitPulse',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Build discipline, track streaks, and master daily routines.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60),
              ),
              const SizedBox(height: 36),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'What is your name?',
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigoAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Primary stateful dashboard screen
class DashboardScreen extends StatefulWidget {
  final String username;
  const DashboardScreen({super.key, required this.username});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Habit> _habits = [];

  String get _todayString {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('stored_habits');
    if (data != null) {
      setState(() {
        _habits = data.map((item) => Habit.fromJson(item)).toList();
        for (var h in _habits) {
          h.isCompleted = h.completedDates.contains(_todayString);
        }
      });
    } else {
      setState(() => _habits = []);
    }
  }

  Future<void> _persistHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _habits.map((h) => h.toJson()).toList();
    await prefs.setStringList('stored_habits', data);
  }

  // Futures Requirement: Asynchronous resolution returning parsed string
  Future<String> _fetchDailyQuote() async {
    await Future.delayed(const Duration(milliseconds: 650));
    return "Consistency is what transforms average into excellence.";
  }

  void _toggleHabit(int index) {
    setState(() {
      final habit = _habits[index];
      habit.isCompleted = !habit.isCompleted;

      if (habit.isCompleted) {
        if (!habit.completedDates.contains(_todayString)) {
          habit.completedDates.add(_todayString);
        }
        habit.streak += 1;
      } else {
        habit.completedDates.remove(_todayString);
        if (habit.streak > 0) habit.streak -= 1;
      }
    });
    _persistHabits();
  }

  void _deleteHabit(int index) {
    setState(() {
      _habits.removeAt(index);
    });
    _persistHabits();
  }

  void _showAddHabitDialog() {
    final controller = TextEditingController();
    HabitPriority selectedPriority = HabitPriority.medium;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Add New Habit',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'e.g. Read 20 pages, Code, Workout',
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Priority Level:',
                    style: TextStyle(color: Colors.white70),
                  ),
                  DropdownButton<HabitPriority>(
                    value: selectedPriority,
                    dropdownColor: const Color(0xFF1E293B),
                    items: HabitPriority.values.map((p) {
                      return DropdownMenuItem(
                        value: p,
                        child: Text(p.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => selectedPriority = val);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    setState(() {
                      _habits.add(
                        Habit(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: controller.text.trim(),
                          priority: selectedPriority,
                        ),
                      );
                    });
                    _persistHabits();
                    Navigator.pop(context); // Dismiss bottom modal
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigoAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Save Habit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedTodayCount = _habits.where((h) => h.isCompleted).length;
    final double completionRatio = _habits.isEmpty
        ? 0
        : completedTodayCount / _habits.length;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddHabitDialog,
        backgroundColor: Colors.indigoAccent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Habit', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi, ${widget.username} 👋',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Ready to hit your targets today?',
                        style: TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.indigoAccent.withOpacity(0.2),
                    child: Text(
                      widget.username.isNotEmpty
                          ? widget.username[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: Colors.indigoAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // FutureBuilder: Handles async quote fetch with waiting vs done states
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: FutureBuilder<String>(
                future: _fetchDailyQuote(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 48,
                      child: Center(child: LinearProgressIndicator()),
                    );
                  }
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lightbulb_outline,
                          color: Colors.indigoAccent,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            snapshot.data ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // GitHub-Style Activity Grid
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _buildAggregateHeatmap(),
            ),

            // Progress Summary Section
            if (_habits.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4F46E5), Color(0xFF3B82F6)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Today's Completion",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '$completedTodayCount / ${_habits.length}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: completionRatio,
                          minHeight: 6,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation(
                            Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 8.0,
              ),
              child: Text(
                _habits.isEmpty ? 'Your Dashboard' : "Your Habits",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            // Empty state vs active list
            Expanded(
              child: _habits.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.checklist_rounded,
                            size: 64,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No habits tracked yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Tap "New Habit" below to begin.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white38,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _habits.length,
                      itemBuilder: (context, index) {
                        final habit = _habits[index];
                        return HabitItemCard(
                          habit: habit,
                          onToggle: () => _toggleHabit(index),
                          onTap: () async {
                            // Basic Navigation: Push route to HabitDetailScreen
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HabitDetailScreen(
                                  habit: habit,
                                  onDelete: () => _deleteHabit(index),
                                ),
                              ),
                            );
                            setState(() {}); // Synchronize state on pop return
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAggregateHeatmap() {
    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Activity Map (${now.month}/${now.year})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.white70,
                ),
              ),
              const Row(
                children: [
                  Text(
                    'None ',
                    style: TextStyle(fontSize: 10, color: Colors.white38),
                  ),
                  _LegendBox(color: Color(0xFF334155)),
                  SizedBox(width: 3),
                  _LegendBox(color: Color(0xFF166534)),
                  SizedBox(width: 3),
                  _LegendBox(color: Color(0xFF22C55E)),
                  Text(
                    ' Done',
                    style: TextStyle(fontSize: 10, color: Colors.white38),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: List.generate(daysInMonth, (index) {
              final day = index + 1;
              final dateStr =
                  '${now.year}-${now.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

              int completionsOnDay = 0;
              for (var h in _habits) {
                if (h.completedDates.contains(dateStr)) completionsOnDay++;
              }

              Color cellColor = const Color(0xFF334155);
              if (_habits.isNotEmpty && completionsOnDay > 0) {
                cellColor = (completionsOnDay == _habits.length)
                    ? const Color(0xFF22C55E)
                    : const Color(0xFF166534);
              }

              final bool isToday = day == now.day;

              return Tooltip(
                message:
                    'Day $day: $completionsOnDay/${_habits.length} habits done',
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: cellColor,
                    borderRadius: BorderRadius.circular(4),
                    border: isToday
                        ? Border.all(color: Colors.white, width: 1.2)
                        : null,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _LegendBox extends StatelessWidget {
  final Color color;
  const _LegendBox({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

// Stateless presentation widget
class HabitItemCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const HabitItemCard({
    super.key,
    required this.habit,
    required this.onToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: habit.isCompleted
              ? Colors.indigoAccent.withOpacity(0.4)
              : Colors.white10,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: IconButton(
          icon: Icon(
            habit.isCompleted
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: habit.isCompleted ? Colors.indigoAccent : Colors.white38,
          ),
          onPressed: onToggle,
        ),
        title: Text(
          habit.title,
          style: TextStyle(
            color: habit.isCompleted ? Colors.white38 : Colors.white,
            decoration: habit.isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '🔥 ${habit.streak}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.orangeAccent,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.white24,
            ),
          ],
        ),
      ),
    );
  }
}

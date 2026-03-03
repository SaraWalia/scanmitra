import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scan_mitra/data/sample_events.dart';
import 'package:scan_mitra/models/event.dart';
import 'package:scan_mitra/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  runApp(const ScanMitraApp());
}

class ScanMitraApp extends StatelessWidget {
  const ScanMitraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScanMitra',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0E6D5D)),
        useMaterial3: true,
      ),
      home: const ItineraryPage(),
    );
  }
}

class ItineraryPage extends StatefulWidget {
  const ItineraryPage({super.key});

  @override
  State<ItineraryPage> createState() => _ItineraryPageState();
}

class _ItineraryPageState extends State<ItineraryPage> {
  late final List<Event> _events;
  int _scheduledReminders = 0;

  @override
  void initState() {
    super.initState();
    _events = List<Event>.from(sampleEvents)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    _scheduleAutomaticReminders();
  }

  Future<void> _scheduleAutomaticReminders() async {
    final count = await NotificationService.instance.scheduleAutomaticReminders(_events);
    if (!mounted) {
      return;
    }
    setState(() {
      _scheduledReminders = count;
    });
  }

  Future<void> _runQuickTest() async {
    final ok = await NotificationService.instance.scheduleQuickTest();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Test notification scheduled (5 seconds)'
              : 'Test notification is not available on this platform',
        ),
      ),
    );
  }

  Map<DateTime, List<Event>> _eventsByDay() {
    final grouped = <DateTime, List<Event>>{};
    for (final event in _events) {
      final key = DateTime(event.startTime.year, event.startTime.month, event.startTime.day);
      grouped.putIfAbsent(key, () => <Event>[]).add(event);
    }
    return grouped;
  }

  String _dateLabel(DateTime dt) => DateFormat('EEE, d MMM yyyy').format(dt);
  String _timeLabel(DateTime dt) => DateFormat('hh:mm a').format(dt);
  String _dateTimeLabel(DateTime dt) => DateFormat('EEE, d MMM yyyy • hh:mm a').format(dt);

  Widget _eventCard(Event event) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text('Time: ${_dateTimeLabel(event.startTime)}'),
            Text('Venue: ${event.venue}'),
            const SizedBox(height: 6),
            Text(event.description),
          ],
        ),
      ),
    );
  }

  Widget _dailyView() {
    final grouped = _eventsByDay();
    final days = grouped.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];
        final events = grouped[day]!;
        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_dateLabel(day), style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ...events.map(_eventCard),
            ],
          ),
        );
      },
    );
  }

  Widget _overallView() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: _events.length,
      separatorBuilder: (_, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final event = _events[index];
        return ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          title: Text(event.title),
          subtitle: Text('${_dateLabel(event.startTime)} • ${_timeLabel(event.startTime)}\n${event.venue}'),
          isThreeLine: true,
          trailing: const Icon(Icons.chevron_right),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Your Personalized Itinerary'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton(
                onPressed: _runQuickTest,
                child: const Text('Test in 5s'),
              ),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Daily Agenda'),
              Tab(text: 'Overall Trip'),
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Automatic reminders are enabled for 30 and 15 minutes before each event. '
                'Scheduled: $_scheduledReminders',
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _dailyView(),
                  _overallView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

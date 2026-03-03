import 'package:scan_mitra/models/event.dart';

final now = DateTime.now();

DateTime at(int dayOffset, int hour, int minute) {
  final base = DateTime(now.year, now.month, now.day).add(Duration(days: dayOffset));
  return DateTime(base.year, base.month, base.day, hour, minute);
}

final List<Event> sampleEvents = [
  Event(
    id: 'e1',
    title: 'Arrival and Registration',
    startTime: at(0, 9, 30),
    venue: 'Main Lobby Desk',
    description: 'Check-in, badge pickup, and welcome kit collection.',
  ),
  Event(
    id: 'e2',
    title: 'Executive Welcome Address',
    startTime: at(0, 11, 0),
    venue: 'Auditorium A',
    description: 'Leadership introduction and event overview.',
  ),
  Event(
    id: 'e3',
    title: 'Campus Innovation Tour',
    startTime: at(0, 14, 0),
    venue: 'Innovation Lab, 3rd Floor',
    description: 'Guided walkthrough of product demos and R&D stations.',
  ),
  Event(
    id: 'e4',
    title: 'Strategy Roundtable',
    startTime: at(1, 10, 30),
    venue: 'Conference Room 2',
    description: 'Discussion on roadmap priorities with company executives.',
  ),
  Event(
    id: 'e5',
    title: 'Partner Networking Lunch',
    startTime: at(1, 13, 0),
    venue: 'Cafeteria Hall',
    description: 'Networking session with leadership and cross-functional teams.',
  ),
  Event(
    id: 'e6',
    title: 'Closing and Departure Brief',
    startTime: at(2, 16, 0),
    venue: 'Auditorium B',
    description: 'Trip summary, next steps, and departure coordination.',
  ),
];

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gnunity/models/user_model.dart'; // User 모델
import 'package:table_calendar/table_calendar.dart';

class Event {
  final String title;
  final String clubName;
  final Color clubColor;
  final DateTime startDate;
  final DateTime endDate;
  Event({required this.title, required this.clubName, required this.clubColor, required this.startDate, required this.endDate});
}

class CalendarScreen extends StatefulWidget {
  final User currentUser; // User 객체
  const CalendarScreen({super.key, required this.currentUser});

  @override
  State<CalendarScreen> createState() => CalendarScreenState();
}

class CalendarScreenState extends State<CalendarScreen> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  List<Event> _events = [];
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final List<Color> _colorPalette = [Colors.lightBlue, Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.teal, Colors.pink, Colors.amber];
  final Map<String, Color> _clubColors = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    loadFirestoreEvents();
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  void loadFirestoreEvents() async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.currentUser.id).get();
    final userData = userDoc.data();
    if (userData == null) return;

    final List<String> joinedClubIds = List<String>.from(userData['joinedClubIds'] ?? []).where((id) => id.isNotEmpty).toList();
    List<Event> allEvents = [];

    for (int i = 0; i < joinedClubIds.length; i++) {
      final clubId = joinedClubIds[i];
      final clubColor = _clubColors.putIfAbsent(clubId, () => _colorPalette[i % _colorPalette.length]);
      final clubDoc = await FirebaseFirestore.instance.collection('clubs').doc(clubId).get();
      if (!clubDoc.exists) continue;
      final clubData = clubDoc.data()!;
      final clubName = clubData['name'] ?? '알 수 없는 동아리';

      final periodSnapshot = await clubDoc.reference.collection('posts').where('startDate', isNull: false).get();
      for (var doc in periodSnapshot.docs) {
        final data = doc.data();
        final startDate = (data['startDate'] as Timestamp).toDate();
        final endDate = data['endDate'] != null ? (data['endDate'] as Timestamp).toDate() : startDate;
        allEvents.add(Event(title: data['title'], clubName: clubName, clubColor: clubColor, startDate: startDate, endDate: endDate));
      }
    }
    if (mounted) { setState(() { _events = allEvents; _selectedEvents.value = _getEventsForDay(_selectedDay!); }); }
  }

  List<Event> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime.utc(day.year, day.month, day.day);
    return _events.where((event) {
      final start = DateTime.utc(event.startDate.year, event.startDate.month, event.startDate.day);
      final end = DateTime.utc(event.endDate.year, event.endDate.month, event.endDate.day);
      return (normalizedDay.isAtSameMomentAs(start) || normalizedDay.isAfter(start)) &&
          (normalizedDay.isAtSameMomentAs(end) || normalizedDay.isBefore(end));
    }).toList();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  Widget _buildCell(DateTime day, {required bool isSelected, required bool isToday}) {
    final eventsForDay = _getEventsForDay(day);
    const double maxBarAreaHeight = 15.0;
    const double maxBarHeight = 5.0;
    const int maxBarsToShow = 3;
    final int barsToRender = min(eventsForDay.length, maxBarsToShow);
    final double barHeight = barsToRender > 0 ? min(maxBarAreaHeight / barsToRender, maxBarHeight) : 0;

    return Container(
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: isSelected ? Border.all(color: Colors.deepPurple, width: 2.0) : null,
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text('${day.day}', style: TextStyle(fontWeight: isToday ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.deepPurple : null)),
            ),
          ),
          if (eventsForDay.isNotEmpty)
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: eventsForDay.take(barsToRender).map((event) {
                  final isStart = isSameDay(day, event.startDate);
                  final isEnd = isSameDay(day, event.endDate);
                  return Container(
                    height: barHeight,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.5),
                    decoration: BoxDecoration(color: event.clubColor, borderRadius: BorderRadius.horizontal(left: isStart ? const Radius.circular(4.0) : Radius.zero, right: isEnd ? const Radius.circular(4.0) : Radius.zero)),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar<Event>(
          locale: 'ko_KR', firstDay: DateTime.utc(2020, 1, 1), lastDay: DateTime.utc(2030, 12, 31), focusedDay: _focusedDay, rowHeight: 60,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) { if (!isSameDay(_selectedDay, selectedDay)) { setState(() { _selectedDay = selectedDay; _focusedDay = focusedDay; }); _selectedEvents.value = _getEventsForDay(selectedDay); } },
          eventLoader: _getEventsForDay,
          calendarStyle: const CalendarStyle(defaultDecoration: BoxDecoration(), weekendDecoration: BoxDecoration(), outsideDecoration: BoxDecoration(), todayDecoration: BoxDecoration(), selectedDecoration: BoxDecoration(), markerDecoration: BoxDecoration(color: Colors.transparent)),
          calendarBuilders: CalendarBuilders(
            selectedBuilder: (context, day, focusedDay) => _buildCell(day, isSelected: true, isToday: isSameDay(day, DateTime.now())),
            todayBuilder: (context, day, focusedDay) => _buildCell(day, isSelected: isSameDay(day, _selectedDay), isToday: true),
            defaultBuilder: (context, day, focusedDay) => _buildCell(day, isSelected: false, isToday: false),
            outsideBuilder: (context, day, focusedDay) => Opacity(opacity: 0.5, child: _buildCell(day, isSelected: false, isToday: false)),
          ),
          headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
        ),
        ValueListenableBuilder<List<Event>>(
          valueListenable: _selectedEvents,
          builder: (context, value, _) {
            if (value.isEmpty) return const Padding(padding: EdgeInsets.all(16.0), child: Center(child: Text('일정 없음')));
            return ListView.builder(
              padding: EdgeInsets.zero, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: value.length,
              itemBuilder: (context, index) {
                final event = value[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                  decoration: BoxDecoration(border: Border.all(color: event.clubColor), borderRadius: BorderRadius.circular(12.0)),
                  child: ListTile(title: Text('${event.title}_${event.clubName}'), leading: Icon(Icons.circle, color: event.clubColor, size: 12)),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
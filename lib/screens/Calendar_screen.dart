import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
// 달력에 표시될 이벤트

class Event {
  final String title;
  final String clubName;
  final Color clubColor;
  final DateTime startDate;
  final DateTime endDate;

  Event({
    required this.title,
    required this.clubName,
    required this.clubColor,
    required this.startDate,
    required this.endDate,
  });

  @override
  String toString() => '$title ($clubName)';
}
// '내 동아리' 탭 상단의 달력 위젯
class CalendarScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  const CalendarScreen({super.key, required this.currentUser});

  @override

  State<CalendarScreen> createState() => CalendarScreenState();
}


class CalendarScreenState extends State<CalendarScreen> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  List<Event> _events = [];
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // 미리 정해진 색상 팔레트
  final List<Color> _colorPalette = [
    Colors.lightBlue, Colors.redAccent, Colors.green, Colors.orangeAccent,
    Colors.purpleAccent, Colors.teal, Colors.pinkAccent, Colors.amber,
  ];
  final Map<String, Color> _clubColors = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    loadFirestoreEvents(); // 공개 함수 호출
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  // 가입한 모든 동아리의 일정/공지 데이터를 불러오는 함수
  void loadFirestoreEvents() async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.currentUser['id']).get();
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

      // 기간이 없는 공지사항 (작성일 기준)
      final announcementSnapshot = await clubDoc.reference.collection('posts')
          .where('isAnnouncement', isEqualTo: true).where('startDate', isNull: true).get();
      for (var doc in announcementSnapshot.docs) {
        final data = doc.data();
        final date = (data['createdAt'] as Timestamp).toDate();
        allEvents.add(Event(
          title: data['title'], clubName: clubName, clubColor: clubColor,
          startDate: date, endDate: date,
        ));
      }

      // 기간이 설정된 게시물 (기간 기준)
      final periodSnapshot = await clubDoc.reference.collection('posts')
          .where('startDate', isNull: false).get();
      for (var doc in periodSnapshot.docs) {
        final data = doc.data();
        final startDate = (data['startDate'] as Timestamp).toDate();
        final endDate = data['endDate'] != null ? (data['endDate'] as Timestamp).toDate() : startDate;

        allEvents.add(Event(
          title: data['title'], clubName: clubName, clubColor: clubColor,
          startDate: startDate, endDate: endDate,
        ));
      }
    }

    if (mounted) {
      setState(() {
        _events = allEvents;
        _selectedEvents.value = _getEventsForDay(_selectedDay!);
      });
    }
  }
// 특정 날짜에 해당하는 이벤트 목록 반환
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
// 달력의 각 날짜 셀을 그리는 함수
  Widget _buildCell(DateTime day, {required bool isSelected, required bool isToday}) {
    final eventsForDay = _getEventsForDay(day);
// 이벤트 막대 높이 동적 계산
    const double maxBarAreaHeight = 15.0;
    const double maxBarHeight = 5.0;
    const int maxBarsToShow = 3;
    final int barsToRender = (eventsForDay.length > maxBarsToShow) ? maxBarsToShow : eventsForDay.length;
    final double barHeight = barsToRender > 0 ? (maxBarAreaHeight / barsToRender
        < maxBarHeight ? maxBarAreaHeight / barsToRender : maxBarHeight) : 0;

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
              child: Text(
                '${day.day}',
                style: TextStyle(
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.deepPurple : null,
                ),
              ),
            ),
          ),
          if (eventsForDay.isNotEmpty)// 이벤트 막대
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
                    decoration: BoxDecoration(
                      color: event.clubColor,
                      borderRadius: BorderRadius.horizontal(
                        left: isStart ? const Radius.circular(4.0) : Radius.zero,
                        right: isEnd ? const Radius.circular(4.0) : Radius.zero,
                      ),
                    ),
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
      children: [// 달력 위젯
        TableCalendar<Event>(
          locale: 'ko_KR',
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          rowHeight: 60,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: _onDaySelected,
          eventLoader: _getEventsForDay,
          calendarStyle: const CalendarStyle(
            defaultDecoration: BoxDecoration(),
            weekendDecoration: BoxDecoration(),
            outsideDecoration: BoxDecoration(),
            todayDecoration: BoxDecoration(),
            selectedDecoration: BoxDecoration(),
            markerDecoration: BoxDecoration(color: Colors.transparent),
          ),
          calendarBuilders: CalendarBuilders(
            selectedBuilder: (context, day, focusedDay) => _buildCell(day, isSelected: true,
                isToday: isSameDay(day, DateTime.now())),
            todayBuilder: (context, day, focusedDay) => _buildCell(day, isSelected:
            isSameDay(day, _selectedDay), isToday: true),
            defaultBuilder: (context, day, focusedDay) => _buildCell(day, isSelected: false, isToday: false),
            outsideBuilder: (context, day, focusedDay) => Opacity(opacity: 0.5,
                child: _buildCell(day, isSelected: false, isToday: false)),
          ),
          headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
        ),
// 선택된 날짜의 일정 목록
        ValueListenableBuilder<List<Event>>(
          valueListenable: _selectedEvents,
          builder: (context, value, _) {
            if (value.isEmpty) {
              return const Padding(padding: EdgeInsets.all(16.0),
                  child: Center(child: Text('선택된 날짜에 일정이 없습니다.')));
            }
            return ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: value.length,
              itemBuilder: (context, index) {
                final event = value[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                  decoration: BoxDecoration(border: Border.all(color: event.clubColor),
                      borderRadius: BorderRadius.circular(12.0)),
                  child: ListTile(
                    title: Text('${event.title}_${event.clubName}'),
                    leading: Icon(Icons.circle, color: event.clubColor, size: 12),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
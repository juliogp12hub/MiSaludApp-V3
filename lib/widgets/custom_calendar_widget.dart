import 'package:flutter/material.dart';
import '../data/datasources/agenda_local_datasource.dart';

class CustomCalendarWidget extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateSelected;
  final Function(DateTime) onMonthChanged;
  final Map<DateTime, DayStatus> availability;
  final bool isLoading;

  const CustomCalendarWidget({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
    required this.onMonthChanged,
    required this.availability,
    this.isLoading = false,
  });

  @override
  State<CustomCalendarWidget> createState() => _CustomCalendarWidgetState();
}

class _CustomCalendarWidgetState extends State<CustomCalendarWidget> {
  late DateTime _focusedMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _focusedMonth = DateTime(_selectedDate.year, _selectedDate.month);
  }

  void _changeMonth(int offset) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + offset);
    });
    widget.onMonthChanged(_focusedMonth);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildDaysOfWeek(),
        _buildCalendarGrid(),
      ],
    );
  }

  Widget _buildHeader() {
    final monthName = _monthName(_focusedMonth.month);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _changeMonth(-1),
          ),
          Text(
            "$monthName ${_focusedMonth.year}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _changeMonth(1),
          ),
        ],
      ),
    );
  }

  Widget _buildDaysOfWeek() {
    const days = ["L", "M", "M", "J", "V", "S", "D"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days
          .map((d) => Text(d, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)))
          .toList(),
    );
  }

  Widget _buildCalendarGrid() {
    if (widget.isLoading) {
      return const SizedBox(
        height: 250,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final daysInMonth = DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
    final firstDayOfWeek = DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday; // 1=Mon, 7=Sun

    // Calculate padding days (previous month)
    final paddingDays = firstDayOfWeek - 1;
    final totalCells = daysInMonth + paddingDays;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalCells,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
      itemBuilder: (context, index) {
        if (index < paddingDays) {
          return const SizedBox.shrink();
        }

        final day = index - paddingDays + 1;
        final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
        final isSelected = DateUtils.isSameDay(date, _selectedDate);

        // Availability status
        // We need to match date keys exactly (ignoring time)
        // Since getAvailabilityForMonth returns keys with time 00:00:00, we should be fine if we construct date correctly.
        final status = widget.availability.entries
            .firstWhere(
                (e) => DateUtils.isSameDay(e.key, date),
                orElse: () => MapEntry(date, DayStatus.unavailable)
            )
            .value;

        return GestureDetector(
          onTap: () {
            if (status != DayStatus.unavailable) { // Only selectable if working day?
                // Or maybe allow selecting unavailable to see "Doctor is resting"?
                // Let's stick to selecting any day, but visual cues guide user.
                setState(() => _selectedDate = date);
                widget.onDateSelected(date);
            }
          },
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$day",
                  style: TextStyle(
                    color: isSelected ? Colors.white : (status == DayStatus.unavailable ? Colors.grey : Colors.black),
                  ),
                ),
                const SizedBox(height: 4),
                _buildDot(status, isSelected),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDot(DayStatus status, bool isSelected) {
    Color? dotColor;
    switch (status) {
      case DayStatus.available:
        dotColor = Colors.green;
        break;
      case DayStatus.full:
        dotColor = Colors.red;
        break;
      case DayStatus.unavailable:
        dotColor = Colors.grey[300];
        break;
    }

    if (isSelected && status != DayStatus.unavailable) {
        dotColor = Colors.white; // Contrast against blue background
    }

    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: dotColor,
        shape: BoxShape.circle,
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
      "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
    ];
    return months[month - 1];
  }
}

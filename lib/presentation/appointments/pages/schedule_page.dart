import 'package:flutter/material.dart';
import 'package:flutter_learning/common/widgets/snackbar/snack_bar_root.dart';
import 'package:flutter_learning/core/utils/date_time_keys.dart';
import 'package:flutter_learning/domain/entities/appointments/appointment.dart';
import 'package:flutter_learning/domain/entities/appointments/doctor.dart';
import 'package:flutter_learning/domain/models/appointments/book_appointment_request.dart';
import 'package:flutter_learning/domain/models/appointments/slots_request.dart';
import 'package:flutter_learning/domain/usecases/appointments/create_appointment.dart';
import 'package:flutter_learning/domain/usecases/appointments/get_booked_slots.dart';
import 'package:flutter_learning/presentation/appointments/models/booking_context.dart';
import 'package:flutter_learning/presentation/root/root_navigation.dart';
import 'package:flutter_learning/service_locator.dart';
import 'package:table_calendar/table_calendar.dart';

class SchedulePage extends StatefulWidget {
  final BookingContext booking;
  final Doctor doctor;
  final String specialty;

  const SchedulePage({
    super.key,
    required this.booking,
    required this.doctor,
    required this.specialty,
  });

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late final DateTime _today = DateTime.now();
  late DateTime _focusedDay = _today;

  DateTime? _selectedDay;
  DateTime? _selectedTime;
  Set<String> _booked = {};

  bool _loadingSlots = false;
  bool _referralConfirmed = false;
  bool _creating = false;

  String _formatTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  Future<void> _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedTime = null;
      _loadingSlots = true;
    });

    final result = await sl<GetBookedSlotsUseCase>().call(
      params: SlotsRequest(doctorId: widget.doctor.id, date: selectedDay),
    );
    if (!mounted) return;

    result.fold(
      (l) {
        setState(() => _loadingSlots = false);
        SnackbarRoot.show(
          context,
          l.toString(),
          selection: SnackbarRootType.bad,
        );
      },
      (r) => setState(() {
        _booked = (r as Set).cast<String>();
        _loadingSlots = false;
      }),
    );
  }

  List<DateTime> _availableSlots() {
    final day = _selectedDay;
    if (day == null) return const [];
    return widget.doctor.schedule
        .slotsFor(day, widget.doctor.slotMinutes)
        .where((s) => !_booked.contains(s.timeKey))
        .toList();
  }

  Future<void> _confirm() async {
    final day = _selectedDay;
    final time = _selectedTime;
    if (day == null || time == null) return;

    setState(() => _creating = true);

    final request = BookAppointmentRequest(
      doctorId: widget.doctor.id,
      doctorName: widget.doctor.name,
      specialty: widget.specialty,
      medicalCenter: widget.booking.center,
      date: DateTime(day.year, day.month, day.day, time.hour, time.minute),
      status: widget.booking.isPublic
          ? AppointmentStatus.requested
          : AppointmentStatus.scheduled,
      referralConfirmed: widget.booking.isPublic,
    );

    final result = await sl<CreateAppointmentUseCase>().call(params: request);
    if (!mounted) return;

    result.fold(
      (l) {
        setState(() => _creating = false);
        SnackbarRoot.show(
          context,
          l.toString(),
          selection: SnackbarRootType.bad,
        );
      },
      (r) {
        SnackbarRoot.show(
          context,
          widget.booking.isPublic ? 'Cita solicitada' : 'Cita programada',
          selection: SnackbarRootType.ok,
        );
        RootNavigation.goTo('Mis citas');
        Navigator.popUntil(context, (route) => route.isFirst);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.specialty} · ${widget.doctor.name}',
          style: TextStyle(
            color: scheme.inverseSurface,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          TableCalendar(
            locale: 'es_ES',
            firstDay: DateTime(_today.year, _today.month, 1),
            lastDay: _today.add(const Duration(days: 90)),
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            enabledDayPredicate: (day) => widget.doctor.schedule.worksOn(day),
            onDaySelected: _onDaySelected,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: scheme.secondaryContainer,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
              ),
              outsideDaysVisible: false,
            ),
          ),

          const SizedBox(height: 16),

          if (_selectedDay == null)
            const Center(
              child: Text(
                'Elige un día del calendario',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedDay != null &&
                          widget.doctor.schedule.worksOn(_selectedDay!)
                      ? 'Horas disponibles'
                      : 'Ese día el médico no consulta',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                if (_loadingSlots)
                  const Center(child: CircularProgressIndicator())
                else if (_availableSlots().isEmpty)
                  const Text('No quedan horas libres ese día')
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final slot in _availableSlots())
                        ChoiceChip(
                          label: Text(_formatTime(slot)),
                          selected: _selectedTime?.timeKey == slot.timeKey,
                          onSelected: (_) =>
                              setState(() => _selectedTime = slot),
                        ),
                    ],
                  ),
              ],
            ),

          if (widget.booking.isPublic) ...[
            const SizedBox(height: 20),
            Card(
              color: scheme.surfaceContainer,
              child: CheckboxListTile(
                value: _referralConfirmed,
                onChanged: (value) => setState(() {
                  _referralConfirmed = value ?? false;
                }),
                title: const Text(
                  'Confirmo que tengo la derivación de mi centro de salud',
                ),
                subtitle: const Text(
                  'Sin derivación no se puede pedir cita con un '
                  'especialista en la pública',
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
          ],

          const SizedBox(height: 28),

          FilledButton(
            onPressed:
                _selectedDay == null ||
                    _selectedTime == null ||
                    (widget.booking.isPublic && !_referralConfirmed) ||
                    _creating
                ? null
                : _confirm,
            child: _creating
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      'Confirmar cita',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

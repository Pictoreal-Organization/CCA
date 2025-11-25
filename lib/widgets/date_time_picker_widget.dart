// import 'package:flutter/material.dart';
// import '../core/app_colors.dart';

// class DateTimePickerWidget extends StatefulWidget {
//   final DateTime? initialDateTime;
//   final void Function(DateTime) onDateTimeChanged;

//   const DateTimePickerWidget({
//     super.key,
//     required this.initialDateTime,
//     required this.onDateTimeChanged,
//   });

//   @override
//   State<DateTimePickerWidget> createState() => _DateTimePickerWidgetState();
// }

// class _DateTimePickerWidgetState extends State<DateTimePickerWidget> {
//   DateTime? dateTime;

//   @override
//   void initState() {
//     super.initState();
//     dateTime = widget.initialDateTime;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.darkTeal, // ✅ Solid dark teal (same as "General" tab)
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.darkTeal.withOpacity(0.4),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: SizedBox(
//         height: 55,
//         width: double.infinity,
//         child: ElevatedButton.icon(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.transparent, // container already colored
//             foregroundColor: Colors.white,
//             elevation: 0,
//             shadowColor: Colors.transparent,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(14),
//             ),
//           ),
//           onPressed: () async {
//             DateTime? picked = await showDatePicker(
//               context: context,
//               initialDate: DateTime.now(),
//               firstDate: DateTime.now(),
//               lastDate: DateTime(2100),
//               builder: (context, child) {
//                 return Theme(
//                   data: theme.copyWith(
//                     useMaterial3: true,
//                     colorScheme: theme.colorScheme.copyWith(
//                       primary: AppColors.darkTeal,
//                       onPrimary: Colors.white,
//                       onSurface: AppColors.darkGray,
//                       surfaceTint: Colors.white,
//                     ),
//                     dialogBackgroundColor: Colors.white,
//                     canvasColor: Colors.white,
//                     datePickerTheme: const DatePickerThemeData(
//                       backgroundColor: Colors.white,
//                       surfaceTintColor: Colors.transparent,
//                     ),
//                   ),
//                   child: child!,
//                 );
//               },
//             );

//             if (picked != null && mounted) {
//               TimeOfDay? time = await showTimePicker(
//                 context: context,
//                 initialTime: TimeOfDay.now(),
//                 builder: (context, child) {
//                   return Theme(
//                     data: theme.copyWith(
//                       timePickerTheme: TimePickerThemeData(
//                         backgroundColor: Colors.white,
//                         hourMinuteColor: AppColors.darkTeal.withOpacity(0.12),
//                         hourMinuteTextColor: AppColors.darkGray,
//                         hourMinuteShape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         dialBackgroundColor: AppColors.green.withOpacity(0.1),
//                         dialHandColor: AppColors.darkTeal,
//                         dialTextColor: MaterialStateColor.resolveWith(
//                           (states) => states.contains(MaterialState.selected)
//                               ? Colors.white
//                               : AppColors.darkGray,
//                         ),
//                         entryModeIconColor: AppColors.darkTeal,
//                         dayPeriodColor: MaterialStateColor.resolveWith(
//                           (states) => states.contains(MaterialState.selected)
//                               ? AppColors.darkTeal
//                               : AppColors.green.withOpacity(0.08),
//                         ),
//                         dayPeriodTextColor: MaterialStateColor.resolveWith(
//                           (states) => states.contains(MaterialState.selected)
//                               ? Colors.white
//                               : AppColors.darkTeal,
//                         ),
//                         helpTextStyle: const TextStyle(
//                           color: AppColors.darkTeal,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                       colorScheme: theme.colorScheme.copyWith(
//                         primary: AppColors.darkTeal,
//                         onPrimary: Colors.white,
//                         onSurface: AppColors.darkGray,
//                       ),
//                     ),
//                     child: child!,
//                   );
//                 },
//               );

//               if (time != null) {
//                 setState(() {
//                   dateTime = DateTime(
//                     picked.year,
//                     picked.month,
//                     picked.day,
//                     time.hour,
//                     time.minute,
//                   );
//                 });
//                 widget.onDateTimeChanged(dateTime!);
//               }
//             }
//           },
//           icon: const Icon(Icons.calendar_today_outlined),
//           label: Text(
//             dateTime == null
//                 ? 'Pick Date & Time'
//                 : 'Selected: ${dateTime!.toString().substring(0, 16)}',
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class DateTimePickerWidget extends StatefulWidget {
  final DateTime? initialDateTime;
  final void Function(DateTime) onDateTimeChanged;

  const DateTimePickerWidget({
    super.key,
    required this.initialDateTime,
    required this.onDateTimeChanged,
  });

  @override
  State<DateTimePickerWidget> createState() => _DateTimePickerWidgetState();
}

class _DateTimePickerWidgetState extends State<DateTimePickerWidget> {
  DateTime? dateTime;

  @override
  void initState() {
    super.initState();
    dateTime = widget.initialDateTime;
  }

  // ✅ Helper method to check if selected date is today
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // ✅ Helper method to get the initial time for time picker
  TimeOfDay _getInitialTime(DateTime selectedDate) {
    if (_isToday(selectedDate)) {
      // If today, start from current time
      final now = DateTime.now();
      return TimeOfDay(hour: now.hour, minute: now.minute);
    } else {
      // If future date, start from beginning of day
      return const TimeOfDay(hour: 0, minute: 0);
    }
  }

  // ✅ Helper method to validate if selected time is in the past
  bool _isTimeInPast(DateTime selectedDate, TimeOfDay selectedTime) {
    if (!_isToday(selectedDate)) {
      return false; // Future dates are always valid
    }

    final now = DateTime.now();
    final selectedDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    return selectedDateTime.isBefore(now);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkTeal,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkTeal.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        height: 55,
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: () async {
            // ✅ STEP 1: Pick Date
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: theme.copyWith(
                    useMaterial3: true,
                    colorScheme: theme.colorScheme.copyWith(
                      primary: AppColors.darkTeal,
                      onPrimary: Colors.white,
                      onSurface: AppColors.darkGray,
                      surfaceTint: Colors.white,
                    ),
                    dialogBackgroundColor: Colors.white,
                    canvasColor: Colors.white,
                    datePickerTheme: const DatePickerThemeData(
                      backgroundColor: Colors.white,
                      surfaceTintColor: Colors.transparent,
                    ),
                  ),
                  child: child!,
                );
              },
            );

            if (picked != null && mounted) {
              // ✅ STEP 2: Pick Time with validation loop
              TimeOfDay? time;
              bool isValidTime = false;

              while (!isValidTime && mounted) {
                time = await showTimePicker(
                  context: context,
                  initialTime: _getInitialTime(picked),
                  builder: (context, child) {
                    return Theme(
                      data: theme.copyWith(
                        timePickerTheme: TimePickerThemeData(
                          backgroundColor: Colors.white,
                          hourMinuteColor: AppColors.darkTeal.withOpacity(0.12),
                          hourMinuteTextColor: AppColors.darkGray,
                          hourMinuteShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          dialBackgroundColor: AppColors.green.withOpacity(0.1),
                          dialHandColor: AppColors.darkTeal,
                          dialTextColor: MaterialStateColor.resolveWith(
                            (states) => states.contains(MaterialState.selected)
                                ? Colors.white
                                : AppColors.darkGray,
                          ),
                          entryModeIconColor: AppColors.darkTeal,
                          dayPeriodColor: MaterialStateColor.resolveWith(
                            (states) => states.contains(MaterialState.selected)
                                ? AppColors.darkTeal
                                : AppColors.green.withOpacity(0.08),
                          ),
                          dayPeriodTextColor: MaterialStateColor.resolveWith(
                            (states) => states.contains(MaterialState.selected)
                                ? Colors.white
                                : AppColors.darkTeal,
                          ),
                          helpTextStyle: const TextStyle(
                            color: AppColors.darkTeal,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        colorScheme: theme.colorScheme.copyWith(
                          primary: AppColors.darkTeal,
                          onPrimary: Colors.white,
                          onSurface: AppColors.darkGray,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );

                // ✅ User cancelled time picker
                if (time == null) {
                  break;
                }

                // ✅ STEP 3: Validate the selected time
                if (_isTimeInPast(picked, time)) {
                  // Show error and prompt to select again
                  if (mounted) {
                    await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          icon: const Icon(
                            Icons.access_time_outlined,
                            color: AppColors.darkOrange,
                            size: 48,
                          ),
                          title: const Text(
                            'Invalid Time',
                            style: TextStyle(
                              color: AppColors.darkTeal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: const Text(
                            'You cannot select a time in the past. Please choose a current or future time.',
                            style: TextStyle(color: AppColors.darkGray),
                            textAlign: TextAlign.center,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text(
                                'OK',
                                style: TextStyle(
                                  color: AppColors.darkTeal,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }
                  // Loop continues - will show time picker again
                } else {
                  // Time is valid
                  isValidTime = true;
                }
              }

              // ✅ STEP 4: Save valid date-time
              if (time != null && isValidTime) {
                final selectedHour = time.hour;
                final selectedMinute = time.minute;

                setState(() {
                  dateTime = DateTime(
                    picked.year,
                    picked.month,
                    picked.day,
                    selectedHour,
                    selectedMinute,
                  );
                });
                widget.onDateTimeChanged(dateTime!);
              }
            }
          },
          icon: const Icon(Icons.calendar_today_outlined),
          label: Text(
            dateTime == null
                ? 'Pick Date & Time'
                : 'Selected: ${dateTime!.toString().substring(0, 16)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }
}

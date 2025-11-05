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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkTeal, // ✅ Solid dark teal (same as "General" tab)
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
            backgroundColor: Colors.transparent, // container already colored
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: () async {
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
              TimeOfDay? time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
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

              if (time != null) {
                setState(() {
                  dateTime = DateTime(
                    picked.year,
                    picked.month,
                    picked.day,
                    time.hour,
                    time.minute,
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
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}


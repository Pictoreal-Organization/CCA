import 'package:flutter/material.dart';
import '../services/meeting_service.dart';

class CreateMeetingScreen extends StatefulWidget {
  final VoidCallback onMeetingCreated;
  const CreateMeetingScreen({super.key, required this.onMeetingCreated});

  @override
  State<CreateMeetingScreen> createState() => _CreateMeetingScreenState();
}

class _CreateMeetingScreenState extends State<CreateMeetingScreen> {
  final _formKey = GlobalKey<FormState>();
  final MeetingService meetingService = MeetingService();

  String title = '';
  String description = '';
  String location = '';
  String? agenda;
  int? duration;
  String? priority = 'Medium';
  DateTime? dateTime;

  bool isSubmitting = false;

  void submit() async {
    if (!_formKey.currentState!.validate() || dateTime == null) return;

    _formKey.currentState!.save();

    setState(() => isSubmitting = true);

    try {
      await meetingService.createMeeting(
        title: title,
        description: description,
        location: location,
        dateTime: dateTime!,
        agenda: agenda,
        duration: duration,
        priority: priority,
      );

      widget.onMeetingCreated(); // refresh dashboard
      Navigator.pop(context); // go back
    } catch (e) {
      setState(() => isSubmitting = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to create meeting: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Meeting')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (val) => val!.isEmpty ? 'Enter title' : null,
                onSaved: (val) => title = val!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (val) => val!.isEmpty ? 'Enter description' : null,
                onSaved: (val) => description = val!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (val) => val!.isEmpty ? 'Enter location' : null,
                onSaved: (val) => location = val!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Agenda (optional)'),
                onSaved: (val) => agenda = val,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Duration (minutes)'),
                keyboardType: TextInputType.number,
                onSaved: (val) => duration = val!.isEmpty ? 60 : int.parse(val),
              ),
              DropdownButtonFormField<String>(
                value: priority,
                items: ['Low', 'Medium', 'High', 'Urgent']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => priority = val),
                decoration: const InputDecoration(labelText: 'Priority'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    TimeOfDay? time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
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
                    }
                  }
                },
                child: Text(dateTime == null
                    ? 'Pick Date & Time'
                    : 'Selected: ${dateTime!.toLocal()}'),
              ),
              const SizedBox(height: 20),
              isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: submit,
                      child: const Text('Create Meeting'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

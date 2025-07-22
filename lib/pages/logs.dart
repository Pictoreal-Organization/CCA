import 'package:flutter/material.dart';

// LogEntry model to represent a log record
class LogEntry {
  final String id;
  final String action;
  final String details;
  final DateTime timestamp;
  final String user;

  LogEntry({
    required this.id,
    required this.action,
    required this.details,
    required this.timestamp,
    required this.user,
  });
}

// LogManager to manage log entries
class LogManager extends ChangeNotifier {
  final List<LogEntry> _logs = [];

  List<LogEntry> get logs => List.unmodifiable(_logs);

  void addLog({
    required String action,
    required String details,
    required String user,
  }) {
    final log = LogEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      action: action,
      details: details,
      timestamp: DateTime.now(),
      user: user,
    );
    _logs.insert(0, log);
    notifyListeners();
  }

  void clearLogs() {
    _logs.clear();
    notifyListeners();
  }

  void logCompletedMeeting({
    required String meetingId,
    required String meetingTitle,
    required String user,
  }) {
    addLog(
      action: 'Meeting Completed',
      details: 'Meeting "$meetingTitle" (ID: $meetingId) was completed.',
      user: user,
    );
  }

  void logCompletedTask({
    required String taskId,
    required String taskTitle,
    required String user,
  }) {
    addLog(
      action: 'Task Completed',
      details: 'Task "$taskTitle" (ID: $taskId) was completed.',
      user: user,
    );
  }
}

// Widget to display logs
class LogsPage extends StatelessWidget {
  final LogManager logManager;

  const LogsPage({Key? key, required this.logManager}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Logs'),
      ),
      body: AnimatedBuilder(
        animation: logManager,
        builder: (context, _) {
          if (logManager.logs.isEmpty) {
            return const Center(child: Text('No logs yet.'));
          }
          return ListView.builder(
            itemCount: logManager.logs.length,
            itemBuilder: (context, index) {
              final log = logManager.logs[index];
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(log.action),
                subtitle: Text(log.details),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(log.user, style: const TextStyle(fontSize: 12)),
                    Text(
                      _formatDateTime(log.timestamp),
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: logManager.clearLogs,
        child: const Icon(Icons.delete),
        tooltip: 'Clear Logs',
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// Example usage (call these from your task/meeting completion logic):
// LogManager().logCompletedMeeting(meetingId: '123', meetingTitle: 'Weekly Sync', user: 'John Doe');
// LogManager().logCompletedTask(taskId: '456', taskTitle: 'Prepare Report', user: 'Jane Smith');

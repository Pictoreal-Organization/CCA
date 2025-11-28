// import 'package:flutter/material.dart';
// import '../services/attendance_service.dart';
// import '../core/app_colors.dart';
// import '../widgets/loading_animation.widget.dart';

// class AttendanceScreen extends StatefulWidget {
//   final Map meeting;
//   const AttendanceScreen({super.key, required this.meeting});

//   @override
//   State<AttendanceScreen> createState() => _AttendanceScreenState();
// }

// class _AttendanceScreenState extends State<AttendanceScreen> {
//   final AttendanceService attendanceService = AttendanceService();
//   List<Map<String, dynamic>> attendanceList = [];
//   List<Map<String, dynamic>> filteredAttendanceList = [];
//   bool isLoading = true;
//   bool isSubmitting = false;
//   String searchQuery = '';

//   @override
//   void initState() {
//     super.initState();
//     fetchAttendance();
//   }

//   void fetchAttendance() async {
//     try {
//       final list = await attendanceService.getAttendanceForMeeting(
//         widget.meeting['_id'],
//       );
//       setState(() {
//         attendanceList = List<Map<String, dynamic>>.from(list);
//         filteredAttendanceList = List.from(attendanceList);
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() => isLoading = false);
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Failed to load: $e')));
//     }
//   }

//   void toggleAttendance(String memberId) {
//     setState(() {
//       final idx = attendanceList.indexWhere(
//         (record) => record['member']['_id'] == memberId,
//       );
//       if (idx != -1) {
//         attendanceList[idx]['status'] =
//             attendanceList[idx]['status'] == 'present' ? 'absent' : 'present';
//       }

//       // Update filtered list too
//       final fIdx = filteredAttendanceList.indexWhere(
//         (record) => record['member']['_id'] == memberId,
//       );
//       if (fIdx != -1) {
//         filteredAttendanceList[fIdx]['status'] = attendanceList[idx]['status'];
//       }
//     });
//   }

//   void submitAttendance() async {
//     setState(() => isSubmitting = true);

//     try {
//       final presentMemberIds = attendanceList
//           .where((record) => record['status'] == 'present')
//           .map<String>((record) => record['member']['_id'] as String)
//           .toList();

//       await attendanceService.submitBulkAttendance(
//         widget.meeting['_id'],
//         presentMemberIds,
//       );

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Attendance submitted successfully!')),
//       );
//       Navigator.pop(context);
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error: $e')));
//     } finally {
//       setState(() => isSubmitting = false);
//     }
//   }

//   void filterSearch(String query) {
//     setState(() {
//       searchQuery = query;
//       filteredAttendanceList = attendanceList.where((record) {
//         final member = record['member'];
//         final text = "${member['name']} ${member['year']} ${member['rollNo']}"
//             .toLowerCase();
//         return text.contains(query.toLowerCase());
//       }).toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColors.darkTeal, // solid color for AppBar
//         title: Text(
//           "Mark Attendance - ${widget.meeting['title']}",
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 22,
//             color: Colors.white,
//           ),
//         ),
//         centerTitle: true,
//         elevation: 6,
//         shadowColor: AppColors.green.withAlpha(60),
//         iconTheme: IconThemeData(
//           color: Colors.white, // sets arrow (and all AppBar icons) to white
//         ),
//       ),

//       // Floating submit button with palette color and white icon
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: isSubmitting ? null : submitAttendance,
//         label: isSubmitting
//             ? const SizedBox(
//                 height: 20,
//                 width: 20,
//                 child: CircularProgressIndicator(color: Colors.white),
//               )
//             : const Text(
//                 'Submit',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                   color: Colors.white,
//                 ),
//               ),
//         icon: isSubmitting
//             ? null
//             : const Icon(Icons.check, size: 24, color: Colors.white),
//         backgroundColor: AppColors.green,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
//       ),
//       body: isLoading
//           ? const Center(child: LoadingAnimation(size: 250))
//           : Container(
//               color: Colors.white, // solid white background
//               child: Padding(
//                 padding: const EdgeInsets.all(14.0),
//                 child: Column(
//                   children: [
//                     // Search bar, glass-like effect, colored border and shadow (palette-based)
//                     Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: AppColors.green, width: 1.2),
//                         boxShadow: [
//                           BoxShadow(
//                             color: AppColors.green.withOpacity(0.13),
//                             blurRadius: 12,
//                             offset: Offset(2, 4),
//                           ),
//                         ],
//                       ),
//                       child: TextField(
//                         decoration: InputDecoration(
//                           labelText: 'Search by name or Roll no',
//                           labelStyle: TextStyle(
//                             color: AppColors.darkTeal,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           prefixIcon: const Icon(
//                             Icons.search,
//                             color: AppColors.green,
//                           ),
//                           border: InputBorder.none,
//                           contentPadding: EdgeInsets.all(14),
//                         ),
//                         onChanged: filterSearch,
//                         style: TextStyle(
//                           color: AppColors.darkGray,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     // List of colourful member cards
//                     Expanded(
//                       child: filteredAttendanceList.isEmpty
//                           ? const Center(
//                               child: Text(
//                                 'No members found',
//                                 style: TextStyle(
//                                   color: AppColors.orange,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                             )
//                           : ListView.builder(
//                               itemCount: filteredAttendanceList.length,
//                               itemBuilder: (context, index) {
//                                 final record = filteredAttendanceList[index];
//                                 final member = record['member'];
//                                 return Container(
//                                   margin: EdgeInsets.symmetric(
//                                     vertical: 10,
//                                     horizontal: 4,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(16),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.black.withOpacity(
//                                           0.08,
//                                         ), // slightly darker for realism
//                                         blurRadius: 20, // softer shadow edges
//                                         spreadRadius:
//                                             1, // small spread for smooth glow
//                                         offset: const Offset(
//                                           0,
//                                           4,
//                                         ), // subtle bottom shadow
//                                       ),
//                                     ],
//                                   ),

//                                   child: ListTile(
//                                     // leading: CircleAvatar(
//                                     //   backgroundColor: AppColors.darkTeal,
//                                     //   child: Icon(
//                                     //     Icons.person,
//                                     //     color: Colors.white,
//                                     //     size: 32,
//                                     //   ),
//                                     //   radius: 24,
//                                     // ),
//                                     leading: CircleAvatar(
//                                       radius: 24,
//                                       backgroundColor: Colors.transparent,
//                                       child: ClipOval(
//                                         child:
//                                             member['avatar'] != null &&
//                                                 member['avatar']
//                                                     .toString()
//                                                     .isNotEmpty
//                                             ? Image.asset(
//                                                 member['avatar'],
//                                                 width: 48,
//                                                 height: 48,
//                                                 fit: BoxFit.cover,
//                                                 errorBuilder:
//                                                     (
//                                                       context,
//                                                       error,
//                                                       stackTrace,
//                                                     ) {
//                                                       return const Icon(
//                                                         Icons.account_circle,
//                                                         size: 48,
//                                                         color: Colors.grey,
//                                                       );
//                                                     },
//                                               )
//                                             : const Icon(
//                                                 Icons.account_circle,
//                                                 size: 48,
//                                                 color: Colors.grey,
//                                               ),
//                                       ),
//                                     ),

//                                     title: Text(
//                                       "${member['name']} - ${member['year']} ${member['division']}",
//                                       style: TextStyle(
//                                         color: AppColors.darkGray,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     subtitle: Text(
//                                       "rollNo: ${member['rollNo']}",
//                                       style: TextStyle(
//                                         color: AppColors.lightGray,
//                                       ),
//                                     ),
//                                     trailing: Checkbox(
//                                       value: record['status'] == 'present',
//                                       onChanged: (_) =>
//                                           toggleAttendance(member['_id']),
//                                       activeColor: AppColors.orange,
//                                     ),

//                                     // Checkbox(
//                                     //   value: isPresent,
//                                     //   onChanged: (value) {
//                                     //     setState(() {
//                                     //       isPresent = value!;
//                                     //     });
//                                     //   },
//                                     // )
//                                   ),
//                                 );
//                               },
//                             ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import '../services/attendance_service.dart';
import '../core/app_colors.dart';
import '../widgets/loading_animation.widget.dart';

class AttendanceScreen extends StatefulWidget {
  final Map meeting;
  const AttendanceScreen({super.key, required this.meeting});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final AttendanceService attendanceService = AttendanceService();

  // Data
  List<Map<String, dynamic>> attendanceList = [];
  List<Map<String, dynamic>> filteredAttendanceList = [];

  // State
  bool isLoading = true;
  bool isSubmitting = false;

  // Filters & Sorting
  String searchQuery = '';
  Set<String> selectedYears = {};
  
  // Sort State
  String currentSortField = 'Name';
  bool isAscending = true;

  final List<String> yearTags = ['FY', 'SY', 'TE', 'BE'];
  final List<String> sortOptions = ['Name', 'Roll No', 'Year'];

  @override
  void initState() {
    super.initState();
    fetchAttendance();
  }

  // ---------------------------------------------------------
  // ✅ REUSABLE POPUP DIALOG FUNCTION
  // ---------------------------------------------------------
  void _showStatusDialog({
    required String title,
    required String message,
    bool isError = false,
    VoidCallback? onConfirm,
  }) {
    showDialog(
      context: context,
      barrierDismissible: !isError,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: isError ? Colors.red : AppColors.darkTeal,
                size: 28,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isError ? Colors.red : AppColors.darkTeal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 16, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                if (onConfirm != null) onConfirm();
              },
              child: const Text(
                "OK",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.darkTeal,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void fetchAttendance() async {
    try {
      final list = await attendanceService.getAttendanceForMeeting(
        widget.meeting['_id'],
      );
      if (mounted) {
        setState(() {
          attendanceList = List<Map<String, dynamic>>.from(list);
          _applyFiltersAndSort();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        _showStatusDialog(
          title: "Load Failed",
          message: "Could not fetch attendance data: $e",
          isError: true,
        );
      }
    }
  }

  void _applyFiltersAndSort() {
    var temp = attendanceList.where((record) {
      final member = record['member'];
      final name = (member['name'] ?? '').toString().toLowerCase();
      final rollNo = (member['rollNo'] ?? '').toString().toLowerCase();
      final year = (member['year'] ?? '').toString();

      final matchesSearch =
          name.contains(searchQuery.toLowerCase()) ||
          rollNo.contains(searchQuery.toLowerCase());

      final matchesYear = selectedYears.isEmpty ||
          selectedYears.any((tag) => year.toUpperCase().contains(tag));

      return matchesSearch && matchesYear;
    }).toList();

    temp.sort((a, b) {
      // Primary Sort: Selected First
      final isPresentA = a['status'] == 'present';
      final isPresentB = b['status'] == 'present';
      if (isPresentA && !isPresentB) return -1;
      if (!isPresentA && isPresentB) return 1;

      // Secondary Sort
      final mA = a['member'];
      final mB = b['member'];
      int comparison = 0;

      switch (currentSortField) {
        case 'Roll No':
          final rA = int.tryParse(mA['rollNo'].toString()) ?? 0;
          final rB = int.tryParse(mB['rollNo'].toString()) ?? 0;
          if (rA != rB) {
            comparison = rA.compareTo(rB);
          } else {
            comparison = (mA['rollNo'].toString()).compareTo(mB['rollNo'].toString());
          }
          break;
        case 'Year':
          final yA = (mA['year'] ?? '').toString();
          final yB = (mB['year'] ?? '').toString();
          comparison = yA.compareTo(yB);
          break;
        case 'Name':
        default:
          final nA = (mA['name'] ?? '').toString().toLowerCase();
          final nB = (mB['name'] ?? '').toString().toLowerCase();
          comparison = nA.compareTo(nB);
          break;
      }

      return isAscending ? comparison : -comparison;
    });

    setState(() {
      filteredAttendanceList = temp;
    });
  }

  void toggleYearFilter(String tag) {
    setState(() {
      if (selectedYears.contains(tag)) {
        selectedYears.remove(tag);
      } else {
        selectedYears.add(tag);
      }
      _applyFiltersAndSort();
    });
  }

  void toggleSortDirection() {
    setState(() {
      isAscending = !isAscending;
      _applyFiltersAndSort();
    });
  }

  void toggleAttendance(String memberId) {
    setState(() {
      final idx = attendanceList.indexWhere(
        (record) => record['member']['_id'] == memberId,
      );
      if (idx != -1) {
        attendanceList[idx]['status'] =
            attendanceList[idx]['status'] == 'present' ? 'absent' : 'present';
        _applyFiltersAndSort();
      }
    });
  }

  void submitAttendance() async {
    setState(() => isSubmitting = true);
    try {
      final presentMemberIds = attendanceList
          .where((record) => record['status'] == 'present')
          .map<String>((record) => record['member']['_id'] as String)
          .toList();

      await attendanceService.submitBulkAttendance(
        widget.meeting['_id'],
        presentMemberIds,
      );

      if (mounted) {
        _showStatusDialog(
          title: "Success",
          message: "Attendance submitted successfully!",
          isError: false,
          onConfirm: () => Navigator.pop(context),
        );
      }
    } catch (e) {
      if (mounted) {
        _showStatusDialog(
          title: "Submission Error",
          message: "Failed to submit attendance: $e",
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  int get selectedCount => attendanceList
      .where((r) => r['status'] == 'present')
      .length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkTeal,
        title: Text(
          "Mark Attendance",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: isLoading 
          ? null 
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.orange,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Selected: $selectedCount",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  FloatingActionButton.extended(
                    heroTag: "submit_btn",
                    onPressed: isSubmitting ? null : submitAttendance,
                    label: isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white),
                          )
                        : const Text(
                            'Submit',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                    icon: isSubmitting
                        ? null
                        : const Icon(Icons.check, size: 24, color: Colors.white),
                    backgroundColor: AppColors.green,
                    elevation: 4,
                  ),
                ],
              ),
            ),

      body: isLoading
          ? const Center(child: LoadingAnimation(size: 250))
          : Container(
              color: Colors.white,
              child: Column(
                children: [
                  // --- HEADER ---
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Search Bar
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.green.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Search Name or Roll No',
                              prefixIcon: Icon(
                                Icons.search,
                                color: AppColors.green,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            onChanged: (val) {
                              searchQuery = val;
                              _applyFiltersAndSort();
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 12),

                        // Filters & Sort
                        Row(
                          children: [
                            // Year Chips
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: yearTags.map((tag) {
                                    final isSelected = selectedYears.contains(tag);
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 6.0),
                                      child: FilterChip(
                                        label: Text(tag),
                                        selected: isSelected,
                                        onSelected: (_) => toggleYearFilter(tag),
                                        backgroundColor: Colors.white,
                                        selectedColor: AppColors.darkTeal,
                                        checkmarkColor: Colors.white,
                                        labelStyle: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.darkTeal,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                        side: BorderSide(
                                          color: AppColors.darkTeal,
                                          width: 1,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        padding: const EdgeInsets.all(4),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),

                            Container(
                              height: 32,
                              width: 1,
                              color: Colors.grey.shade300,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                            ),

                            // Sort Dropdown
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: AppColors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: currentSortField,
                                  icon: const Icon(
                                    Icons.arrow_drop_down,
                                    color: AppColors.darkTeal,
                                  ),
                                  style: const TextStyle(
                                    color: AppColors.darkTeal,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        currentSortField = newValue;
                                        _applyFiltersAndSort();
                                      });
                                    }
                                  },
                                  items: sortOptions.map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),

                            const SizedBox(width: 6),

                            // Sort Arrow
                            InkWell(
                              onTap: toggleSortDirection,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  isAscending
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                  size: 18,
                                  color: AppColors.darkTeal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // --- LIST ---
                  Expanded(
                    child: filteredAttendanceList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.filter_list_off,
                                  size: 48,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'No members found',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(14, 10, 14, 80),
                            itemCount: filteredAttendanceList.length,
                            itemBuilder: (context, index) {
                              final record = filteredAttendanceList[index];
                              final member = record['member'];
                              final isPresent = record['status'] == 'present';

                              return GestureDetector(
                                onTap: () => toggleAttendance(member['_id']),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    // ✅ SMOOTH GREEN BORDER (AnimatedContainer handles transition)
                                    border: Border.all(
                                      color: isPresent
                                          ? AppColors.green
                                          : Colors.transparent,
                                      width: 2, 
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 4,
                                    ),
                                    leading: CircleAvatar(
                                      radius: 22,
                                      backgroundColor: Colors.transparent,
                                      child: ClipOval(
                                        child: (member['avatar'] != null &&
                                                member['avatar']
                                                    .toString()
                                                    .isNotEmpty)
                                            ? Image.asset(
                                                member['avatar'],
                                                width: 44,
                                                height: 44,
                                                fit: BoxFit.cover,
                                                errorBuilder: (ctx, err, stack) {
                                                  return const Icon(
                                                    Icons.account_circle,
                                                    size: 44,
                                                    color: Colors.grey,
                                                  );
                                                },
                                              )
                                            : const Icon(
                                                Icons.account_circle,
                                                size: 44,
                                                color: Colors.grey,
                                              ),
                                      ),
                                    ),
                                    title: Text(
                                      "${member['name']} ${member['year'] != null ? '(${member['year']})' : ''}",
                                      style: TextStyle(
                                        color: isPresent 
                                            ? AppColors.darkTeal 
                                            : AppColors.darkGray,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "Roll No: ${member['rollNo']}",
                                      style: const TextStyle(
                                        color: AppColors.lightGray,
                                        fontSize: 13,
                                      ),
                                    ),
                                    // ✅ SQUARE ORANGE BOX
                                    trailing: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      height: 24,
                                      width: 24,
                                      decoration: BoxDecoration(
                                        color: isPresent
                                            ? AppColors.orange // ORANGE FILL
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(6), // SQUARE ROUNDED
                                        border: Border.all(
                                          color: isPresent
                                              ? AppColors.orange
                                              : Colors.grey.shade400,
                                          width: 2,
                                        ),
                                      ),
                                      child: isPresent
                                          ? const Icon(
                                              Icons.check,
                                              size: 16,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
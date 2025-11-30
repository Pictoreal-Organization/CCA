// import 'package:flutter/material.dart';
// import '../core/app_colors.dart';

// PreferredSizeWidget customAppBar({
//   required String title,
//   required BuildContext context,
//   bool showEdit = false,
//   bool isEditing = false,
//   VoidCallback? onEditToggle,
// }) {
//   return AppBar(
//     backgroundColor: AppColors.darkTeal,
//     elevation: 4,
//     automaticallyImplyLeading: false,

//     leading: IconButton(
//       icon: const Icon(
//         Icons.arrow_back_ios_new_rounded,
//         color: Colors.white,
//         size: 20,
//       ),
//       onPressed: () => Navigator.of(context).pop(),
//     ),

//     title: Text(
//       title,
//       style: const TextStyle(
//         color: Colors.white,
//         fontWeight: FontWeight.w600,
//         fontSize: 18,
//       ),
//     ),

//     actions: showEdit
//         ? [
//             IconButton(
//               icon: Container(
//                 padding: const EdgeInsets.all(6),
//                 decoration: BoxDecoration(
//                   color: isEditing
//                       ? Colors.white.withOpacity(0.2)
//                       : Colors.transparent,
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   isEditing
//                       ? Icons.check_circle_rounded
//                       : Icons.edit_rounded,
//                   color: Colors.white,
//                   size: 20,
//                 ),
//               ),
//               onPressed: onEditToggle,
//             ),
//           ]
//         : null,
//   );
// }

import 'package:flutter/material.dart';
import '../core/app_colors.dart';

PreferredSizeWidget customAppBar({
  required String title,
  required BuildContext context,
  bool showEdit = false,
  bool isEditing = false,
  VoidCallback? onEditToggle,
  bool showLogout = false, // ✅ NEW PARAMETER
  VoidCallback? onLogout, // ✅ NEW PARAMETER
}) {
  return AppBar(
    backgroundColor: AppColors.darkTeal,
    elevation: 4,
    automaticallyImplyLeading: false,

    leading: IconButton(
      icon: const Icon(
        Icons.arrow_back_ios_new_rounded,
        color: Colors.white,
        size: 20,
      ),
      onPressed: () => Navigator.of(context).pop(),
    ),

    title: Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
    ),

    actions: [
      // ✅ EDIT BUTTON (if showEdit is true)
      if (showEdit)
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isEditing
                  ? Colors.white.withOpacity(0.2)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isEditing ? Icons.check_circle_rounded : Icons.edit_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: onEditToggle,
        ),

      // ✅ LOGOUT BUTTON (if showLogout is true)
      if (showLogout)
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white, size: 26),
          onPressed: onLogout,
          tooltip: 'Logout',
        ),
    ],
  );
}

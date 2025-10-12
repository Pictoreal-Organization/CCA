import 'package:flutter/material.dart';

class SearchableUserDropdown extends StatefulWidget {
  final List<Map<String, dynamic>> allUsers;
  final bool isLoading;
  final String? selectedUserId;
  final Function(String?, String?) onUserSelected;
  final String? Function(String?)? validator;

  const SearchableUserDropdown({
    super.key,
    required this.allUsers,
    required this.isLoading,
    required this.selectedUserId,
    required this.onUserSelected,
    this.validator,
  });

  @override
  State<SearchableUserDropdown> createState() => _SearchableUserDropdownState();
}

class _SearchableUserDropdownState extends State<SearchableUserDropdown> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredUsers = [];
  bool _isDropdownOpen = false;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _filteredUsers = List.from(widget.allUsers);
    _updateControllerWithSelectedUser();
  }

  @override
  void didUpdateWidget(covariant SearchableUserDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedUserId != oldWidget.selectedUserId) {
      _updateControllerWithSelectedUser();
    }
    if (widget.allUsers != oldWidget.allUsers) {
      _filteredUsers = List.from(widget.allUsers);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Detect when route (page) is popped
    ModalRoute.of(context)?.addScopedWillPopCallback(() async {
      _removeOverlay(); // remove dropdown if open
      return true; // allow pop
    });
  }

  void _updateControllerWithSelectedUser() {
    if (widget.selectedUserId != null) {
      final selectedUser = widget.allUsers.firstWhere(
        (user) => user['_id'] == widget.selectedUserId,
        orElse: () => {},
      );
      if (selectedUser.isNotEmpty) {
        _searchController.text = selectedUser['username'];
      }
    } else {
      _searchController.clear();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _filterUsers(String query) {
    setState(() {
      _filteredUsers = widget.allUsers
          .where((user) => user['username']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });

    if (_overlayEntry != null && mounted) {
      _overlayEntry?.markNeedsBuild();
    }
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;

      if (mounted) {
        setState(() => _isDropdownOpen = false);
      } else {
        _isDropdownOpen = false;
      }
    }
  }

  void _createOverlay() {
    if (_overlayEntry != null || !mounted) return;

    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        // Get AppBar height to exclude it from the tap detection
        final appBarHeight = AppBar().preferredSize.height + MediaQuery.of(context).padding.top;
        
        return Stack(
          children: [
            // Transparent layer to detect outside taps - positioned BELOW the AppBar
            // Uses Listener to allow scrolling while detecting taps
            Positioned(
              left: 0,
              top: appBarHeight,
              right: 0,
              bottom: 0,
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: (event) {
                  // Close dropdown on any pointer down outside the dropdown list
                  _removeOverlay();
                },
                child: Container(color: Colors.transparent),
              ),
            ),
            Positioned(
              left: offset.dx,
              top: offset.dy + size.height,
              width: size.width,
              child: Material(
                elevation: 4.0,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      return ListTile(
                        title: Text(user['username']),
                        onTap: () {
                          _searchController.text = user['username'];
                          widget.onUserSelected(user['_id'], user['username']);
                          _removeOverlay();
                          FocusScope.of(context).unfocus();
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isDropdownOpen = true);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _searchController,
      decoration: InputDecoration(
        labelText: 'Assign To',
        prefixIcon: const Icon(Icons.person_search),
        suffixIcon: widget.isLoading
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : IconButton(
                icon: Icon(_isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down),
                onPressed: () {
                  if (_isDropdownOpen) {
                    _removeOverlay();
                  } else {
                    _createOverlay();
                  }
                },
              ),
      ),
      readOnly: widget.isLoading,
      onTap: () {
        if (!_isDropdownOpen && !widget.isLoading) _createOverlay();
      },
      onChanged: (val) {
        _filterUsers(val);
        if (!_isDropdownOpen && val.isNotEmpty) _createOverlay();
        if (val.isEmpty) {
          widget.onUserSelected(null, null);
        }
      },
      validator: (val) {
        if (widget.selectedUserId == null || widget.selectedUserId!.isEmpty) {
          return 'Please select a user from the list.';
        }
        return null;
      },
    );
  }
}
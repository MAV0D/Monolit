import 'package:flutter/material.dart';

import '../widgets/admin/admin_points_list_view.dart';

class AdminScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const AdminScreen({super.key, required this.onLogout});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1F1F),
        automaticallyImplyLeading: false,
        title: const Text("Monolit - Admin panel"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: widget.onLogout,
            alignment: AlignmentGeometry.centerRight,
          ),
        ],
      ),
      body: AdminPointsListView(),
    );
  }
}

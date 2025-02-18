import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/bottom_nav_bar.dart';

class MyCooperativesScreen extends StatelessWidget {
  const MyCooperativesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cooperatives'),
        backgroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('My Cooperatives - Coming Soon'),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }
}

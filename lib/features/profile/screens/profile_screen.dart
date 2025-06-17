import 'package:flutter/material.dart';
import '../../food/screens/food_management_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.restaurant_menu),
            title: const Text('Manage Foods'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FoodManagementScreen()),
              );
            },
          ),
          // Add more profile options here in the future
        ],
      ),
    );
  }
} 
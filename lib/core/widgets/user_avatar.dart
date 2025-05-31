import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/auth/services/auth_service.dart';

class UserAvatar extends StatelessWidget {
  final VoidCallback onTap;

  const UserAvatar({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final currentUser = authService.currentUser;

    if (currentUser == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          // Show first letter of email if no user document exists
          final email = currentUser.email ?? '';
          final initial = email.isNotEmpty ? email[0].toUpperCase() : 'U';
          
          return _buildAvatar(context, initial, null);
        }

        final data = snapshot.data!.data() as Map<String, dynamic>?;
        if (data == null) {
          return _buildAvatar(context, 'U', null);
        }

        final name = data['name'] as String? ?? '';
        final profilePhotoUrl = data['profilePhotoUrl'] as String?;
        final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

        return _buildAvatar(context, initial, profilePhotoUrl);
      },
    );
  }

  Widget _buildAvatar(BuildContext context, String initial, String? profilePhotoUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 48,
          height: 48,
          child: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            backgroundImage: profilePhotoUrl != null ? NetworkImage(profilePhotoUrl) : null,
            child: profilePhotoUrl == null
                ? Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
} 
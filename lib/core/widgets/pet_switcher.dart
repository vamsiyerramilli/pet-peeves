import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/pets/models/pet_model.dart';
import '../../features/auth/services/auth_service.dart';

class PetSwitcher extends StatelessWidget {
  final List<String> petIds;
  final String? activePetId;
  final Function(String) onPetSelected;

  const PetSwitcher({
    super.key,
    required this.petIds,
    required this.activePetId,
    required this.onPetSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (petIds.isEmpty || activePetId == null) {
      return const SizedBox.shrink();
    }

    final authService = AuthService();
    final currentUser = authService.currentUser;

    if (currentUser == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('pets')
          .doc(activePetId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox.shrink();
        }

        final activePet = PetModel.fromFirestore(snapshot.data!);

        return InkWell(
          onTap: () => _showPetSelector(context, currentUser.uid),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: activePet.profilePhotoUrl != null
                    ? NetworkImage(activePet.profilePhotoUrl!)
                    : null,
                child: activePet.profilePhotoUrl == null
                    ? Text(
                        activePet.name.isNotEmpty ? activePet.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                activePet.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showPetSelector(BuildContext context, String userId) async {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    final String? selected = await showMenu<String>(
      context: context,
      position: position,
      items: await _buildMenuItems(userId, context),
    );

    if (selected != null && selected != activePetId) {
      onPetSelected(selected);
    }
  }

  Future<List<PopupMenuEntry<String>>> _buildMenuItems(String userId, BuildContext context) async {
    final List<PopupMenuEntry<String>> items = [];
    const int maxVisiblePets = 4;

    for (var i = 0; i < petIds.length; i++) {
      if (i == maxVisiblePets && i < petIds.length - 1) {
        // Add a "More" item that shows a dialog with remaining pets
        items.add(
          PopupMenuItem<String>(
            value: 'more',
            child: const Text('More pets...'),
            onTap: () => _showMorePetsDialog(context, userId),
          ),
        );
        break;
      }

      final petDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('pets')
          .doc(petIds[i])
          .get();
      
      if (!petDoc.exists) continue;

      final pet = PetModel.fromFirestore(petDoc);
      items.add(
        PopupMenuItem<String>(
          value: pet.id,
          child: Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundImage: pet.profilePhotoUrl != null
                    ? NetworkImage(pet.profilePhotoUrl!)
                    : null,
                child: pet.profilePhotoUrl == null
                    ? Text(
                        pet.name.isNotEmpty ? pet.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Text(pet.name),
              if (pet.id == activePetId)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.check, size: 16),
                ),
            ],
          ),
        ),
      );
    }

    return items;
  }

  Future<void> _showMorePetsDialog(BuildContext context, String userId) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Pet'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: petIds.length,
            itemBuilder: (context, index) {
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection('pets')
                    .doc(petIds[index])
                    .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const SizedBox.shrink();
                  }

                  final pet = PetModel.fromFirestore(snapshot.data!);
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: pet.profilePhotoUrl != null
                          ? NetworkImage(pet.profilePhotoUrl!)
                          : null,
                      child: pet.profilePhotoUrl == null
                          ? Text(
                              pet.name.isNotEmpty ? pet.name[0].toUpperCase() : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    title: Text(pet.name),
                    trailing: pet.id == activePetId
                        ? const Icon(Icons.check)
                        : null,
                    onTap: () {
                      onPetSelected(pet.id);
                      Navigator.pop(context);
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
} 
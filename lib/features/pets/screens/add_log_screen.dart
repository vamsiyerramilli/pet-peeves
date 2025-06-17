import 'package:flutter/material.dart';
import '../models/health_log_model.dart';
import '../../food/widgets/food_entry_modal.dart';
import '../../measurements/widgets/measurement_entry_modal.dart';

class AddLogScreen extends StatelessWidget {
  final String petId;

  const AddLogScreen({
    super.key,
    required this.petId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Add New Log',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.medical_services),
            title: const Text('Health Log'),
            onTap: () {
              // TODO: Navigate to health log form
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.straighten),
            title: const Text('Measurement'),
            onTap: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: MeasurementEntryModal(
                    petId: petId,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.restaurant),
            title: const Text('Food Log'),
            onTap: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: FoodEntryModal(petId: petId),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.event_note),
            title: const Text('Activity Log'),
            onTap: () {
              // TODO: Navigate to activity log form
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
} 
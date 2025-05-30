import 'package:flutter/material.dart';
import 'package:pet_peeves/models/pet.dart';
import 'package:pet_peeves/screens/logs/measurements_log_screen.dart';
import 'package:pet_peeves/services/pet_service.dart';

class MeasurementsCard extends StatelessWidget {
  final Pet pet;
  final PetService petService;
  final List<dynamic> recentLogs;

  const MeasurementsCard({
    super.key,
    required this.pet,
    required this.petService,
    required this.recentLogs,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MeasurementsLogScreen(
                pet: pet,
                petService: petService,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Measurements',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MeasurementsLogScreen(
                            pet: pet,
                            petService: petService,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (recentLogs.isEmpty)
                const Center(
                  child: Text('No recent measurements'),
                )
              else
                ...recentLogs.map((log) => Column(
                      children: [
                        _buildMeasurementRow(
                          'Weight',
                          '${log.weight} kg',
                          Icons.monitor_weight,
                        ),
                        _buildMeasurementRow(
                          'Height',
                          '${log.height} cm',
                          Icons.height,
                        ),
                        _buildMeasurementRow(
                          'Length',
                          '${log.length} cm',
                          Icons.straighten,
                        ),
                        const Divider(),
                      ],
                    )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeasurementRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 16),
          Text(label),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
} 
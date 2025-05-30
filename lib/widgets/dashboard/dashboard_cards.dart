import 'package:flutter/material.dart';
import 'package:pet_peeves/models/pet.dart';

class FoodCard extends StatelessWidget {
  final Pet pet;
  final VoidCallback onAddLog;

  const FoodCard({
    super.key,
    required this.pet,
    required this.onAddLog,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Food & Diet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: onAddLog,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // TODO: Add food trend chart
            Container(
              height: 100,
              color: Colors.grey[200],
              child: const Center(
                child: Text('Food Trend Chart'),
              ),
            ),
            const SizedBox(height: 16),
            if (pet.foods != null && pet.foods!.isNotEmpty) ...[
              const Text(
                'Current Diet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              ...pet.foods!.map((food) => ListTile(
                    title: Text(food.name),
                    subtitle: Text('${food.energyPerGram} kcal/g'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

class MeasurementsCard extends StatelessWidget {
  final Pet pet;
  final VoidCallback onAddMeasurement;

  const MeasurementsCard({
    super.key,
    required this.pet,
    required this.onAddMeasurement,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Measurements',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: onAddMeasurement,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (pet.measurements != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MeasurementItem(
                    label: 'Weight',
                    value: '${pet.measurements!.weight} kg',
                    icon: Icons.monitor_weight,
                  ),
                  _MeasurementItem(
                    label: 'Height',
                    value: '${pet.measurements!.height} cm',
                    icon: Icons.height,
                  ),
                  _MeasurementItem(
                    label: 'Length',
                    value: '${pet.measurements!.length} cm',
                    icon: Icons.straighten,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            // TODO: Add weight trend chart
            Container(
              height: 100,
              color: Colors.grey[200],
              child: const Center(
                child: Text('Weight Trend Chart'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HealthCard extends StatelessWidget {
  final Pet pet;
  final VoidCallback onAddVaccination;
  final VoidCallback onViewHistory;

  const HealthCard({
    super.key,
    required this.pet,
    required this.onAddVaccination,
    required this.onViewHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Health',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: onAddVaccination,
                    ),
                    IconButton(
                      icon: const Icon(Icons.history),
                      onPressed: onViewHistory,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (pet.vaccinations != null && pet.vaccinations!.isNotEmpty) ...[
              const Text(
                'Vaccination Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              ...pet.vaccinations!.map((vaccination) {
                final isUpcoming = vaccination.nextDueDate != null &&
                    vaccination.nextDueDate!.isAfter(DateTime.now());
                return ListTile(
                  title: Text(vaccination.name),
                  subtitle: Text(
                    'Last: ${vaccination.date.day}/${vaccination.date.month}/${vaccination.date.year}',
                  ),
                  trailing: isUpcoming
                      ? Chip(
                          label: Text(
                            'Due: ${vaccination.nextDueDate!.day}/${vaccination.nextDueDate!.month}/${vaccination.nextDueDate!.year}',
                          ),
                          backgroundColor: Colors.orange[100],
                        )
                      : null,
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

class _MeasurementItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MeasurementItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
} 
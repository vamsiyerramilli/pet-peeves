import 'package:flutter/material.dart';
import 'package:pet_peeves/models/pet.dart';
import 'package:pet_peeves/screens/logs/health_log_screen.dart';
import 'package:pet_peeves/services/pet_service.dart';
import 'package:intl/intl.dart';

class HealthCard extends StatelessWidget {
  final Pet pet;
  final PetService petService;
  final List<dynamic> recentLogs;

  const HealthCard({
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
              builder: (context) => HealthLogScreen(
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
                    'Health',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HealthLogScreen(
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
                  child: Text('No recent health records'),
                )
              else
                ...recentLogs.map((log) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              log.type,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              DateFormat('MMM d').format(log.timestamp),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        if (log.notes?.isNotEmpty ?? false) ...[
                          const SizedBox(height: 4),
                          Text(
                            log.notes!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                        if (log.nextDueDate != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'Next due: ${DateFormat('MMM d').format(log.nextDueDate!)}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                            ],
                          ),
                        ],
                        const Divider(),
                      ],
                    )),
            ],
          ),
        ),
      ),
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:pet_peeves/models/pet.dart';
import 'package:pet_peeves/screens/logs/food_log_screen.dart';
import 'package:pet_peeves/services/pet_service.dart';

class FoodCard extends StatelessWidget {
  final Pet pet;
  final PetService petService;
  final List<dynamic> recentLogs;

  const FoodCard({
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
              builder: (context) => FoodLogScreen(
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
                    'Food',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FoodLogScreen(
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
                  child: Text('No recent food entries'),
                )
              else
                ...recentLogs.map((log) => ListTile(
                      leading: const Icon(Icons.restaurant),
                      title: Text(log.foodName),
                      subtitle: Text(
                        '${log.amount}g • ${log.energyPerGram * log.amount} kcal',
                      ),
                      trailing: Text(
                        _formatDate(log.timestamp),
                      ),
                    )),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${(difference.inDays / 7).floor()} weeks ago';
    }
  }
} 
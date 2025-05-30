import 'package:flutter/material.dart';
import 'package:pet_peeves/models/pet.dart';
import 'package:pet_peeves/services/pet_service.dart';

class TimelineScreen extends StatefulWidget {
  final Pet pet;
  final PetService petService;

  const TimelineScreen({
    super.key,
    required this.pet,
    required this.petService,
  });

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.pet.name}\'s Timeline'),
      ),
      body: Center(
        child: Text('Timeline coming soon'),
      ),
    );
  }
} 
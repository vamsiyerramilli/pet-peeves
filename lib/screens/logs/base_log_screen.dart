import 'package:flutter/material.dart';
import 'package:pet_peeves/models/pet.dart';

abstract class BaseLogScreen extends StatefulWidget {
  final Pet pet;
  final String title;
  final String emptyMessage;

  const BaseLogScreen({
    super.key,
    required this.pet,
    required this.title,
    required this.emptyMessage,
  });

  @override
  State<BaseLogScreen> createState() => _BaseLogScreenState();
}

class _BaseLogScreenState<T extends BaseLogScreen> extends State<T> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEntryDialog(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildLogList(),
    );
  }

  Widget _buildLogList() {
    return StreamBuilder(
      stream: getLogStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final logs = snapshot.data;
        if (logs == null || logs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.emptyMessage,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showAddEntryDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Entry'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: logs.length,
          itemBuilder: (context, index) {
            return buildLogItem(logs[index]);
          },
        );
      },
    );
  }

  Stream getLogStream();
  Widget buildLogItem(dynamic log);
  Future<void> _showAddEntryDialog(BuildContext context);
} 
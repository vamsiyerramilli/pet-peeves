import 'package:flutter/material.dart';
import 'package:pet_peeves/models/logs.dart';
import 'package:intl/intl.dart';

class TimelineItem extends StatefulWidget {
  final BaseLog log;

  const TimelineItem({
    super.key,
    required this.log,
  });

  @override
  State<TimelineItem> createState() => _TimelineItemState();
}

class _TimelineItemState extends State<TimelineItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final (icon, color) = switch (widget.log.type) {
      LogType.food => (Icons.restaurant, Colors.orange),
      LogType.health => (Icons.favorite, Colors.red),
      LogType.vaccine => (Icons.vaccines, Colors.blue),
    };

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getTitle(),
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM d, y • h:mm a')
                              .format(widget.log.timestamp),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ],
              ),
              if (_isExpanded) ...[
                const Divider(height: 24),
                _buildDetails(),
                if (widget.log.notes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Notes',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.log.notes,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getTitle() {
    return switch (widget.log) {
      FoodLog log => '${log.amount} ${log.unit} of ${log.foodName}',
      HealthLog log => '${log.condition} (${log.severity})',
      VaccineLog log => log.vaccineName,
      _ => 'Unknown Log Type',
    };
  }

  Widget _buildDetails() {
    return switch (widget.log) {
      FoodLog log => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow(
              label: 'Food',
              value: log.foodName,
            ),
            _DetailRow(
              label: 'Amount',
              value: '${log.amount} ${log.unit}',
            ),
            if (log.energyContent != null)
              _DetailRow(
                label: 'Energy',
                value: '${log.energyContent} kcal/g',
              ),
          ],
        ),
      HealthLog log => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow(
              label: 'Condition',
              value: log.condition,
            ),
            _DetailRow(
              label: 'Severity',
              value: log.severity,
            ),
            _DetailRow(
              label: 'Symptoms',
              value: log.symptoms.join(', '),
            ),
            if (log.diagnosis != null)
              _DetailRow(
                label: 'Diagnosis',
                value: log.diagnosis!,
              ),
            if (log.treatment != null)
              _DetailRow(
                label: 'Treatment',
                value: log.treatment!,
              ),
          ],
        ),
      VaccineLog log => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow(
              label: 'Vaccine',
              value: log.vaccineName,
            ),
            _DetailRow(
              label: 'Administered By',
              value: log.administeredBy,
            ),
            _DetailRow(
              label: 'Next Due',
              value: DateFormat('MMM d, y').format(log.nextDueDate),
            ),
            if (log.batchNumber != null)
              _DetailRow(
                label: 'Batch Number',
                value: log.batchNumber!,
              ),
          ],
        ),
      _ => const SizedBox.shrink(),
    };
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
} 
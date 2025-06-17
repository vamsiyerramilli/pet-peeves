import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import '../../../core/store/app_state.dart';
import '../../food/widgets/food_timeline.dart';
import '../../measurements/widgets/measurement_timeline.dart';

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      converter: (store) => _ViewModel.fromStore(store),
      builder: (context, vm) {
        if (!vm.hasPets) {
          return const Center(
            child: Text('No pets added yet'),
          );
        }

        if (vm.activePetId == null) {
          return const Center(
            child: Text('Select a pet to view logs'),
          );
        }

        return DefaultTabController(
          length: 4,
          child: Column(
            children: [
              TabBar(
                isScrollable: true,
                tabs: const [
                  Tab(text: 'Food'),
                  Tab(text: 'Health'),
                  Tab(text: 'Measurements'),
                  Tab(text: 'Activity'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    // Food Timeline
                    FoodTimeline(petId: vm.activePetId!),
                    // Other logs - Coming soon
                    const Center(child: Text('Health Logs - Coming Soon')),
                    // Measurements Timeline
                    MeasurementTimeline(petId: vm.activePetId!),
                    const Center(child: Text('Activity Logs - Coming Soon')),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ViewModel {
  final bool hasPets;
  final String? activePetId;

  _ViewModel({
    required this.hasPets,
    this.activePetId,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    return _ViewModel(
      hasPets: store.state.pets.petIds.isNotEmpty,
      activePetId: store.state.pets.activePetId,
    );
  }
} 
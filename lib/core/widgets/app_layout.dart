import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import '../store/app_state.dart';
import '../store/actions.dart';
import '../theme/app_theme.dart';
import 'pet_switcher.dart';
import 'user_avatar.dart';
import '../../features/pets/screens/add_log_screen.dart';
import '../../features/pets/screens/edit_pet_screen.dart';

class AppLayout extends StatelessWidget {
  final Map<AppTab, Widget> tabViews;

  const AppLayout({
    super.key,
    required this.tabViews,
  });

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      converter: (store) => _ViewModel.fromStore(store),
      builder: (context, vm) {
        return Scaffold(
          appBar: AppBar(
            title: vm.hasPets
                ? PetSwitcher(
                    petIds: vm.petIds,
                    activePetId: vm.activePetId,
                    onPetSelected: vm.setActivePet,
                  )
                : null,
            actions: [
              UserAvatar(
                onTap: () {
                  // TODO: Navigate to profile/settings
                },
              ),
            ],
          ),
          body: IndexedStack(
            index: vm.activeTab.index,
            children: AppTab.values.map((tab) => tabViews[tab]!).toList(),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: vm.activeTab.index,
            onTap: (index) => vm.setActiveTab(AppTab.values[index]),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt),
                label: 'Logs',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.pets),
                label: 'Pet Info',
              ),
            ],
          ),
          floatingActionButton: _buildFAB(context, vm),
        );
      },
    );
  }

  Widget? _buildFAB(BuildContext context, _ViewModel vm) {
    if (!vm.hasPets || vm.activePetId == null) {
      return null;
    }

    switch (vm.activeTab) {
      case AppTab.home:
      case AppTab.logs:
        return FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => AddLogScreen(petId: vm.activePetId!),
            );
          },
          child: const Icon(Icons.add),
        );
      case AppTab.petInfo:
        return FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditPetScreen(petId: vm.activePetId!),
              ),
            );
          },
          child: const Icon(Icons.edit),
        );
      default:
        return null;
    }
  }
}

class _ViewModel {
  final AppTab activeTab;
  final List<String> petIds;
  final String? activePetId;
  final bool hasPets;
  final Function(AppTab) setActiveTab;
  final Function(String) setActivePet;

  _ViewModel({
    required this.activeTab,
    required this.petIds,
    required this.activePetId,
    required this.hasPets,
    required this.setActiveTab,
    required this.setActivePet,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    return _ViewModel(
      activeTab: store.state.navigation.activeTab,
      petIds: store.state.pets.petIds,
      activePetId: store.state.pets.activePetId,
      hasPets: store.state.pets.petIds.isNotEmpty,
      setActiveTab: (tab) => store.dispatch(SetActiveTabAction(tab)),
      setActivePet: (petId) => store.dispatch(SetActivePetAction(petId)),
    );
  }
} 
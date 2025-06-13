import '../models/food.dart';
import '../models/food_tracking_entry.dart';

// Load foods
class LoadFoodsAction {
  final String userId;
  final String? query;

  LoadFoodsAction(this.userId, [this.query]);
}

class LoadFoodsSuccessAction {
  final List<Food> foods;
  final bool wasOptimistic;

  LoadFoodsSuccessAction(this.foods, {this.wasOptimistic = false});
}

class LoadFoodsFailureAction {
  final String error;

  LoadFoodsFailureAction(this.error);
}

// Add food
class AddFoodAction {
  final Food food;
  final bool optimistic;

  AddFoodAction(this.food, {this.optimistic = false});
}

class AddFoodSuccessAction {
  final Food food;
  final bool wasOptimistic;

  AddFoodSuccessAction(this.food, {this.wasOptimistic = false});
}

class AddFoodFailureAction {
  final String error;
  final Food food;
  final bool wasOptimistic;

  AddFoodFailureAction(this.error, this.food, {this.wasOptimistic = false});
}

// Update food
class UpdateFoodAction {
  final Food food;
  final bool optimistic;

  UpdateFoodAction(this.food, {this.optimistic = false});
}

class UpdateFoodSuccessAction {
  final Food food;
  final bool wasOptimistic;

  UpdateFoodSuccessAction(this.food, {this.wasOptimistic = false});
}

class UpdateFoodFailureAction {
  final String error;
  final Food food;
  final bool wasOptimistic;

  UpdateFoodFailureAction(this.error, this.food, {this.wasOptimistic = false});
}

// Delete food
class DeleteFoodAction {
  final String foodId;
  final bool optimistic;

  DeleteFoodAction(this.foodId, {this.optimistic = false});
}

class DeleteFoodSuccessAction {
  final String foodId;
  final bool wasOptimistic;

  DeleteFoodSuccessAction(this.foodId, {this.wasOptimistic = false});
}

class DeleteFoodFailureAction {
  final String error;
  final String foodId;
  final bool wasOptimistic;

  DeleteFoodFailureAction(this.error, this.foodId, {this.wasOptimistic = false});
}

// Food entries
class LoadFoodEntriesAction {
  final String petId;
  final DateTime? startDate;
  final DateTime? endDate;

  LoadFoodEntriesAction(this.petId, {this.startDate, this.endDate});
}

class LoadFoodEntriesSuccessAction {
  final String petId;
  final List<FoodTrackingEntry> entries;
  final bool wasOptimistic;

  LoadFoodEntriesSuccessAction(this.petId, this.entries, {this.wasOptimistic = false});
}

class LoadFoodEntriesFailureAction {
  final String error;
  final String petId;

  LoadFoodEntriesFailureAction(this.error, this.petId);
}

class AddFoodEntryAction {
  final FoodTrackingEntry entry;
  final bool optimistic;

  AddFoodEntryAction(this.entry, {this.optimistic = false});
}

class AddFoodEntrySuccessAction {
  final FoodTrackingEntry entry;
  final bool wasOptimistic;

  AddFoodEntrySuccessAction(this.entry, {this.wasOptimistic = false});
}

class AddFoodEntryFailureAction {
  final String error;
  final FoodTrackingEntry entry;
  final bool wasOptimistic;

  AddFoodEntryFailureAction(this.error, this.entry, {this.wasOptimistic = false});
}

class UpdateFoodEntryAction {
  final FoodTrackingEntry entry;
  final bool optimistic;

  UpdateFoodEntryAction(this.entry, {this.optimistic = false});
}

class UpdateFoodEntrySuccessAction {
  final FoodTrackingEntry entry;
  final bool wasOptimistic;

  UpdateFoodEntrySuccessAction(this.entry, {this.wasOptimistic = false});
}

class UpdateFoodEntryFailureAction {
  final String error;
  final FoodTrackingEntry entry;
  final bool wasOptimistic;

  UpdateFoodEntryFailureAction(this.error, this.entry, {this.wasOptimistic = false});
}

class DeleteFoodEntryAction {
  final String petId;
  final String entryId;
  final bool optimistic;

  DeleteFoodEntryAction(this.petId, this.entryId, {this.optimistic = false});
}

class DeleteFoodEntrySuccessAction {
  final String entryId;
  final bool wasOptimistic;

  DeleteFoodEntrySuccessAction(this.entryId, {this.wasOptimistic = false});
}

class DeleteFoodEntryFailureAction {
  final String error;
  final String petId;
  final String entryId;
  final bool wasOptimistic;

  DeleteFoodEntryFailureAction(this.error, this.petId, this.entryId, {this.wasOptimistic = false});
}

// Search foods (client-side filtering)
class SearchFoodsAction {
  final String query;

  SearchFoodsAction(this.query);
} 
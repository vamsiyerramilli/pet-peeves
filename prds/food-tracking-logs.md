# Objective

Enable users to log, manage, and review food entries for their pets, with seamless integration between the food database and tracking entries. The system must be scalable for future enhancements, including a timeline view of food logs, and maintain consistency with existing app navigation and design.

---

# User Stories

1. As a user, I want to log food entries with details like food type, weight, and time.
2. As a user, I want to select foods from a pre-defined list or add new foods on the fly.
3. As a user, I want calories to auto-calculate based on food type and weight.
4. As a user, I want to edit or delete existing food entries.
5. As a user, I want to manage my food list (add/edit/delete) in the Profile section.
6. As a user, I want to see all my food entries as a timeline, either from the Home screen or the Logs tab.
7. As a user, I want food tracking to work offline and sync later.
8. As a user, I want the food entry UI to be consistent and accessible across discovery points.

---

# User Journey

## Adding a Food Entry

1. User taps FAB on Home/Logs screen → “Add Food Entry” modal opens.
2. User selects food from dropdown or adds a new food.
3. User enters weight → kcal auto-calculates (if possible).
4. User saves → entry appears in logs and updates pet’s daily summary.

## Managing Food List

1. User navigates to Profile → “Manage Foods” section.
2. User adds/edits/deletes foods → changes sync to all food entry screens.

## Viewing Food Entry Timeline (Provision)

1. User clicks on the Home screen food card or navigates to the Logs tab.
2. User sees a timeline view of all food entries for the selected pet (provision for future implementation).
3. Timeline groups entries by date/time, showing food name, type, weight, kcal, and notes.

---

# UI/UX Elements

## Food Entry Modal

- **Fields:**
    1. **Time & Date:** Default to current; editable.
    2. **Food Type:** Dropdown (Dry, Wet, Treats).
    3. **Food Name:** Autocomplete dropdown with "+ Add New Food" option.
    4. **Weight (grams):** Numeric input.
    5. **kCal:** Auto-calculated or "NA" if missing.
    6. **Notes:** Optional.
- **Buttons:** Save, Cancel.

## Food List Management (Profile Section)

- List with search bar and "+ Add Food" button.
- Food cards with name, type, kcal/g, edit/delete icons.
- Add/Edit Food form (kcal/g required).

## Timeline View (Provision Only)

- **Screens:**
    - Home screen food card (when clicked)
    - Logs tab (dedicated timeline section)
- **Layout:**
    - Chronological list grouped by date.
    - Each entry: time, food name, type, weight, kcal, notes.
    - Scrollable, with date separators.
- **Provisioning:**
    - Data models, Redux state, and API responses should support fetching and displaying entries in timeline order.
    - UI components should be designed to allow easy addition of the timeline view in future sprints.

## Discovery Points

1. Home Screen FAB: “Add Food Entry.”
2. Logs Screen FAB: “Add Food Entry.”
3. (Future) Home screen food card: “View Food Timeline.”

---

## Accessibility

1. High contrast colors for text and icons.
2. Large tap targets (min 48x48 dp).
3. Screen reader support with proper labels.
4. Keyboard navigation where applicable.
5. Dynamic font scaling.

---

# Technical Specifications

## Food Model

Dart:

```dart
enum FoodType { dry, wet, treat, other }

class Food {
  final String id;
  final String name;
  final FoodType type;
  final double? kCalPerGram;
  final DateTime createdAt;
  final String? createdBy;
  final DateTime? updatedAt;

  Food({
    required this.id,
    required this.name,
    required this.type,
    this.kCalPerGram,
    required this.createdAt,
    required this.createdBy,
    this.updatedAt,
  });

  // Add fromJson/toJson methods for Firestore mapping
}
```

Firestore:

```json
{
  "id": "foodId",                // Firestore doc ID, also stored in the doc if needed
  "name": "Chicken Kibble",
  "type": "dry",                 // "dry", "wet", "treat", "other"
  "kCalPerGram": 3.5,
  "createdAt": "timestamp",
  "createdBy": "userId",
  "updatedAt": "timestamp"
}
```

**Note:**

- Enum values in Dart (**`FoodType`**) must map exactly to Firestore strings.
- **`createdBy`** is optional in Dart, but recommended for consistency: auto-populate the user name

## FoodTrackingEntry Model

```dart
class FoodTrackingEntry {
  final String id;
  final String petId;
  final DateTime timestamp;
  final String foodId;
  final String foodName;           // denormalized
  final FoodType type;             // denormalized
  final double? kCalPerGram;       // denormalized
  final double weightGrams;
  final double? kCal;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  FoodTrackingEntry({
    required this.id,
    required this.petId,
    required this.timestamp,
    required this.foodId,
    required this.foodName,
    required this.type,
    this.kCalPerGram,
    required this.weightGrams,
    this.kCal,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  // Add fromJson/toJson methods for Firestore mapping
}
```

Firestore:

```json
{
  "id": "foodIntakeId",           // Firestore doc ID, also stored in the doc if needed
  "timestamp": "datetime",
  "foodId": "foodId",
  "foodName": "Chicken Kibble",   // denormalized for historical accuracy
  "type": "dry",                  // denormalized FoodType
  "kCalPerGram": 3.5,             // denormalized, nullable
  "weightGrams": 100,
  "kCal": 350,                    // calculated at entry time, nullable
  "notes": "Breakfast",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**Notes:**

- All denormalized fields (**`foodName`**, **`type`**, **`kCalPerGram`**, **`kCal`**) are present for historical accuracy and timeline display.
- **`kCal`** is calculated at entry time and stored; do not recalculate for historical entries unless specifically required by logic (as in your PRD).
- **`petId`** is stored in Dart for easier state management, even though the Firestore path already includes it.

### **Final Notes and Best Practices**

- **Denormalize** key fields in food intake entries for timeline/historical accuracy and to support your PRD’s edge cases.
- **Always update** both the Firestore and Dart models together to avoid mismatch.
- **Document enum mappings** and nullable fields for future maintainers.
- **Add fromJson/toJson** methods in Dart for Firestore serialization/deserialization.

## State Management (Redux Slices)

1. **Food Slice**
    - Stores: **`List<Food>`**, search/filter state.
    - Actions: **`AddFood`**, **`UpdateFood`**, **`DeleteFood`**, **`SearchFoods`**.
2. **Tracking Slice**
    - Stores: **`List<FoodTrackingEntry>`** (by petId, sorted by timestamp for timeline).
    - Actions: **`AddEntry`**, **`EditEntry`**, **`DeleteEntry`**.
3. **Provision for Timeline View**
    - Ensure **`Tracking Slice`** supports efficient retrieval and grouping of entries by date for timeline display.
    - This should support pagination parameters (e.g., limit/offset or cursor-based) to avoid performance issues with large logs.

## API Integration

- **Fetch Food List:** GET **`/foods`** (cached for offline use).
- **Sync New Food:** POST **`/foods`** (queue requests if offline).
- **Sync Entries:** POST **`/entries/food`** (batch upload if offline).
- **Fetch Timeline:** GET **`/entries/food?petId={id}&sort=desc`** (API and Redux should support timeline queries).

---

# Error Handling

1. **Offline Mode:**
    - Store entries/foods locally → sync when online.
    - Show banner: “Offline – data will sync later.”
2. **Validation Errors:**
    - Highlight empty required fields.
3. **Sync Failures:**
    - Retry 3x → show “Sync failed” message with manual retry and ask the user to retry later

---

# Edge Cases

- User adds a new food during entry but deletes it later: Preserve entry’s food name, mark as “Food no longer in list.”
    - this should only affect the entries moving forward - not retroactively
- kCal data added or updated after entry creation:
    - Do NOT back-calculate historical entries, if a kCal entry was already present before (i.e., edit scenatio)
    - If kCal is updated from NA, back calculate values and notify the user via a toast that historical values will be populated
- User edits a food’s kcal/g: Future entries use new value; historical remain unchanged.
- No foods in list: Show “Add your first food” prompt.
- User has a large number of food entries: Timeline view must handle large datasets efficiently (provision for infinite scroll)

---

# Acceptance Criteria

- Users can add/edit/delete food entries from multiple discovery points.
- Food list and entries sync across all screens in real-time.
- Auto-calculation works for known foods; “NA” handled gracefully.
- Offline usage supported with local storage.
- Timeline view is provisioned in codebase and data models, ready for future UI implementation.
- UI matches existing app design and accessibility standards.

---

# Implementation Order

1. Define Food + Tracking data models.
2. Build Food Entry Modal UI (Flutter widget).
3. Create Redux slices for food + tracking (with timeline-ready state).
4. Implement API service with offline queue.
5. Integrate food autocomplete dropdown with Redux.
6. Add food management UI to Profile section.
7. Provision timeline view in state/API (no UI yet).
8. Test sync, validation, and edge cases.
9. Optimize for large food lists and logs.

---

# Testing

## Devices

- iPhone 13–16 (iOS)
- Architecture should be platform agnostic as the plan is to expand into android later

## Scenarios

- **Happy Path:** Add entry → verify sync → edit → delete.
- **Edge Cases:**
    - Add food offline → check sync on reconnect.
    - Edit food used in existing entries.
    - Enter large weight values.
    - Ensure timeline data is available for future UI.

---

**Note:**

Timeline view does not need to be implemented now, but all data models, APIs, and Redux slices should be designed to support it with minimal changes in the future.
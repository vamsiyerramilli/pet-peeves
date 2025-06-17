Objective
Enable users to log, manage, and review standardized measurement entries (weight, height, length) for their pets. The system must be simple, scalable, and consistent with the food tracking module, supporting timeline visualization, offline entry, and robust validation provisioning
User Stories
- As a user, I want to log weight, height, and length for my pet, entering any or all measurements per entry.
- As a user, I want to add optional notes to each measurement entry.
- As a user, I want to edit or delete my measurement entries, with the system keeping an audit trail but showing only the latest value.
- As a user, I want to see a timeline of all measurement entries for each pet.
- As a user, I want measurement logging to work offline and sync later.
- As a user, I want the measurement entry UI to be accessible and consistent across discovery points.
User Journey
Adding a Measurement Entry
- User taps FAB on Home/Logs screen → “Add Measurement Entry” modal opens.
- User enters one or more of: Weight (kg), Height (cm), Length (cm).
- User optionally adds notes (free text; provision for future tags).
- User sets date/time (default to current; editable).
- User saves → entry appears in logs and updates pet’s measurement timeline.
Editing/Deleting an Entry
- User finds entry in timeline → taps to edit or delete.
- System updates entry, maintains audit trail, but only shows latest value to user.
Viewing Measurement Timeline
- User clicks on Home screen measurement card or navigates to Logs tab.
- User sees a timeline view of all measurement entries for the selected pet, grouped by date/time.
UI/UX Specifications
Measurement Entry Modal
- Fields:
    - Time & Date: Default to current; editable.
    - Weight (kg): Numeric (float), optional.
    - Height (cm): Numeric (float), optional.
    - Length (cm): Numeric (float), optional.
    - Notes: Optional free text (provision for tags).
- Buttons: Save, Cancel.
- Validation: At least one measurement field required. No negative or out-of-range values.
Timeline View
- Chronological list grouped by date.
- Each entry: time, weight, height, length, notes.
- Scrollable, with date separators.
- Pagination/infinite scroll for large datasets1.
Discovery Points
- Home Screen FAB: “Add Measurement Entry.”
- Logs Screen FAB: “Add Measurement Entry.”
- (Future) Home screen measurement card: “View Measurement Timeline.”
Accessibility
- High contrast colors for text and icons.
- Large tap targets (min 48x48 dp).
- Screen reader support with proper labels.
- Keyboard navigation where applicable.
- Dynamic font scaling
Technical Specifications
Measurement Model
class MeasurementEntry {   
  final String id;  
  final String petId;  
  final DateTime timestamp;  
  final double? weightKg;    // Optional, float, 0.01–1000  
  final double? heightCm;    // Optional, float, 
  1–10000  final double? lengthCm;    // Optional, float, 1–10000  
  final String? notes;       // Optional, free text  
  final String? createdBy;   // For future multi-user support  
  final DateTime createdAt;  
  final DateTime? updatedAt;  
  // Audit trail (not exposed to user)  
  final List<MeasurementAudit>? auditTrail; }
Firestore Example
{   
  "id": "measurementId",  
  "petId": "petId",  
  "timestamp": "datetime",  
  "weightKg": 4.5,  
  "heightCm": 32.0,  
  "lengthCm": null,  
  "notes": "After vet visit", 
  "createdBy": "userId",
  "createdAt": "timestamp",  
  "updatedAt": "timestamp",  
  "auditTrail": [    
    {      
      "updatedAt": "timestamp",      
      "updatedBy": "userId",      
      "oldValues": { ... }    
    }  
  ] 
}
Validation
- Weight: 0.01–1000 kg
- Height/Length: 1–10000 cm (100 m)
- No negative or zero values.
- At least one measurement field required per entry.
- Provision for future validation rules, but only basic range checks implemented now.
State Management
- Measurement Slice:
    - Stores: List (by petId, sorted by timestamp).
    - Actions: AddEntry, EditEntry, DeleteEntry.
    - Supports efficient retrieval/grouping for timeline display.
    - Supports pagination for large logs
API Integration
- Sync New Entry: POST /entries/measurement (queue requests if offline).
- Fetch Timeline: GET /entries/measurement?petId={id}&sort=desc (support pagination).
- Edit/Delete: PATCH/DELETE /entries/measurement/{id}
- Offline Mode: Store entries locally, sync when online2.
- Show banner: “Offline – data will sync later.”
Error Handling
- Validation errors: Highlight invalid fields, prevent save.
- Sync failures: Retry 3x, show “Sync failed” message with manual retry.
- No measurements: Show “Add your first measurement” prompt.
- Large logs: Timeline view must handle large datasets efficiently (pagination/infinite scroll)
Edge Cases
- User enters only one measurement: Allowed, as all fields are optional except at least one must be filled.
- Negative or out-of-range values: Show error, prevent save.
- Edit/delete: Only latest value shown, full audit trail maintained internally.
- Multi-user: Store createdBy for future support, but no UI for this yet.
- Future extensibility: Model allows for new measurement types (e.g., temperature) to be added later.
Acceptance Criteria
- Users can add/edit/delete measurement entries from multiple discovery points.
- Entries sync across all screens in real-time (when online).
- Offline usage supported with local storage and later sync.
- Timeline view is provisioned and paginated for large logs.
- UI matches existing app design and accessibility standards.
- Validation prevents negative, zero, or out-of-range values.
- Audit trail is maintained for all edits/deletions, but only latest value shown to user.
Implementation Order
To ensure a smooth rollout and maintain consistency with your food tracking module, follow this implementation sequence for the measurement logs module:
1. Define Data Models
    - Implement the MeasurementEntry model (Dart, Firestore mapping) with audit trail support and value range provisioning.
2. Build Measurement Entry Modal UI
    - Create the measurement entry form (weight, height, length, notes, date/time) with validation, error handling, and accessibility features.
3. Create Redux Slice for Measurements
    - Set up state management for measurement entries (by petId, sorted by timestamp), including actions for add, edit, delete, and audit trail.
4. Implement API Service with Offline Queue
    - Develop API endpoints and offline sync logic (queue writes, retry on reconnect, local storage).
5. Integrate Measurement Entry Points
    - Add FABs and navigation from Home, Logs, and other discovery points, mirroring food tracking.
6. Provision Timeline View
    - Implement timeline view UI for measurements (grouped by date, paginated, infinite scroll support).
7. Add Edit and Delete Functionality
    - Enable editing and deletion of entries, maintaining audit trails and showing only the latest value.
8. Optimize for Performance
    - Implement pagination and optimize data retrieval for large logs.
9. Testing and QA
    - Conduct comprehensive testing (see scenarios below).
10. Accessibility Review
    - Audit and adjust for accessibility compliance
Testing
Devices
- iPhone 13–16 (iOS)
- Platform-agnostic architecture for future Android support
Happy Path
- Add measurement entry (any combination of weight, height, length) → verify it appears in timeline.
- Edit an entry → confirm only latest value is shown, audit trail is updated.
- Delete an entry → ensure removal from timeline, audit trail persists.
- Add entry with notes → confirm notes are saved and displayed.
Validation & Error Handling
- Attempt to save with all fields empty → error shown, entry not saved.
- Enter negative or out-of-range values for weight, height, or length → error shown, entry not saved.
- Enter extremely large values (e.g., 1001 kg, 10001 cm) → error shown, entry not saved.
- Enter only one measurement (e.g., just weight) → entry saved successfully.
Offline & Sync
- Add entry while offline → entry saved locally, “Offline” banner shown.
- Reconnect to internet → entry syncs to server, timeline updates.
- Edit/delete entry while offline → changes sync on reconnect.
Timeline & Pagination
- Add multiple entries to exceed one page → verify pagination/infinite scroll works.
- Scroll through large timeline → confirm performance and grouping by date.
Edge Cases
- Add entry, edit it multiple times → only latest value shown, audit trail maintained internally.
- Add entry for one pet, switch to another pet → confirm measurement logs are pet-specific.
- Add entry with only notes (no measurements) → error shown, entry not saved.
Accessibility
- Navigate measurement entry form using screen reader.
- Test with dynamic font scaling and high contrast mode.
- Verify all form controls are labeled and accessible.
Multi-user (Future-proofing)
- Ensure createdBy is stored for each entry (no UI for this yet).
Data Integrity
- Confirm that audit trail is not exposed to user but is present in backend.
- Verify that deleted entries are removed from timeline but retained in audit logs.

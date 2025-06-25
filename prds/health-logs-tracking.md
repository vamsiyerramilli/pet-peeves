# Health Logs Tracking

## Objective
Enable users to upload, log, and review their pets' health records (PDF/photo) and track key health parameters (temperature) in a simple, scalable, and accessible system. The module should mirror the structure and usability of the measurement tracking module, supporting timeline visualisation, robust validation, and future extensibility.

## User Stories
- As a user, I want to upload my pet's health records as a photo or PDF, which are stored securely and retrievable by date.
- As a user, I want to quickly log my pet's temperature, with the option to do this without uploading a full health record.
- As a user, I want to view a chronological log of all health records and temperature entries for each pet, grouped by date.
- As a user, I want to edit or delete health records or temperature logs, with the system maintaining an audit trail but only showing the latest value.
- As a user, I want health logging to work offline and sync when online.
- As a user, I want the health log UI to be accessible and consistent across all entry points.

## User Journey
### Adding a Health Entry
- User taps FAB ("Add Health Entry") on Home or Logs screen.
- User chooses:
    - Upload Health Record (Photo/PDF)
        - Select file (photo or PDF).
        - Optionally add notes, set date/time (defaults to now).
        - Save – file is uploaded and appears in logs.
    - Log Temperature Only
        - Enter temperature (°C/°F), set date/time (defaults to now).
        - Optionally add notes.
        - Save – temperature entry appears in logs.

### Editing/Deleting an Entry
- User finds entry in timeline → taps to edit or delete.
- System updates entry, maintains audit trail, but only latest value shown to user.

### Viewing Health Timeline
- User navigates to Logs tab.
- User sees a timeline view of all health entries (PDF/photo or temperature), grouped by date/time.
- Each entry shows:
    - For health record: file icon/preview, date/time, notes.
    - For temperature: value, date/time, notes.

## UI/UX Specifications
### Health Entry Modal
- Fields (conditional on entry type):
    - Time & Date: Defaults to current; editable.
    - Upload: Photo or PDF (required for health record upload).
    - Temperature: Numeric, optional (required for temp-only entry).
    - Notes: Optional free text.
- Buttons: Save, Cancel.
- Validation: At least one required field (file or temperature). No negative or out-of-range temperature values.

### Timeline View
- Chronological, grouped by date.
- Each entry: time, type (PDF/photo or temp), notes.
- File entries show preview or file icon; temp entries show value.
- Scrollable, with date separators.
- Pagination/infinite scroll for large datasets.

## Discovery Points
- Home Screen FAB: "Add Health Entry."
- Logs Screen FAB: "Add Health Entry."
- (Future) Health card: "View Health Timeline."

## Accessibility
- High contrast colors, large tap targets, screen reader support, keyboard navigation, dynamic font scaling

## Technical Specifications
### Health Log Model
```dart
class HealthEntry {   
  final String id;  
  final String petId;  
  final DateTime timestamp;  
  final String? fileUrl;     // PDF or photo, optional  
  final double? temperature; // Optional, °C or °F  
  final String? notes;       // Optional  
  final String? createdBy;   // For future multi-user support  
  final DateTime createdAt;  
  final DateTime? updatedAt;  
  final List<HealthAudit>? auditTrail; // Internal only 
}
```

### Firestore Example
```json
{
  "petId": "petId",
  "timestamp": "datetime",
  "fileUrl": "https://.../record.pdf",
  "temperature": 38.5,
  "notes": "Annual checkup",
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
```

### ID Generation Pattern
- **Firestore Document ID**: Generated using `_firestore.collection('health').doc().id` in the service layer
- **Model ID Field**: Assigned from the generated document ID before saving to Firestore
- **UI/Modal**: Does not generate or include ID field for new entries; service handles ID generation
- **Loading**: Uses `HealthEntry.fromFirestore(doc)` which extracts ID from `doc.id`
- **Consistency**: Follows the same pattern as the measurements module

## Validation
- Temperature: 25–50°C (or 77–122°F) for animal safety.
- File: Must be PDF, JPG, or PNG; max size 10MB.
- At least one of file or temperature must be present.
- No negative or zero temperature values.

## State Management
- Health Slice:
    - Stores: List (by petId, sorted by timestamp).
    - Actions: AddEntry, EditEntry, DeleteEntry.
    - Efficient retrieval/grouping for timeline display.
    - Pagination for large logs.

## API Integration
- POST /entries/health (queue if offline).
- GET /entries/health?petId={id}&sort=desc (pagination).
- PATCH/DELETE /entries/health/{id}.
- Offline Mode: Local storage, sync on reconnect.
- Show banner: "Offline – data will sync later."

## Error Handling
- Validation errors: Highlight invalid fields, prevent save.
- Sync failures: Retry 3x, show "Sync failed" message with manual retry.
- No entries: Show "Add your first health record" prompt.
- Large logs: Timeline view must handle large datasets efficiently.

## Edge Cases
- User uploads only a file or only temperature: Allowed.
- Negative or out-of-range temperature: Error, prevent save.
- Edit/delete: Only latest value shown, full audit trail maintained internally.
- Multi-user: Store createdBy for future support.
- Future extensibility: Model allows for new health parameters.

## Acceptance Criteria
- Users can add/edit/delete health entries from multiple discovery points.
- Entries sync across all screens in real-time (when online).
- Offline usage supported with local storage and later sync.
- Timeline view is provisioned and paginated for large logs.
- UI matches existing app design and accessibility standards.
- Validation prevents negative, zero, or out-of-range values.
- Audit trail is maintained for all edits/deletions, but only latest value shown to user.

## Implementation Order
1. Define Data Models
    - Implement HealthEntry model (with audit trail and value range validation).
2. Build Health Entry Modal UI
    - Create modal for uploading file or logging temperature, with validation and accessibility.
3. Create Redux Slice for Health Logs
    - Set up state management for health entries (by petId, sorted by timestamp).
4. Implement API Service with Offline Queue
    - Develop endpoints and offline sync logic.
5. Integrate Health Entry Points
    - Add FABs and navigation from Home, Logs, etc.
6. Provision Timeline View
    - Implement timeline UI for health logs (grouped by date, paginated).
7. Add Edit and Delete Functionality
    - Enable editing and deletion of entries, maintaining audit trails.
8. Optimize for Performance
    - Pagination and data retrieval for large logs.
9. Testing and QA
    - Comprehensive testing (see scenarios below).
10. Accessibility Review
    - Audit and adjust for accessibility compliance.

## Testing
### Happy Path
- Add health record (photo/PDF) → appears in timeline.
- Add temperature entry → appears in timeline.
- Edit/delete entry → only latest value shown, audit trail updated.
- Add entry with notes → notes saved and displayed.

### Validation & Error Handling
- Attempt to save with all fields empty → error, not saved.
- Enter negative or out-of-range temperature → error, not saved.
- Upload unsupported file type or large file → error, not saved.
- Enter only one field (file or temperature) → entry saved.

### Offline & Sync
- Add entry while offline → saved locally, "Offline" banner shown.
- Reconnect → entry syncs to server, timeline updates.
- Edit/delete while offline → syncs on reconnect.

### Timeline & Pagination
- Add many entries → verify pagination/infinite scroll.

### Edge Cases
- Add entry, edit multiple times → only latest value shown, audit trail maintained.
- Add entry for one pet, switch to another → logs are pet-specific.

### Accessibility
- Navigate form using screen reader.
- Test with dynamic font scaling and high contrast mode.
- Verify all form controls are labeled and accessible.

## Bug Fixes and Resolutions
### ID Generation Issue (Resolved)
- **Problem**: "type 'Null' is not a subtype of type 'String'" error when saving new health entries
- **Root Cause**: New entries created in the UI modal were missing the `id` field, causing parsing errors
- **Solution**: 
  - Updated `HealthService.addHealthEntry()` to generate Firestore document ID using `_firestore.collection('health').doc().id`
  - Modified `HealthEntry.fromFirestore()` to use `doc.id` instead of expecting ID in document data
  - Updated `HealthEntry.toFirestore()` to exclude ID field (since it's the document ID)
  - Modified modal's `_createHealthEntryData()` to not include ID field for new entries
- **Pattern**: Now follows the same ID generation pattern as the measurements module
- **Status**: ✅ Resolved

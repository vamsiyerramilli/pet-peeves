import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/health_entry.dart';

class HealthService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  HealthService(this._firestore, this._storage);

  /// Load all health entries for a specific pet, ordered by timestamp descending
  Future<List<HealthEntry>> loadHealthEntries(String petId) async {
    try {
      final snapshot = await _firestore
          .collection('pets')
          .doc(petId)
          .collection('healthLogs')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final entry = HealthEntry.fromFirestore(doc);
        // Set the petId since it's not stored in the document anymore
        return entry.copyWith(petId: petId);
      }).toList();
    } catch (e) {
      throw Exception('Failed to load health entries: $e');
    }
  }

  /// Load health entries with date range filtering
  Future<List<HealthEntry>> loadHealthEntriesInDateRange(
    String petId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _firestore
          .collection('pets')
          .doc(petId)
          .collection('healthLogs')
          .orderBy('timestamp', descending: true);

      if (startDate != null) {
        query = query.where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        query = query.where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final entry = HealthEntry.fromFirestore(doc);
        return entry.copyWith(petId: petId);
      }).toList();
    } catch (e) {
      throw Exception('Failed to load health entries in date range: $e');
    }
  }

  /// Load health entries with pagination support
  Future<List<HealthEntry>> loadHealthEntriesWithPagination(
    String petId, {
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      var query = _firestore
          .collection('pets')
          .doc(petId)
          .collection('healthLogs')
          .orderBy('timestamp', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final entry = HealthEntry.fromFirestore(doc);
        return entry.copyWith(petId: petId);
      }).toList();
    } catch (e) {
      throw Exception('Failed to load health entries with pagination: $e');
    }
  }

  /// Load temperature-only entries for a pet
  Future<List<HealthEntry>> loadTemperatureEntries(String petId) async {
    try {
      final snapshot = await _firestore
          .collection('pets')
          .doc(petId)
          .collection('healthLogs')
          .where('temperature', isNotEqualTo: null)
          .orderBy('temperature')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final entry = HealthEntry.fromFirestore(doc);
        return entry.copyWith(petId: petId);
      }).toList();
    } catch (e) {
      throw Exception('Failed to load temperature entries: $e');
    }
  }

  /// Load file-based entries (health records) for a pet
  Future<List<HealthEntry>> loadFileEntries(String petId) async {
    try {
      final snapshot = await _firestore
          .collection('pets')
          .doc(petId)
          .collection('healthLogs')
          .where('fileUrl', isNotEqualTo: null)
          .orderBy('fileUrl')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final entry = HealthEntry.fromFirestore(doc);
        return entry.copyWith(petId: petId);
      }).toList();
    } catch (e) {
      throw Exception('Failed to load file entries: $e');
    }
  }

  /// Search health entries by notes content
  Future<List<HealthEntry>> searchHealthEntriesByNotes(
    String petId,
    String searchTerm,
  ) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // This is a simple contains search on the notes field
      // For more advanced search, consider using Algolia or similar service
      
      final snapshot = await _firestore
          .collection('pets')
          .doc(petId)
          .collection('healthLogs')
          .where('notes', isNotEqualTo: null)
          .orderBy('notes')
          .orderBy('timestamp', descending: true)
          .get();

      final allEntries = snapshot.docs.map((doc) {
        final entry = HealthEntry.fromFirestore(doc);
        return entry.copyWith(petId: petId);
      }).toList();

      // Filter entries that contain the search term in notes
      return allEntries.where((entry) {
        if (entry.notes == null) return false;
        return entry.notes!.toLowerCase().contains(searchTerm.toLowerCase());
      }).toList();
    } catch (e) {
      throw Exception('Failed to search health entries: $e');
    }
  }

  /// Get health entry statistics for a pet
  Future<Map<String, dynamic>> getHealthEntryStats(String petId) async {
    try {
      final snapshot = await _firestore
          .collection('pets')
          .doc(petId)
          .collection('healthLogs')
          .get();

      final entries = snapshot.docs.map((doc) {
        final entry = HealthEntry.fromFirestore(doc);
        return entry.copyWith(petId: petId);
      }).toList();

      final totalEntries = entries.length;
      final temperatureEntries = entries.where((e) => e.temperature != null).length;
      final fileEntries = entries.where((e) => e.fileUrl != null).length;
      final combinedEntries = entries.where((e) => e.temperature != null && e.fileUrl != null).length;

      // Calculate temperature statistics
      final temperatureValues = entries
          .where((e) => e.temperature != null)
          .map((e) => e.temperature!)
          .toList();
      
      double? avgTemperature;
      double? minTemperature;
      double? maxTemperature;
      
      if (temperatureValues.isNotEmpty) {
        avgTemperature = temperatureValues.reduce((a, b) => a + b) / temperatureValues.length;
        minTemperature = temperatureValues.reduce((a, b) => a < b ? a : b);
        maxTemperature = temperatureValues.reduce((a, b) => a > b ? a : b);
      }

      // Get date range
      DateTime? earliestDate;
      DateTime? latestDate;
      
      if (entries.isNotEmpty) {
        final dates = entries.map((e) => e.timestamp).toList();
        earliestDate = dates.reduce((a, b) => a.isBefore(b) ? a : b);
        latestDate = dates.reduce((a, b) => a.isAfter(b) ? a : b);
      }

      return {
        'totalEntries': totalEntries,
        'temperatureEntries': temperatureEntries,
        'fileEntries': fileEntries,
        'combinedEntries': combinedEntries,
        'avgTemperature': avgTemperature,
        'minTemperature': minTemperature,
        'maxTemperature': maxTemperature,
        'earliestDate': earliestDate,
        'latestDate': latestDate,
      };
    } catch (e) {
      throw Exception('Failed to get health entry stats: $e');
    }
  }

  /// Add a new health entry to Firestore
  /// Handles file upload if a file is provided
  Future<HealthEntry> addHealthEntry(HealthEntry entry) async {
    try {
      // Validate the entry
      _validateHealthEntry(entry);

      // Handle file upload if needed
      String? fileUrl;
      if (entry.fileUrl != null && entry.fileUrl!.startsWith('file://')) {
        // This is a local file path, need to upload it
        final file = File(entry.fileUrl!.replaceFirst('file://', ''));
        fileUrl = await _uploadHealthFile(file, entry.petId);
      } else if (entry.fileUrl != null) {
        // This is already a remote URL, use as is
        fileUrl = entry.fileUrl;
      }

      // Create document reference in the pet's healthLogs sub-collection and generate ID
      final docRef = _firestore
          .collection('pets')
          .doc(entry.petId)
          .collection('healthLogs')
          .doc();

      // Create the entry with the generated ID and updated file URL
      final newEntry = entry.copyWith(
        id: docRef.id,
        fileUrl: fileUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Create the document in Firestore
      await docRef.set(newEntry.toFirestore());

      // Return the created entry with the new ID and file URL
      return newEntry;
    } catch (e) {
      throw Exception('Failed to add health entry: $e');
    }
  }

  /// Edit an existing health entry in Firestore
  /// Focuses on updating non-file fields (temperature, notes, timestamp)
  /// Maintains audit trail of changes
  Future<HealthEntry> editHealthEntry(String entryId, HealthEntry updatedEntry) async {
    try {
      // Validate the entry ID
      if (entryId.isEmpty) {
        throw Exception('Entry ID is required');
      }

      // Validate the updated entry (excluding file validation for edits)
      _validateHealthEntryForEdit(updatedEntry);

      // Get the existing entry to preserve file URL and other immutable fields
      final existingDoc = await _firestore
          .collection('pets')
          .doc(updatedEntry.petId)
          .collection('healthLogs')
          .doc(entryId)
          .get();
      
      if (!existingDoc.exists) {
        throw Exception('Health entry not found');
      }

      final existingData = existingDoc.data()!;
      final existingEntry = HealthEntry.fromJson(existingData);

      // Create audit record for the changes
      final auditRecord = HealthAudit(
        updatedAt: DateTime.now(),
        updatedBy: updatedEntry.createdBy ?? 'unknown',
        oldValues: {
          'timestamp': existingEntry.timestamp.toIso8601String(),
          'temperature': existingEntry.temperature,
          'notes': existingEntry.notes,
        },
      );

      // Prepare update data - only update allowed fields
      final updateData = <String, dynamic>{
        'timestamp': updatedEntry.timestamp.toIso8601String(),
        'temperature': updatedEntry.temperature,
        'notes': updatedEntry.notes,
        'updatedAt': DateTime.now().toIso8601String(),
        'auditTrail': FieldValue.arrayUnion([auditRecord.toFirestore()]),
      };

      // Remove null values to keep the document clean
      updateData.removeWhere((key, value) => value == null);

      // Update the document in Firestore
      await _firestore
          .collection('pets')
          .doc(updatedEntry.petId)
          .collection('healthLogs')
          .doc(entryId)
          .update(updateData);

      // Return the updated entry by combining existing and updated data
      final finalData = {
        ...existingData,
        ...updateData,
        'id': entryId, // Ensure ID is preserved
      };

      final resultEntry = HealthEntry.fromJson(finalData);
      // Set the petId since it's not stored in the document anymore
      return resultEntry.copyWith(petId: updatedEntry.petId);
    } catch (e) {
      throw Exception('Failed to edit health entry: $e');
    }
  }

  /// Delete a health entry and its associated file
  /// Two-step process: delete file from Storage, then delete document from Firestore
  /// Maintains audit trail before deletion
  Future<void> deleteHealthEntry(String entryId, String petId) async {
    try {
      // Validate the entry ID
      if (entryId.isEmpty) {
        throw Exception('Entry ID is required');
      }

      // Step 1: Get the entry to check for file URL and create audit record
      final doc = await _firestore
          .collection('pets')
          .doc(petId)
          .collection('healthLogs')
          .doc(entryId)
          .get();
      
      if (!doc.exists) {
        throw Exception('Health entry not found');
      }

      final entryData = doc.data()!;
      final existingEntry = HealthEntry.fromJson(entryData);
      final fileUrl = entryData['fileUrl'] as String?;

      // Create audit record for deletion
      final auditRecord = HealthAudit(
        updatedAt: DateTime.now(),
        updatedBy: existingEntry.createdBy ?? 'unknown',
        oldValues: {
          'id': existingEntry.id,
          'petId': existingEntry.petId,
          'timestamp': existingEntry.timestamp.toIso8601String(),
          'fileUrl': existingEntry.fileUrl,
          'temperature': existingEntry.temperature,
          'notes': existingEntry.notes,
          'createdBy': existingEntry.createdBy,
          'createdAt': existingEntry.createdAt.toIso8601String(),
          'updatedAt': existingEntry.updatedAt?.toIso8601String(),
          'action': 'deleted',
        },
      );

      // Step 2: Add audit record before deletion
      await _firestore
          .collection('pets')
          .doc(petId)
          .collection('healthLogs')
          .doc(entryId)
          .update({
        'auditTrail': FieldValue.arrayUnion([auditRecord.toFirestore()]),
      });

      // Step 3: Delete file from Firebase Storage if it exists
      if (fileUrl != null && fileUrl.isNotEmpty) {
        await _deleteHealthFile(fileUrl);
      }

      // Step 4: Delete the document from Firestore
      await _firestore
          .collection('pets')
          .doc(petId)
          .collection('healthLogs')
          .doc(entryId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete health entry: $e');
    }
  }

  /// Delete a health file from Firebase Storage
  Future<void> _deleteHealthFile(String fileUrl) async {
    try {
      // Extract the file path from the Firebase Storage URL
      final filePath = _extractFilePathFromUrl(fileUrl);
      if (filePath != null) {
        final storageRef = _storage.ref().child(filePath);
        await storageRef.delete();
      }
    } catch (e) {
      // Log the error but don't fail the entire deletion process
      // The file might already be deleted or the URL might be invalid
      print('Warning: Failed to delete file from storage: $e');
    }
  }

  /// Extract file path from Firebase Storage URL
  String? _extractFilePathFromUrl(String fileUrl) {
    try {
      final uri = Uri.parse(fileUrl);
      
      // Firebase Storage URLs typically have this pattern:
      // https://firebasestorage.googleapis.com/v0/b/{bucket}/o/{path}?alt=media&token={token}
      
      if (uri.host.contains('firebasestorage.googleapis.com')) {
        // Extract the path from the 'o' parameter
        final pathSegments = uri.pathSegments;
        if (pathSegments.length >= 3 && pathSegments[0] == 'v0' && pathSegments[2] == 'o') {
          // The path is URL-encoded, so we need to decode it
          final encodedPath = pathSegments[3];
          return Uri.decodeComponent(encodedPath);
        }
      }
      
      return null;
    } catch (e) {
      print('Warning: Failed to extract file path from URL: $e');
      return null;
    }
  }

  /// Validate health entry for editing (less strict than creation)
  void _validateHealthEntryForEdit(HealthEntry entry) {
    // For edits, we allow updating temperature and notes even if file exists
    // The file URL will be preserved from the existing entry

    // Validate temperature if provided
    if (entry.temperature != null) {
      if (entry.temperature! <= 0) {
        throw Exception('Temperature must be greater than 0°C');
      }
      if (entry.temperature! < 25 || entry.temperature! > 50) {
        throw Exception('Temperature must be between 25°C and 50°C');
      }
    }

    // Validate required fields
    if (entry.petId.isEmpty) {
      throw Exception('Pet ID is required');
    }
  }

  /// Validate health entry before saving
  void _validateHealthEntry(HealthEntry entry) {
    // Check that at least one of file or temperature is provided
    if (entry.fileUrl == null && entry.temperature == null) {
      throw Exception('At least one of file or temperature must be provided');
    }

    // Validate temperature if provided
    if (entry.temperature != null) {
      if (entry.temperature! <= 0) {
        throw Exception('Temperature must be greater than 0°C');
      }
      if (entry.temperature! < 25 || entry.temperature! > 50) {
        throw Exception('Temperature must be between 25°C and 50°C');
      }
    }

    // Validate file URL if provided
    if (entry.fileUrl != null) {
      if (entry.fileUrl!.startsWith('file://')) {
        // Local file - will be validated during upload
        final filePath = entry.fileUrl!.replaceFirst('file://', '');
        final file = File(filePath);
        if (!file.existsSync()) {
          throw Exception('Local file does not exist');
        }
      } else if (!entry.fileUrl!.startsWith('http')) {
        throw Exception('Invalid file URL format');
      }
    }

    // Validate required fields
    if (entry.petId.isEmpty) {
      throw Exception('Pet ID is required');
    }
  }

  /// Upload a health record file to Firebase Storage
  /// Returns the downloadable URL for the uploaded file
  Future<String> _uploadHealthFile(File file, String petId) async {
    try {
      // Validate file
      await _validateHealthFile(file);

      // Generate unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final originalName = file.path.split('/').last;
      final extension = originalName.split('.').last.toLowerCase();
      final fileName = 'health_record_${petId}_$timestamp.$extension';

      // Create storage reference with structured path
      final storageRef = _storage
          .ref()
          .child('health_records')
          .child(petId)
          .child(fileName);

      // Upload file
      final uploadTask = storageRef.putFile(
        file,
        SettableMetadata(
          contentType: _getContentType(extension),
          customMetadata: {
            'originalName': originalName,
            'petId': petId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Wait for upload to complete
      final snapshot = await uploadTask;
      
      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload health file: $e');
    }
  }

  /// Validate health file before upload
  Future<void> _validateHealthFile(File file) async {
    // Check if file exists
    if (!await file.exists()) {
      throw Exception('File does not exist');
    }

    // Check file size (10MB limit as per PRD)
    final fileSize = await file.length();
    const maxSize = 10 * 1024 * 1024; // 10MB in bytes
    if (fileSize > maxSize) {
      throw Exception('File size exceeds 10MB limit');
    }

    // Check file extension
    final fileName = file.path.split('/').last.toLowerCase();
    final allowedExtensions = ['jpg', 'jpeg', 'png', 'pdf'];
    final extension = fileName.split('.').last;
    
    if (!allowedExtensions.contains(extension)) {
      throw Exception('File type not supported. Allowed: JPG, PNG, PDF');
    }
  }

  /// Get content type based on file extension
  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }
} 
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pet_model.dart';
import '../models/health_log_model.dart';
import '../services/pet_onboarding_service.dart';
import '../../core/theme/app_theme.dart';
import 'steps/basic_info_step.dart';
import 'steps/measurements_step.dart';
import 'steps/health_info_step.dart';
import 'steps/review_step.dart';
import 'home_screen.dart';
import 'pet_success_screen.dart';

enum OnboardingStep {
  basicInfo,
  measurements,
  healthInfo,
  review,
}

class PetOnboardingScreen extends StatefulWidget {
  final String userId;

  const PetOnboardingScreen({
    super.key,
    required this.userId,
  });

  @override
  State<PetOnboardingScreen> createState() => _PetOnboardingScreenState();
}

class _PetOnboardingScreenState extends State<PetOnboardingScreen> {
  final _onboardingService = PetOnboardingService();
  final _formKey = GlobalKey<FormState>();
  
  OnboardingStep _currentStep = OnboardingStep.basicInfo;
  bool _isLoading = false;
  String? _errorMessage;

  // Form data
  String _name = '';
  Species _species = Species.dog;
  String? _otherSpecies;
  Gender _gender = Gender.male;
  DateTime? _dateOfBirth;
  DateTime? _adoptionDate;
  File? _profilePhoto;

  double? _weight;
  double? _length;
  double? _height;
  String? _measurementNotes;

  VaccinationStatus? _vaccinationStatus;
  String? _healthNotes;

  // Progress indicator
  double get _progress {
    switch (_currentStep) {
      case OnboardingStep.basicInfo:
        return 0.25;
      case OnboardingStep.measurements:
        return 0.5;
      case OnboardingStep.healthInfo:
        return 0.75;
      case OnboardingStep.review:
        return 1.0;
    }
  }

  // Step titles
  String get _stepTitle {
    switch (_currentStep) {
      case OnboardingStep.basicInfo:
        return 'Basic Information';
      case OnboardingStep.measurements:
        return 'Measurements';
      case OnboardingStep.healthInfo:
        return 'Health Information';
      case OnboardingStep.review:
        return 'Review & Confirm';
    }
  }

  // Navigation methods
  void _nextStep() {
    if (_currentStep == OnboardingStep.review) {
      _submitOnboarding();
    } else {
      setState(() {
        _currentStep = OnboardingStep.values[_currentStep.index + 1];
      });
    }
  }

  void _previousStep() {
    // Only allow going back between steps, not exiting onboarding
    if (_currentStep != OnboardingStep.basicInfo) {
      setState(() {
        _currentStep = OnboardingStep.values[_currentStep.index - 1];
      });
    }
  }

  // Form validation
  bool _validateCurrentStep() {
    switch (_currentStep) {
      case OnboardingStep.basicInfo:
        return _name.isNotEmpty && 
               (_species != Species.other || 
                (_species == Species.other && _otherSpecies != null && _otherSpecies!.isNotEmpty));
      case OnboardingStep.measurements:
        return true; // All measurements are optional
      case OnboardingStep.healthInfo:
        return true; // All fields are optional
      case OnboardingStep.review:
        return true; // All validation done in previous steps
    }
  }

  // Submit onboarding
  Future<void> _submitOnboarding() async {
    if (!_validateCurrentStep()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Create pet
      final pet = await _onboardingService.createPet(
        userId: widget.userId,
        name: _name,
        species: _species,
        otherSpecies: _otherSpecies,
        gender: _gender,
        dateOfBirth: _dateOfBirth,
        adoptionDate: _adoptionDate,
        profilePhoto: _profilePhoto,
      );

      // Add measurements if provided
      if (_weight != null || _length != null || _height != null) {
        await _onboardingService.addInitialMeasurements(
          userId: widget.userId,
          petId: pet.id,
          weight: _weight,
          length: _length,
          height: _height,
          notes: _measurementNotes,
        );
      }

      // Add health log if provided
      if (_vaccinationStatus != null) {
        await _onboardingService.addInitialHealthLog(
          userId: widget.userId,
          petId: pet.id,
          vaccinationStatus: _vaccinationStatus,
          notes: _healthNotes,
        );
      }

      // Navigate to success screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PetSuccessScreen(
              userId: widget.userId,
              petName: _name,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to create pet profile. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Build step content
  Widget _buildStepContent() {
    switch (_currentStep) {
      case OnboardingStep.basicInfo:
        return BasicInfoStep(
          onNameChanged: (value) => setState(() => _name = value),
          onSpeciesChanged: (value) => setState(() => _species = value ?? Species.dog),
          onOtherSpeciesChanged: (value) => setState(() => _otherSpecies = value),
          onGenderChanged: (value) => setState(() => _gender = value ?? Gender.male),
          onDateOfBirthChanged: (value) => setState(() => _dateOfBirth = value),
          onAdoptionDateChanged: (value) => setState(() => _adoptionDate = value),
          onProfilePhotoChanged: (value) => setState(() => _profilePhoto = value),
          initialName: _name,
          initialSpecies: _species,
          initialOtherSpecies: _otherSpecies,
          initialGender: _gender,
          initialDateOfBirth: _dateOfBirth,
          initialAdoptionDate: _adoptionDate,
          initialProfilePhoto: _profilePhoto,
        );

      case OnboardingStep.measurements:
        return MeasurementsStep(
          initialWeight: _weight,
          initialLength: _length,
          initialHeight: _height,
          onWeightChanged: (value) => setState(() => _weight = value),
          onLengthChanged: (value) => setState(() => _length = value),
          onHeightChanged: (value) => setState(() => _height = value),
          onSkip: () => _nextStep(),
        );

      case OnboardingStep.healthInfo:
        return HealthInfoStep(
          initialVaccinationStatus: _vaccinationStatus,
          initialNotes: _healthNotes,
          onVaccinationStatusChanged: (value) => setState(() => _vaccinationStatus = value),
          onNotesChanged: (value) => setState(() => _healthNotes = value),
          onSkip: () => _nextStep(),
        );

      case OnboardingStep.review:
        return ReviewStep(
          name: _name,
          species: _species,
          otherSpecies: _otherSpecies,
          gender: _gender,
          dateOfBirth: _dateOfBirth,
          adoptionDate: _adoptionDate,
          profilePhoto: _profilePhoto,
          weight: _weight,
          length: _length,
          height: _height,
          measurementNotes: _measurementNotes,
          vaccinationStatus: _vaccinationStatus,
          healthNotes: _healthNotes,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_stepTitle),
        leading: _currentStep == OnboardingStep.basicInfo 
          ? null // No back button on first step
          : IconButton(
              icon: const Icon(CupertinoIcons.back),
              onPressed: _isLoading ? null : _previousStep,
            ),
        automaticallyImplyLeading: _currentStep != OnboardingStep.basicInfo,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: _progress,
                backgroundColor: AppTheme.colors.background,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.colors.primary),
              ),
              
              // Main content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: _buildStepContent(),
                  ),
                ),
              ),
            ],
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),

          // Error message
          if (_errorMessage != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.colors.error,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Only show back button if not on first step
              if (_currentStep != OnboardingStep.basicInfo) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _previousStep,
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: FilledButton(
                  onPressed: _isLoading || !_validateCurrentStep()
                      ? null
                      : _nextStep,
                  child: Text(
                    _currentStep == OnboardingStep.review ? 'Create Pet' : 'Next',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
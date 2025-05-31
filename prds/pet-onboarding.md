# Objective

Enable users to create a pet and add details of their pets in the platform

# User stories

1. As a new user (or user without pets), I want to be able to quickly add the details of my pet on the platform
2. As an existing user (or user with pets), I want to be able to add a new pet to my profile
3. As an existing user (or user with pets), I want to be able to edit the details of my pet
4. As a user, I want to be able to add a photograph of my loved one(s) for easy recognition

# User journey

## First pet

1. Add the basic details of the pet (non-skippable)
    1. Name
    2. Profile Photo
        1. If null, fill with generic asset of the species; other to be represented by first letter of the name
    3. Species (Cat, Dog, Bird, Fish, Other: open text)
    4. Gender (Male, Female, Prefer not to say, Unsure)
    5. DoB (date; nullable)
    6. Age (in years and months): auto-calculate if DoB is added as Current Date - DOB, show in years & months (7 years & 2 months)
    7. Date of Adoption (date; nullable)
2. User clicks Next to go to the next step 
    1. Save state of the first set of inputs
    2. Save them to firebase to the Pets DB as well
3. Add the first measurement details of the pet (can skip)
    1. Weight (in Kgs)
    2. Length (in cm)
    3. Height (in cm)
4. User clicks Next to go to the next step 
    1. Save state of the second set of inputs; if skipped, save all the data as null
    2. Save them to firebase to the Pets DB as well
5. Add the first health details of the pet (can skip)
    1. Vaccination status (not vaccinated, partially vaccinated, fully vaccinated)
6. User clicks Next to go to the next step 
    1. Save state of the third set of inputs; if skipped, save all the data as null
    2. Save them to firebase to the Pets DB as well
7. Summary of all the details filled in a single view, with a “Save” option
8. On successful completion:
    1. Save pet details to Firebase storage
    2. Show an option to take the user to the home screen (primary CTA)
    3. Show an option to add another pet (secondary CTA)
9. On failure:
    1. Reload the pet onboarding screen from the last unsaved state

## Second and more pets

1. Follow a similar flow to First pet addition

# UI/UX elements

![image.png](attachment:2e1848a2-f240-42af-9b37-dcd76d846092:image.png)

## Visual Elements

1. Show the breadcrumbs of the different steps in the onboarding journey on the left side
2. Have each step of the onboarding journey go vertically, with each section collapsing into a vertical tab once completed
3. Have navigation options to go back from any step, so the user can go back to edit previously filled information
4. Friendly, rounded off buttons
5. For profile photo, if no photo is provided, display a generic image based on species. If species is also not provided, show the first letter of the pet’s name as a placeholder

## Accessibility

1. High contrast text and buttons
2. Use subtle borders for UI elements wherever the contrast is not much
3. Support screen readers

# Technical specifications

- **Platform**: Flutter
- **Database:** Pets stored in Firebase Firestore under each user’s document.
- **Image Storage:** Pet photos stored in Firebase Storage, with URL saved in Firestore.
- **State Management:** Redux
- **Validation:** Required fields, image size/type, etc.

# Error handling

1. Network failure while saving data
    1. Ask user to retry, in case of mandatory details
    2. Inform user of ability to edit it later (needs to be provisioned, will be detailed later) and take to the next step
    3. User friendly error messaging 
2. Invalid input (e.g., future date for DoB)
    1. Warn the user of error and allow them to input the data again
3. Image upload failure
    1. Inform user of the issue and allow them to retry once
    2. If failed more than 2 times, inform the user that this can be added later (needs to be provisioned, will be detailed later)
4. Validation errors (e.g., missing name/species)
    1. Inform user of the issue and allow them to retry until the data is valid and required data is present
    2. User friendly error messaging 

# Edge cases

- User tries to add a pet with a duplicate name
    - Warn the user about the issue, but allow them to continue after the warning
- User skips optional steps, then tries to edit later
    - This should be allowed and is the desired functionality. This functionality will be discussed in a later document, but should be catered to
    - If they go ahead in the onboarding journey without filling an optional detail, and then navigate back, then they should be able to add the details again immediately
- User uploads a non-image file as a photo
    - Throw an error and ask the user to check the file being uploaded; also limit uploads to 5 MB
- User navigates away mid-flow (auto-save or prompt)
    - At each save state (when next is clicked), auto-save and inform the user
    - In the middle of a save state, prompt the user that the data will be lost and they’ll have to refill it

# Acceptance criteria

- User can add a pet with all mandatory fields and optional fields as available
- User can skip optional steps and complete onboarding
- All data is correctly saved to Firebase (both Firestore and Storage)
- User can go back and edit any step before final save
- User receives clear feedback on success or failure

# Data model

```json
#scope: onboarding

When a new pet is onboarded:

- A pet document is created under `users/{userId}/pets/{petId}` with fields:
    - name: string (required)
    - profilePhotoUrl: string (optional)
    - species: string (required)
    - gender: enum (required) ("male", "female", "prefer not to say", "unsure")
    - dob: date|null (required)
    - age: object (auto-generated as {current date - dob}, show as Months & Years - e.g., 7 years & 2 months) 
    - adoptionDate: date|null (optional)
    - createdAt: timestamp (auto-generated)
    - updatedAt: timestamp (auto-generated)
    - ... (other static fields as needed)

- If the user provides initial measurements (all optional, can skip), a document is created in the `measurements` subcollection:
    - timestamp: datetime (when entered)
    - weight: number|null (in kg)
    - length: number|null (in cm)
    - height: number|null (in cm)
    - notes: string|null

- If the user provides initial health details (all optional, can skip), a document is created in the `health_logs` subcollection:
    - timestamp: datetime (when entered)
    - type: enum ("vaccination")
    - status: enum ("not vaccinated", "partially vaccinated", "fully vaccinated")
    - notes: string|null

> _Note: If these steps are skipped, the subcollections will remain empty until the user adds entries later. This structure supports future tracking and analytics as more data is added over time. No document will be created in such cases_
> _Note: Age is not stored, but calculated dynamically
```

# Implementation order

1. Design onboarding flow screens (steps, navigation, breadcrumbs)
2. Implement form validation for each step
3. Integrate image upload and preview
4. Connect to Firebase for data and image storage
5. Implement state management (Redux)
6. Add error handling and edge case management
7. Test all flows and edge cases

# Testing

1. Happy case
    1. Add pet with all fields filled
    2. Add pet skipping optional steps
    3. Add multiple pets in succession
2. Edge cases:
    1. Add pet with missing/invalid data (e.g., no name)
    2. Simulate network failures
    3. Add two pets with the same name
    4. Go back and change details during the onboarding process
    5. Upload non-image as a photo
    6. Navigate away from onboarding mid-flow
    7. Test editing pet details after onboarding is complete, including adding measurements and health logs later

# Future proofing

1. Currently, a single image will be allowed for each pet, with the option to change the profile picture. In a later phase, this could be updated to have multiple images for each pet - the handling can be discussed later
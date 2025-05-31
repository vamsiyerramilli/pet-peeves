Allow users to explore the entire app and use all the different features in the app with the fewest steps required.

# User Stories

1. As a user, I want to easily navigate between different sections of the app without confusion.
2. As a user, I want quick access to key features like Home, Logs, Pet Info, and Profile.
3. As a user, I want the navigation to be intuitive and consistent across all screens.
4. As a user, I want to be able to switch between multiple pets easily.
5. As a user, I want the app layout to be clean, responsive, and accessible.

# User Journey

## App Launch and Navigation

1. User lands on the Home screen after login or onboarding.
2. User can use the bottom navigation bar to switch between Home, Logs, Pet Info, and Profile.
3. User can use the top bar to switch between pets if multiple pets are added.
4. User can access settings or additional options from the Profile section.
5. Navigation elements are persistent and visible on all main screens.

# UI/UX Elements

## Visual Elements

1. **Bottom Navigation Bar**
    - Contains icons and labels for Home, Logs, Pet Info.
    - Clearly highlights the active tab.
    - Uses friendly, rounded buttons and consistent colors.
2. **Top Bar**
    - Left:
        - Display the pet’s profile picture (DP) alongside the pet’s name.
        - The pet’s name should be in a bold and large font, ensuring it is clearly visible and prominent next to the DP.
        - When multiple pets exist, the pet name and DP together should act as a simple dropdown for easy switching
    - Right:
        - User DP, which is linked to the User Profile section and App settings
        - App settings will be clubbed under the profile section itself for this phase
3. **Floating Action Button (FAB)**
    - Contextual FAB on relevant screens (e.g., add new log entry on Logs screen)
        - Home: Add a new entry
        - Logs: Add a new entry
        - Pet Info: Edit pet details
    - Icons
        - Add entry: Plus
        - Edit entry: Edit / pencil
    - Future provisioning: implement the visuals now but leave the functionality grayed out
        - In add entry mode, clicking on it should open a menu of 3 types of logs: food intake, measurements, and health
        - In edit mode, clicking on it should allow the user to edit the pet’s info
4. Consistent spacing, typography, and colour palette matching the app theme

## Accessibility

1. High contrast colors for text and icons.
2. Large tap targets for navigation buttons.
3. Support for screen readers with proper labels.
4. Keyboard navigation support where applicable.
5. All tap areas should be a minimum of 48x48 dp
6. Dynamic font scaling

# Technical Specifications

- **Platform:** Flutter
- **State Management:** Redux (provision for preserving tab state - scroll position, partial entry of forms)
- **Navigation:** Use go_router package
- **Persistent navigation bars and state preservation across tabs.**

## State management

State management within the app will have 2 slices to begin with, but needs provisioning for a 3rd

1. Navigation slice
    1. What it stores:
        1. Which screen/tab is currently active (Home, Logs, Profile, etc.)
    2. What it does:
        1. Lets you switch screens or tabs
2. Pet slice
    1. What it stores:
        1. List of all pets
        2. Which pet is currently active
    2. What it does:
        1. Lets you switch pets
3. Tab-wise slice (future - just lay the groundwork for now)
    1. What it stores:
        1. List of all tabs
        2. scroll position within each tab
        3. Partially edited entries within each tab
    2. What it does:
        1. Resume activity on a different tab easily (either scroll or edit)

# Error Handling

1. Handle navigation errors gracefully (e.g., invalid routes).
    1. Allow user to retry 3 times manually before asking them to restart the app
2. Show user-friendly messages if a screen fails to load.

# Edge Cases

- User has no pets added: Pet switcher dropdown is hidden or disabled
    - Should load the pet onboarding journey instead of the home screen in such cases
    - This should be a modal journey
    - Archived pets count as pets (i.e., if a user only has archived pets, they would not fall under this segment)
- User tries to switch to a pet that has been deleted: Show error and refresh pet list
- User rapidly switches tabs: Ensure state is preserved and no crashes occur
- User has a very large number of pets
    - Show up to 4 pets in the drop down and have scroll within the drop down to show the remaining pets
    - Make the UX easy so users know that they can scroll

# Acceptance Criteria

- User can navigate to all main sections using bottom navigation
- Pet switcher works correctly and updates content accordingly
- Navigation elements are visible and consistent across screens
- App layout is responsive and accessible
- No crashes or errors during navigation

# Data Model

- Navigation state is managed in Redux store
- Current active tab and selected pet ID are stored and updated

# Implementation Order

1. Design navigation bar and top bar UI components
2. Implement bottom navigation with tab switching
3. Implement pet switcher dropdown in the top bar
4. Integrate navigation state with Redux
5. Add FAB with contextual actions
6. Implement accessibility features
7. Test navigation flows and edge cases

# Testing

Device: iPhone 13 - iPhone 16
OS: iOS (Android will be coming next)

## Happy Case

1. Navigate between all tabs
2. Switch pets and verify content updates
3. Use FAB to add new entries where applicable

## Edge Cases

1. No pets added: verify pet switcher behaviour
2. Switch to deleted pet: verify error handling
3. Rapid tab switching: verify stability and state preservation
# Objective

Enable new users to signup and existing users to login securely to the platform using their Google sign-in (support Apple login, Email-based login and Phone number-based login in the future)

# User stories

1. As a new user, I want to be able to signup quickly to the platform
2. As a new user, I want to get a quick glance of some things that I can do in the app
3. As an existing user, I want to be able to login reliably every time
4. As a user, I want to see some welcoming and warm visuals when I am trying to get into the app

# User journey

## First Launch

1. App splash screen (with a branded loader in the future)
2. Landing on the signup/login screen
3. Click on Google sign-in (primary CTA)
4. Provision for Apple and email-based in the future

## Signup

1. User taps on “Sign in with Google” (or other options later)
2. User completes the OAuth flow
3. On successful completion:
    1. Fetch user’s email ID, name and profile picture
    2. Pop up asking the user to confirm the details
    3. Continue to User Onboarding journey
4. On failure: show a user-friendly error message and reload the login screen

## Login

1. User taps on “Sign in with Google” (or other options later)
2. User completes the OAuth flow
3. On successful completion:
    1. User completed “User Onboarding” journey
        1. If the user has Pets, land on the Home screen
        2. If the user has no Pets, continue to the Pet Onboarding jourey
    2. User has not completed “User Onboarding” journey
        1. Continue to the User Onboarding journey
4. On failure: show a user-friendly error message and reload the login screen

# UI/UX elements

![image.png](attachment:2e1848a2-f240-42af-9b37-dcd76d846092:image.png)

## Visual Elements

1. Pet themed header image (cats and dogs for now)
2. App logo and Name (”Pet Peeves”, with a paw (in Charcoal Black *#36454F*) as the logo
3. Friendly, rounded off buttons
4. Swipeable list of 3-4 key features in a carousel in the top 1/2 of the screen

## Accessibility

1. High contrast text and buttons
2. Use subtle borders for UI elements wherever the contrast is not much
3. Support screen readers

# Technical specifications

**Platform**: Flutter

**Auth**:

- Firebase authentication with Google Sign-In
- Store user info from auth in a User DB on firebase (UID, user’s email ID, name and profile picture)

**Error handling**

- Handle errors arising due to network failures, user cancels, Google errors
- Show user-friendly error messages giving context of the issue and some potential solutions

**Security**

- Ensure security of all sensitive tokens
- Do not log any sensitive information

# Edge cases

1. Network connection failed
    1. Show an error message informing the user about the issue and to retry
2. User cancels the login
    1. Inform the user of the cancelled login; allow the user to login when they try again the next time
3. User denies permissions
    1. If non-mandatory permissions, continue with login. If mandatory, block sign in and inform the user
4. Duplicate accounts
    1. Inform user of the existing account & prompt user to sign in using the right details
5. Name, Profile Pic missing from Google profile
    1. Name: Load the edit details screen, with name as blank and do not allow user to move ahead without a name
    2. Profile pic: Use a generic profile image of first letter of the name (V for Vamsi)
6. (Future) User tries to sign up with a Google ID which is already registered
    1. Login automatically using the existing ID; in case of an error, prompt user to sign in using the right details
7. (Future) User tries to link their email ID to a mobile number-based profile & email ID already exists
    1. Prompt user if they want to merge accounts; if not, ask them to enter a different email address

# Acceptance criteria

- User can sign up using Google sign-in within 10 seconds
- On first login, the user details are all fetched and editable & user gets redirected to the right journey after the details are captured
- On repeat login, user is auto-signed-in and put in the right journey based on the user and pet profile status
- All error states are handled well

# Data model

```json
{
	"uid": "string",
	"name": "string",
	"email": "string",
	"profilePicURL": "string",
	"onboardingComplete": bool,
	"pets": []
}
```

# Implementation order

1. Set up Firebase project and enable Google sign-in
    1. Create a firebase project & enable Google sign-in
    2. Configure the app to work with this project
2. Implement splash and login screens with the mentioned UI elements
    1. Splash screen with loader functionality
    2. Login screen with a header image featuring 2 cats, a carousel of text about the app features and the google sign-in button
3. Integrate Firebase OAuth and handle OAuth flows
    1. Connect Firebase auth with Google sign-in
4. Store user info in Firebase
    1. Fetch user details from Google and store in firebase
    2. Display the details to the user, and ask them to confirm or edit
    3. In case of any changes, save the updated details to Firebase
5. Implement error handling for all cases
    1. Have user-friendly messages on all screens and for all edge cases
6. Redirect users into the right journeys post login depending on the onboarding status
    1. Determine the user onboarding status and pet onboarding status
    2. Select the journey per the combination of these statuses

# Testing

1. Happy case
    1. Google log in, no changes
    2. User edits details after login (name, picture)
    3. User drops off during the onboarding journey and logs back in
2. Edge cases:
    1. Sign up with missing name, missing profile picture
    2. Cancel login during the process & try logging in again
    3. Simulate network failure during OAuth
    4. Attempt logging in with an already registered email ID
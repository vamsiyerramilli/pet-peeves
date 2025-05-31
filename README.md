# Objective

Enable user to track details regarding their pets over time

# Why?

1. Pet parents want to be informed about changes to their pets, so they can take informed decisions
2. Pets cannot communicate their issues with humans, and hence, it becomes important to track the trends in their behaviour to notice any changes in their health
3. Track how your pets are growing over time
4. Understand the impact of any changes in their routine - diet, sleep, new patterns, etc. - on their overall wellbeing and long term health

# Initial thoughts

[Scope definition](https://www.notion.so/Scope-definition-204e040ad29980b394efd6dc7115678a?pvs=21)

[Planning](https://www.notion.so/Planning-204e040ad299804a948ec53226393dca?pvs=21)

# How?

## Agent stack

Phase 1 will be built entirely using AI code editors - Cursor, primarily. The prototyping will be entirely done first in Cursor and then designs will be refined in Figma

I will act as the PM, QA and the overall reviewer and approver of everything that is written and will give the final acceptance.

## Tech stack

**Frontend**: Flutter, as the app will have to work across iOS (first), Android (next), and Web (in the future)

**State management**: Redux

**Database**: Firebase for data and images in Phase 1; can plan for migration later, if required

**Auth**: Firebase Google Signin

## UI/UX elements

Use the below colour scheme for all the different UI elements. Whenever in question, just ask for a confirmation instead of introducing any other colours.

![image.png](attachment:5163260c-35c1-4563-93f5-143b72cc4599:image.png)

## User Journey

1. User downloads the app
2. User opens the app for the first time
3. [Signup and Login Journey](https://www.notion.so/Signup-and-Login-Journey-204e040ad299806d8b4dd7f72f7f5d79?pvs=21) 
4. User onboarding & Profile
5. Pet onboarding & Profile
6. App landing screen
    1. Bottom navigation
    2. Top navigation
    3. Home page navigation
    4. Floating action button
7. Food Tracking
    1. Adding a new entry
    2. Editing an entry
    3. Deleting an entry
    4. Page layout and actions
8. Measurement Tracking
    1. Adding a new entry
    2. Editing an entry
    3. Deleting an entry
    4. Page layout and actions
9. Health Tracking
    1. Adding a new entry
    2. Editing an entry
    3. Deleting an entry
    4. Page layout and actions
10. Home page
11. Timeline views
12. Trends and Charts

# PRDs

[Signup and Login Journey](https://www.notion.so/Signup-and-Login-Journey-204e040ad299806d8b4dd7f72f7f5d79?pvs=21)

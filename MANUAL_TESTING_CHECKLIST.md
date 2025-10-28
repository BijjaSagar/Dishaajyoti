# Manual Layout Testing Checklist

## Purpose
This checklist provides step-by-step instructions for manually verifying layout integrity across all supported languages.

## Prerequisites
- App installed on test device or emulator
- Access to Settings > Language selection
- Test data ready for form inputs

## Testing Instructions

### How to Test Each Screen
1. Navigate to Settings
2. Change language to the target language
3. Navigate to the screen being tested
4. Check all items in the checklist
5. Take screenshots if issues found
6. Repeat for all 6 languages

## Supported Languages to Test
- [ ] English (en)
- [ ] Hindi (hi)
- [ ] Marathi (mr)
- [ ] Tamil (ta)
- [ ] Telugu (te)
- [ ] Kannada (kn)

---

## Screen 1: Forgot Password Screen

**Navigation:** Login Screen > "Forgot Password?" link

### Checklist
- [ ] Title "Forgot Password?" displays without truncation
- [ ] Subtitle text wraps correctly (not cut off)
- [ ] Email field label is fully visible
- [ ] Email hint text is visible
- [ ] "Send Reset Link" button text fits within button
- [ ] Success message displays correctly
- [ ] "Back to Login" link is fully visible
- [ ] No text overlaps with other elements

### Test Cases
1. Enter email and submit
2. Verify success message with email placeholder
3. Check error message display

---

## Screen 2: Profile Setup Screen

**Navigation:** After signup > Profile Setup

### Checklist
- [ ] "Complete Your Profile" title fits
- [ ] Step indicator "Step X of Y" displays correctly
- [ ] Section headers fit (Birth Details, Career Info, etc.)
- [ ] All form field labels are fully visible
- [ ] Hint text in fields is readable
- [ ] Privacy note at bottom wraps correctly
- [ ] Back and Next buttons fit side-by-side
- [ ] Complete button fits on final step

### Test Cases
1. Navigate through all 3 steps
2. Verify all labels in each step
3. Check button layout on narrow screens

---

## Screen 3: Language Selection Screen

**Navigation:** Onboarding > Language Selection OR Settings > Language

### Checklist
- [ ] "Choose Your Language" title fits
- [ ] Subtitle text wraps correctly
- [ ] All 6 language names display correctly
- [ ] Selected language indicator is visible
- [ ] Continue button text fits
- [ ] Language change confirmation message displays

### Test Cases
1. Select each language
2. Verify immediate UI update
3. Check confirmation toast/snackbar

---

## Screen 4: Kundali Detail Screen

**Navigation:** Dashboard > My Kundalis > Select a Kundali

### Checklist
- [ ] "Kundali Details" title fits
- [ ] "Generate Detailed Report" button fits
- [ ] "Basic Information" section header fits
- [ ] All info labels fit (Name, DOB, Time, Place)
- [ ] "Astrological Information" header fits
- [ ] Lagna, Moon Sign, Sun Sign labels fit
- [ ] "Planetary Positions" header fits
- [ ] "Houses" section header fits
- [ ] House labels with numbers fit (e.g., "House 1: Aries")
- [ ] Action buttons at bottom fit

### Test Cases
1. View a kundali with full data
2. Scroll through all sections
3. Check planetary positions list
4. Verify house data display

---

## Screen 5: Kundali Form Screen

**Navigation:** Dashboard > New Kundali > Quick Generate

### Checklist
- [ ] "Get Your Free Kundali" header fits
- [ ] Subtitle text wraps correctly
- [ ] All form field labels fit
- [ ] Hint text in fields is visible
- [ ] "Auto-Fill Coordinates" button fits
- [ ] Latitude/Longitude labels fit
- [ ] Info text at bottom wraps correctly
- [ ] "Generate Free Kundali" button fits
- [ ] Loading dialog text displays correctly

### Test Cases
1. Fill out entire form
2. Test coordinate auto-fill
3. Submit and check loading message
4. Verify validation error messages

---

## Screen 6: Kundali Input Screen

**Navigation:** Dashboard > New Kundali > Professional

### Checklist
- [ ] "Enter Birth Details" header fits
- [ ] Subtitle wraps correctly
- [ ] All form labels fit
- [ ] Date/Time picker buttons fit
- [ ] "Fetch Coordinates" button fits
- [ ] Coordinates display format fits
- [ ] Note text at bottom wraps correctly
- [ ] "Generate Kundali" button fits

### Test Cases
1. Fill form with all fields
2. Test date/time pickers
3. Fetch coordinates
4. Verify coordinate display format

---

## Screen 7: Kundali WebView Screen

**Navigation:** Dashboard > New Kundali > Professional > Select Service

### Checklist
- [ ] "Generate Kundali Online" title fits
- [ ] Instructions text wraps correctly
- [ ] Service name buttons fit (AstroSage, mPanchang, etc.)
- [ ] WebView loads correctly
- [ ] Back button is accessible

### Test Cases
1. Select each service option
2. Verify WebView loads
3. Check navigation controls

---

## Screen 8: Compatibility Check Screen

**Navigation:** Dashboard > Services > Marriage Compatibility

### Checklist
- [ ] "Check Marriage Compatibility" title fits
- [ ] Subtitle wraps correctly
- [ ] "Person 1" and "Person 2" headers fit
- [ ] All form field labels fit for both persons
- [ ] "Fetch Coordinates" buttons fit
- [ ] Coordinate display fits
- [ ] Note text at bottom wraps correctly
- [ ] "Check Compatibility" button fits

### Test Cases
1. Fill details for both persons
2. Fetch coordinates for both
3. Submit and verify loading state
4. Check validation messages

---

## Screen 9: Compatibility Result Screen

**Navigation:** After compatibility check submission

### Checklist
- [ ] "Compatibility Result" title fits
- [ ] Score display fits
- [ ] "out of 36" text fits
- [ ] Match quality label fits (Excellent, Good, etc.)
- [ ] "Detailed Ashtakoot Analysis" header fits
- [ ] All 8 factor names fit (Varna, Vashya, Tara, etc.)
- [ ] Factor descriptions fit
- [ ] Mangal Dosha section header fits
- [ ] Dosha descriptions wrap correctly
- [ ] Remedies section fits

### Test Cases
1. View result with high score (30+)
2. View result with low score (<18)
3. Check Mangal Dosha section
4. Scroll through all factors

---

## Screen 10: Numerology Input Screen

**Navigation:** Dashboard > Services > Numerology

### Checklist
- [ ] "Enter Your Details" header fits
- [ ] Subtitle wraps correctly
- [ ] Name field label fits
- [ ] Date picker label fits
- [ ] "What You'll Discover" section header fits
- [ ] All discovery items fit (Life Path, Destiny, etc.)
- [ ] Item descriptions wrap correctly
- [ ] Note text at bottom wraps correctly
- [ ] "Analyze Numerology" button fits

### Test Cases
1. Fill name and date
2. Read all discovery items
3. Submit form
4. Check validation messages

---

## Screen 11: Numerology Analysis Screen

**Navigation:** After numerology submission

### Checklist
- [ ] "Numerology Analysis" title fits
- [ ] "Your Core Numbers" section header fits
- [ ] Number labels fit (Life Path, Destiny, Soul Urge)
- [ ] Analysis section headers fit
- [ ] Analysis text wraps correctly
- [ ] "Lucky Elements" section header fits
- [ ] Lucky numbers, colors, days display correctly
- [ ] Compatibility section fits

### Test Cases
1. View complete analysis
2. Scroll through all sections
3. Check number displays
4. Verify lucky elements section

---

## Screen 12: Palmistry Upload Screen

**Navigation:** Dashboard > Services > Palmistry

### Checklist
- [ ] "Capture Palm Images" header fits
- [ ] Subtitle wraps correctly
- [ ] "Left Hand" and "Right Hand" labels fit
- [ ] "Take Photo" button fits
- [ ] "Choose from Gallery" button fits
- [ ] Tips text wraps correctly (multi-line)
- [ ] "Analyze Palmistry" button fits
- [ ] Error messages display correctly

### Test Cases
1. Capture left hand image
2. Capture right hand image
3. Try to submit with one image missing
4. Read all tips text

---

## Screen 13: Palmistry Analysis Screen

**Navigation:** After palmistry submission

### Checklist
- [ ] "Palmistry Analysis" title fits
- [ ] "Analysis Summary" section header fits
- [ ] "Major Palm Lines" section header fits
- [ ] Line names fit (Life, Heart, Head, Fate)
- [ ] "Palm Mounts" section header fits
- [ ] "Finger Analysis" section header fits
- [ ] "Predictions" section header fits
- [ ] Subsection headers fit (Health, Career, etc.)
- [ ] Analysis text wraps correctly

### Test Cases
1. View complete analysis
2. Scroll through all sections
3. Check all subsections
4. Verify text wrapping

---

## Screen 14: Onboarding Screen

**Navigation:** First app launch OR Settings > View Onboarding

### Checklist
- [ ] All 6 slide titles fit
- [ ] All subtitles fit
- [ ] All descriptions wrap correctly (no truncation)
- [ ] "Skip" button fits
- [ ] "Next" button fits
- [ ] "Back" button fits
- [ ] "Get Started" button fits (final slide)
- [ ] Page indicator displays correctly
- [ ] Slide transitions work smoothly

### Test Cases
1. Navigate through all 6 slides
2. Test Skip button
3. Test Back button
4. Complete onboarding

---

## Screen 15: Order Tracking Screen

**Navigation:** Dashboard > Orders > Select an Order

### Checklist
- [ ] "Order Tracking" title fits
- [ ] "Order Details" section header fits
- [ ] All detail labels fit (Order ID, Service, Amount, etc.)
- [ ] "Order Timeline" section header fits
- [ ] Timeline step labels fit
- [ ] Status labels fit (Completed, Pending, In Progress)
- [ ] Status descriptions wrap correctly
- [ ] "View Report" button fits
- [ ] "Download Report" button fits

### Test Cases
1. View pending order
2. View processing order
3. View completed order
4. Check all timeline steps
5. Test action buttons

---

## Common Elements to Check on All Screens

### Navigation Bar
- [ ] All tab labels fit (Home, Services, Reports, Profile)
- [ ] Icons display correctly
- [ ] Selected state is visible

### Dialogs and Alerts
- [ ] Dialog titles fit
- [ ] Dialog messages wrap correctly
- [ ] Button labels in dialogs fit
- [ ] Close button is accessible

### Toast/Snackbar Messages
- [ ] Success messages display completely
- [ ] Error messages display completely
- [ ] Messages don't overlap with other UI

### Form Validation
- [ ] Error messages display in correct language
- [ ] Error messages wrap if long
- [ ] Error messages are readable

---

## Device-Specific Testing

### Small Screens (< 5.5")
- [ ] All buttons remain accessible
- [ ] Text doesn't overflow
- [ ] Scrolling works smoothly

### Medium Screens (5.5" - 6.5")
- [ ] Layout looks balanced
- [ ] No excessive white space
- [ ] Text is readable

### Large Screens (> 6.5")
- [ ] Layout scales appropriately
- [ ] Text doesn't look too small
- [ ] Buttons are appropriately sized

---

## Orientation Testing

### Portrait Mode
- [ ] All screens display correctly
- [ ] No layout breaking

### Landscape Mode (if supported)
- [ ] Layout adapts appropriately
- [ ] All content remains accessible

---

## Accessibility Testing

### Font Scaling
- [ ] Test with system font size set to Large
- [ ] Test with system font size set to Extra Large
- [ ] Verify text doesn't overflow at larger sizes

### Screen Reader
- [ ] Test with TalkBack (Android) or VoiceOver (iOS)
- [ ] Verify all labels are read correctly in each language
- [ ] Check semantic labels are localized

---

## Issue Reporting Template

If you find a layout issue, document it as follows:

```
**Screen:** [Screen Name]
**Language:** [Language Code]
**Issue:** [Description]
**Expected:** [What should happen]
**Actual:** [What actually happens]
**Screenshot:** [Attach screenshot]
**Device:** [Device model and screen size]
**Severity:** [Critical/High/Medium/Low]
```

---

## Sign-off

After completing all tests for all languages:

**Tester Name:** ___________________
**Date:** ___________________
**Languages Tested:** ___________________
**Issues Found:** ___________________
**Status:** [ ] Approved [ ] Needs Fixes

---

## Notes

- Focus on longest translations (Tamil, Telugu) as they are most likely to cause issues
- Pay special attention to buttons and fixed-width containers
- Check multi-line text wrapping carefully
- Verify dynamic content with placeholders works correctly
- Test on actual devices, not just emulators, for best results

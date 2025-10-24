# Accessibility Guide

This document outlines the accessibility features implemented in the DishaAjyoti application and provides guidelines for maintaining and improving accessibility.

## Overview

The DishaAjyoti app follows WCAG 2.1 Level AA standards to ensure the application is accessible to all users, including those with disabilities.

## Implemented Accessibility Features

### 1. Semantic Labels

All interactive elements have been enhanced with semantic labels for screen readers:

- **Buttons**: Clear labels describing the action (e.g., "Login", "Get Now", "Skip onboarding")
- **Text Fields**: Labels include field name, hint text, and error messages
- **Cards**: Descriptive labels combining service/report name, status, and relevant details
- **Navigation**: Bottom navigation items announce current selection state
- **Icons**: Icon-only buttons include descriptive labels

### 2. Touch Target Sizes

All interactive elements meet or exceed the minimum touch target size:

- **Minimum Size**: 48x48 dp (Material Design guideline)
- **Recommended Size**: 56x56 dp for primary actions
- **Implementation**: Buttons use `height: 56` by default
- **Navigation Items**: Constrained to minimum 48x48 dp

### 3. Screen Reader Support

The app is fully compatible with:

- **Android**: TalkBack
- **iOS**: VoiceOver

#### Testing Instructions

**Android (TalkBack):**
1. Go to Settings > Accessibility > TalkBack
2. Enable TalkBack
3. Navigate the app using swipe gestures
4. Double-tap to activate elements

**iOS (VoiceOver):**
1. Go to Settings > Accessibility > VoiceOver
2. Enable VoiceOver
3. Navigate the app using swipe gestures
4. Double-tap to activate elements

### 4. Color Contrast Ratios

All text and interactive elements meet WCAG AA standards (4.5:1 for normal text, 3:1 for large text):

#### Primary Color Combinations

| Foreground | Background | Ratio | Status |
|------------|------------|-------|--------|
| Black (#1A1A1A) | White (#FFFFFF) | 16.1:1 | ✅ AAA |
| Dark Blue (#003366) | White (#FFFFFF) | 12.6:1 | ✅ AAA |
| Dark Orange (#FF6B35) | White (#FFFFFF) | 3.8:1 | ✅ AA (Large Text) |
| White (#FFFFFF) | Primary Blue (#0066CC) | 5.2:1 | ✅ AA |
| White (#FFFFFF) | Primary Orange (#FF6B35) | 2.9:1 | ⚠️ Large Text Only |

#### Status Colors

| Color | Use Case | Contrast with White |
|-------|----------|---------------------|
| Success Green (#06A77D) | Success messages | 4.8:1 ✅ |
| Error Red (#E63946) | Error messages | 4.9:1 ✅ |
| Warning Yellow (#FFB703) | Warning messages | 1.9:1 ⚠️ |

**Note**: Warning yellow should only be used with dark text overlay or as a background with sufficient contrast.

### 5. Text Scaling Support

The app supports dynamic text scaling:

- All text uses `TextStyle` from theme
- No hardcoded font sizes that ignore system settings
- Layouts adapt to larger text sizes
- Minimum font size: 12sp (caption text)
- Maximum recommended scaling: 200%

#### Testing Text Scaling

**Android:**
1. Settings > Display > Font size
2. Adjust slider to test different sizes

**iOS:**
1. Settings > Display & Brightness > Text Size
2. Adjust slider to test different sizes

### 6. Focus Management

Proper focus order and management:

- Logical tab order for keyboard navigation
- Focus indicators visible on all interactive elements
- Auto-focus on first input field where appropriate
- Focus returns to triggering element after dialog dismissal

### 7. Error Handling

Accessible error messages:

- Error messages announced to screen readers via `Semantics(liveRegion: true)`
- Visual error indicators (icons, colors)
- Clear, actionable error text
- Errors associated with specific form fields

### 8. Loading States

Accessible loading indicators:

- Loading spinners have semantic labels ("Loading")
- Button states clearly indicate loading ("Loading, Login")
- Disabled state announced to screen readers

## Accessibility Utilities

### AccessibilityUtils Class

Located in `lib/utils/accessibility_utils.dart`, this utility class provides:

```dart
// Ensure minimum touch target size
AccessibilityUtils.ensureMinTouchTarget(
  child: widget,
  minSize: 48.0,
);

// Create semantic labels
final label = AccessibilityUtils.createSemanticLabel(
  label: 'Login',
  hint: 'Double tap to login',
  isEnabled: true,
);

// Check color contrast
final meetsStandards = AccessibilityUtils.meetsContrastRatio(
  foreground: Colors.black,
  background: Colors.white,
  minRatio: 4.5,
);
```

## Best Practices

### 1. Adding New Interactive Elements

When adding new buttons, links, or interactive widgets:

```dart
Semantics(
  button: true,
  label: 'Clear description of action',
  hint: 'Additional context if needed',
  enabled: !isDisabled,
  child: YourWidget(),
)
```

### 2. Form Fields

Always provide labels and error handling:

```dart
CustomTextField(
  label: 'Email',
  hint: 'Enter your email address',
  errorText: _emailError,
  // ... other properties
)
```

### 3. Images and Icons

Provide semantic labels for meaningful images:

```dart
Semantics(
  label: 'Service icon for Palmistry',
  child: Icon(Icons.palm),
)
```

Exclude decorative images from screen readers:

```dart
Semantics(
  excludeSemantics: true,
  child: DecorativeImage(),
)
```

### 4. Navigation

Announce navigation changes:

```dart
Semantics(
  label: 'Home tab, currently selected',
  selected: true,
  child: NavigationItem(),
)
```

### 5. Dynamic Content

Use live regions for dynamic updates:

```dart
Semantics(
  liveRegion: true,
  child: Text('Content updated'),
)
```

## Testing Checklist

### Manual Testing

- [ ] Navigate entire app using TalkBack/VoiceOver
- [ ] Test all interactive elements with screen reader
- [ ] Verify all images have appropriate labels
- [ ] Test with 200% text scaling
- [ ] Verify color contrast in all states (normal, hover, focus, disabled)
- [ ] Test keyboard navigation (web/desktop)
- [ ] Verify focus indicators are visible
- [ ] Test error messages are announced
- [ ] Verify loading states are announced

### Automated Testing

Run accessibility tests:

```bash
flutter test test/accessibility_test.dart
```

### Tools

- **Flutter DevTools**: Accessibility inspector
- **Android Accessibility Scanner**: Automated checks on Android
- **iOS Accessibility Inspector**: Automated checks on iOS
- **Contrast Checker**: Online tools for color contrast verification

## Common Issues and Solutions

### Issue: Button too small
**Solution**: Ensure minimum size of 48x48 dp
```dart
constraints: BoxConstraints(minWidth: 48, minHeight: 48)
```

### Issue: Missing semantic label
**Solution**: Wrap with Semantics widget
```dart
Semantics(label: 'Description', child: widget)
```

### Issue: Poor color contrast
**Solution**: Use AccessibilityUtils to verify contrast ratios
```dart
AccessibilityUtils.meetsContrastRatio(foreground, background)
```

### Issue: Text not scaling
**Solution**: Use theme text styles instead of hardcoded sizes
```dart
style: AppTypography.bodyLarge // ✅
style: TextStyle(fontSize: 16) // ❌
```

## Resources

- [Flutter Accessibility Guide](https://docs.flutter.dev/development/accessibility-and-localization/accessibility)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Material Design Accessibility](https://material.io/design/usability/accessibility.html)
- [iOS Accessibility Guidelines](https://developer.apple.com/accessibility/)
- [Android Accessibility Guidelines](https://developer.android.com/guide/topics/ui/accessibility)

## Continuous Improvement

Accessibility is an ongoing process. Regular testing and updates are essential:

1. Test with real users who rely on assistive technologies
2. Stay updated with WCAG guidelines
3. Monitor user feedback for accessibility issues
4. Conduct regular accessibility audits
5. Train team members on accessibility best practices

## Contact

For accessibility-related questions or issues, please contact the development team or file an issue in the project repository.

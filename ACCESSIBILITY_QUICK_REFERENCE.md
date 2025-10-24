# Accessibility Quick Reference Card

Quick reference for maintaining accessibility standards in DishaAjyoti.

## ✅ Checklist for New Features

- [ ] All buttons have semantic labels
- [ ] Touch targets are minimum 48x48 dp
- [ ] Color contrast meets 4.5:1 ratio
- [ ] Text uses theme styles (supports scaling)
- [ ] Error messages use live regions
- [ ] Loading states are announced
- [ ] Icons have descriptive labels
- [ ] Forms have proper labels and hints
- [ ] Tested with TalkBack/VoiceOver

## 🎯 Common Patterns

### Button with Semantic Label
```dart
Semantics(
  button: true,
  label: 'Login',
  hint: 'Double tap to login',
  enabled: !isDisabled,
  child: YourButton(),
)
```

### Text Field with Accessibility
```dart
CustomTextField(
  label: 'Email',
  hint: 'Enter your email',
  errorText: _emailError,
  // Automatically includes semantic labels
)
```

### Card with Description
```dart
Semantics(
  label: 'Service name, Price: 299 rupees',
  button: true,
  hint: 'Double tap to select',
  child: YourCard(),
)
```

### Navigation Item
```dart
Semantics(
  button: true,
  selected: isSelected,
  label: 'Home',
  hint: isSelected 
    ? 'Home tab, currently selected'
    : 'Double tap to switch to Home tab',
  child: NavigationItem(),
)
```

### Error Message (Live Region)
```dart
Semantics(
  liveRegion: true,
  child: Text('Error: Invalid input'),
)
```

### Loading State
```dart
Semantics(
  label: 'Loading',
  child: CircularProgressIndicator(),
)
```

## 🎨 Color Contrast Requirements

| Text Size | Minimum Ratio | Use Case |
|-----------|---------------|----------|
| Normal (< 18pt) | 4.5:1 | Body text, labels |
| Large (≥ 18pt) | 3:1 | Headings, buttons |
| UI Components | 3:1 | Icons, borders |

### Approved Color Combinations
- ✅ Black (#1A1A1A) on White (#FFFFFF) - 16.1:1
- ✅ Primary Blue (#0066CC) on White - 5.2:1
- ✅ White on Primary Blue - 5.2:1
- ✅ Error Red (#E63946) on White - 4.9:1

## 📏 Touch Target Sizes

| Element | Minimum Size | Recommended |
|---------|-------------|-------------|
| Buttons | 48x48 dp | 56x56 dp |
| Icons | 48x48 dp | 48x48 dp |
| List Items | 48 dp height | 56 dp height |
| Text Links | 48x48 dp | - |

### Ensure Minimum Size
```dart
Container(
  constraints: BoxConstraints(
    minWidth: 48,
    minHeight: 48,
  ),
  child: YourWidget(),
)
```

## 🧪 Testing Commands

```bash
# Run accessibility tests
flutter test test/accessibility_test.dart

# Check diagnostics
flutter analyze

# Test with screen reader
# Android: Enable TalkBack in Settings
# iOS: Enable VoiceOver in Settings
```

## 🚫 Common Mistakes to Avoid

❌ **Don't**: Use hardcoded font sizes
```dart
Text('Hello', style: TextStyle(fontSize: 16))
```

✅ **Do**: Use theme text styles
```dart
Text('Hello', style: AppTypography.bodyLarge)
```

---

❌ **Don't**: Create small touch targets
```dart
IconButton(iconSize: 16, ...)
```

✅ **Do**: Ensure minimum 48x48 dp
```dart
IconButton(
  iconSize: 24,
  constraints: BoxConstraints(minWidth: 48, minHeight: 48),
  ...
)
```

---

❌ **Don't**: Use low contrast colors
```dart
Text('Hello', style: TextStyle(color: Color(0xFFCCCCCC)))
// on white background
```

✅ **Do**: Verify contrast ratio
```dart
AccessibilityUtils.meetsContrastRatio(
  foreground: myColor,
  background: backgroundColor,
)
```

---

❌ **Don't**: Forget semantic labels
```dart
IconButton(icon: Icon(Icons.delete), onPressed: ...)
```

✅ **Do**: Add semantic labels
```dart
Semantics(
  button: true,
  label: 'Delete item',
  child: IconButton(icon: Icon(Icons.delete), onPressed: ...),
)
```

## 📚 Quick Links

- [Full Accessibility Guide](./ACCESSIBILITY_GUIDE.md)
- [Implementation Summary](./ACCESSIBILITY_IMPLEMENTATION_SUMMARY.md)
- [Accessibility Utils](./lib/utils/accessibility_utils.dart)
- [Test Suite](./test/accessibility_test.dart)

## 🆘 Need Help?

1. Check `ACCESSIBILITY_GUIDE.md` for detailed documentation
2. Review existing implementations in widgets
3. Run accessibility tests to verify compliance
4. Test with actual screen readers

---

**Remember**: Accessibility is not optional—it's essential for all users! 🌟

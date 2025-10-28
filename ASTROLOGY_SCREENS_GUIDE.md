# Astrology Services Screens - Developer Guide

## Quick Navigation Reference

### Kundali Service
```dart
// Navigate to create new kundali
AppRoutes.navigateToKundaliInput(context);

// Navigate to kundali list
AppRoutes.navigateToKundaliList(context);

// Navigate to specific kundali detail
AppRoutes.navigateToKundaliDetail(context, kundaliId: 123);
```

### Palmistry Service
```dart
// Navigate to upload palm images
AppRoutes.navigateToPalmistryUpload(context);

// Navigate to analysis results
AppRoutes.navigateToPalmistryAnalysis(
  context,
  analysisData: responseData,
);
```

### Numerology Service
```dart
// Navigate to numerology input
AppRoutes.navigateToNumerologyInput(context);

// Navigate to analysis results
AppRoutes.navigateToNumerologyAnalysis(
  context,
  analysisData: responseData,
);
```

### Compatibility Service
```dart
// Navigate to compatibility check
AppRoutes.navigateToCompatibilityCheck(context);

// Navigate to compatibility results
AppRoutes.navigateToCompatibilityResult(
  context,
  compatibilityData: responseData,
);
```

### Reports
```dart
// Navigate to reports list
AppRoutes.navigateToReportsList(context);

// Navigate to specific report
AppRoutes.navigateToReportDetailApi(context, reportId: 456);
```

## Screen Flow Diagrams

### Kundali Flow
```
Dashboard
  ↓
KundaliInputScreen (enter birth details)
  ↓
KundaliDetailScreen (view analysis)
  ↓
Generate Report Button
  ↓
ReportDetailApiScreen (view/download PDF)
```

### Palmistry Flow
```
Dashboard
  ↓
PalmistryUploadScreen (capture images)
  ↓
PalmistryAnalysisScreen (view analysis)
```

### Numerology Flow
```
Dashboard
  ↓
NumerologyInputScreen (enter name & DOB)
  ↓
NumerologyAnalysisScreen (view analysis)
```

### Compatibility Flow
```
Dashboard
  ↓
CompatibilityCheckScreen (enter two people's details)
  ↓
CompatibilityResultScreen (view compatibility score)
```

## API Service Usage

All screens use the `ApiService` provider. Access it in your screens:

```dart
final apiService = context.read<ApiService>();
```

### Example: Generate Kundali
```dart
try {
  final response = await apiService.generateKundali(
    name: 'John Doe',
    dateOfBirth: '1990-01-15',
    timeOfBirth: '14:30:00',
    placeOfBirth: 'Mumbai',
    latitude: 19.0760,
    longitude: 72.8777,
  );
  
  if (response.data['success'] == true) {
    final kundaliId = response.data['data']['kundali_id'];
    // Navigate to detail screen
  }
} catch (e) {
  ErrorHandler.showError(context, 
    title: 'Error', 
    message: e.toString()
  );
}
```

## Common Patterns

### Loading State
```dart
bool _isLoading = false;

setState(() {
  _isLoading = true;
});

try {
  // API call
} finally {
  setState(() {
    _isLoading = false;
  });
}
```

### Error Handling
```dart
try {
  // API call
} catch (e) {
  if (mounted) {
    ErrorHandler.showError(
      context,
      title: 'Operation Failed',
      message: e.toString(),
    );
  }
}
```

### Form Validation
```dart
final _formKey = GlobalKey<FormState>();

if (!_formKey.currentState!.validate()) {
  return;
}
```

## Geocoding Integration

For birth place coordinates:

```dart
final geocodingService = GeocodingService.instance;
final coordinates = await geocodingService.getIndianCityCoordinates(
  'Mumbai',
);

if (coordinates != null) {
  final latitude = coordinates['latitude'];
  final longitude = coordinates['longitude'];
}
```

## Image Handling (Palmistry)

```dart
final ImagePicker _picker = ImagePicker();

// Capture from camera
final XFile? image = await _picker.pickImage(
  source: ImageSource.camera,
  maxWidth: 1920,
  maxHeight: 1920,
  imageQuality: 85,
);

// Select from gallery
final XFile? image = await _picker.pickImage(
  source: ImageSource.gallery,
  maxWidth: 1920,
  maxHeight: 1920,
  imageQuality: 85,
);
```

## PDF Download & Share

```dart
// Download PDF
final response = await apiService.downloadReport(reportId);
final file = File(filePath);
await file.writeAsBytes(response.data);

// Share PDF
await Share.shareXFiles(
  [XFile(filePath)],
  subject: 'Astrology Report',
);
```

## Styling Guidelines

All screens use the app theme:

```dart
// Colors
AppColors.primaryBlue
AppColors.primaryOrange
AppColors.textPrimary
AppColors.textSecondary

// Typography
AppTypography.h1
AppTypography.h2
AppTypography.h3
AppTypography.bodyLarge
AppTypography.bodyMedium
AppTypography.bodySmall
```

## Widget Components

### Custom Widgets Available:
- `PrimaryButton` - Main action button
- `SecondaryButton` - Secondary action button
- `CustomTextField` - Styled text input
- `LoadingOverlay` - Full-screen loading indicator
- `ErrorDialog` - Error display dialog

### Example Usage:
```dart
PrimaryButton(
  label: 'Generate Kundali',
  onPressed: _generateKundali,
  isLoading: _isLoading,
  icon: Icons.auto_awesome,
)
```

## Testing Checklist

- [ ] Navigation works correctly
- [ ] Form validation displays errors
- [ ] API calls handle success/error
- [ ] Loading states display properly
- [ ] Error messages are user-friendly
- [ ] Back navigation works
- [ ] Data persists correctly
- [ ] Images upload successfully (palmistry)
- [ ] PDFs download correctly (reports)
- [ ] Share functionality works (reports)

## Troubleshooting

### Common Issues:

1. **Context not available after async**
   - Always check `if (mounted)` before using context

2. **API errors**
   - Check network connectivity
   - Verify API endpoint URLs
   - Check authentication token

3. **Image picker not working**
   - Verify permissions in AndroidManifest.xml and Info.plist
   - Check camera/gallery permissions

4. **PDF download fails**
   - Check storage permissions
   - Verify file path is accessible
   - Check available storage space

## Performance Tips

1. Use `const` constructors where possible
2. Implement pagination for large lists
3. Cache API responses when appropriate
4. Compress images before upload
5. Use `ListView.builder` for long lists
6. Dispose controllers in `dispose()` method

## Accessibility

All screens implement:
- Semantic labels for screen readers
- Sufficient color contrast
- Touch target sizes (minimum 48x48)
- Keyboard navigation support
- Error announcements

## Next Steps

To add a new astrology service screen:

1. Create screen file in `lib/screens/`
2. Add route constant in `AppRoutes`
3. Add route builder in `getRoutes()` or `onGenerateRoute()`
4. Add navigation helper method
5. Implement API endpoint in `ApiService`
6. Add to this guide

## Support

For questions or issues:
- Check existing screen implementations
- Review API documentation
- Test with mock data first
- Use error logging for debugging

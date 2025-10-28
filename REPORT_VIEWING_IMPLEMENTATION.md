# Report Viewing Implementation

## Overview
This document describes the implementation of task 15.6: Report viewing functionality in Flutter.

## Requirements Addressed
- **8.3**: PDF download and viewing
- **8.4**: Report list and detail views
- **8.5**: Share functionality

## Components Implemented

### 1. Reports List Screen (`reports_list_screen.dart`)
**Features:**
- Displays all user reports in a scrollable list
- Filter reports by status (Ready, Generating, Failed)
- Pull-to-refresh functionality
- Infinite scroll with pagination
- Status indicators with color coding
- File size and creation date display
- Navigation to report detail view

**Key Functionality:**
- Uses `ReportProvider` for state management
- Implements lazy loading for better performance
- Shows empty state when no reports exist
- Error handling with retry capability

### 2. Report Detail Screen (`report_detail_screen.dart`)
**Features:**
- PDF viewer using Syncfusion PDF Viewer
- Download report to device storage
- Share report via native share dialog
- Progress indicator during download
- Permission handling for storage access
- Success/error dialogs

**Key Functionality:**
- Displays PDF inline with zoom and text selection
- Downloads PDF to Downloads folder (Android) or Documents (iOS)
- Shares PDF using `share_plus` package
- Handles storage permissions properly

### 3. Report Detail API Screen (`report_detail_api_screen.dart`)
**Features:**
- Fetches report details from API
- Displays report metadata
- Download and share functionality
- Works with report ID only (no need for full report object)

**Key Functionality:**
- Loads report data dynamically
- Downloads PDF bytes from API
- Shares report with custom message

### 4. Routes Configuration (`app_routes.dart`)
**Updates:**
- Added `reportsList` route for reports list screen
- Added `reportDetailApi` route for API-based detail screen
- Added helper methods:
  - `navigateToReportsList()`
  - `navigateToReportDetailApi()`

## Technical Implementation

### State Management
- Uses `ReportProvider` (already implemented) for:
  - Loading reports list
  - Pagination
  - Filtering by status
  - Downloading reports
  - Sharing reports

### PDF Viewing
- **Library**: `syncfusion_flutter_pdfviewer`
- **Features**:
  - Network PDF loading
  - Zoom and pan
  - Text selection
  - Scroll indicators

### File Operations
- **Download**: Uses `path_provider` to get appropriate directory
- **Permissions**: Uses `permission_handler` for storage access
- **Share**: Uses `share_plus` for native sharing

### UI/UX
- Material Design 3 components
- Custom theme colors from `AppColors`
- Typography from `AppTypography`
- Responsive layouts
- Loading states
- Error states
- Empty states

## File Structure
```
lib/
├── screens/
│   ├── reports_list_screen.dart          # Reports list view
│   ├── report_detail_screen.dart         # Report detail with PDF viewer
│   └── report_detail_api_screen.dart     # API-based report detail
├── providers/
│   └── report_provider.dart              # Report state management
├── services/
│   ├── api_service.dart                  # API endpoints
│   └── report_service.dart               # Report-specific API calls
├── models/
│   └── report_model.dart                 # Report data model
└── routes/
    └── app_routes.dart                   # Navigation configuration
```

## API Integration

### Endpoints Used
- `GET /api/v1/reports/list` - Get user's reports
- `GET /api/v1/reports/{id}` - Get report details
- `GET /api/v1/reports/{id}/download` - Download PDF

### Request Flow
1. User opens reports list
2. App fetches reports from API
3. User taps on a report
4. App navigates to detail screen
5. PDF is loaded from URL
6. User can download or share

## Permissions Required

### Android
- `WRITE_EXTERNAL_STORAGE` (Android < 13)
- `READ_EXTERNAL_STORAGE` (Android < 13)
- No permissions needed for Android 13+ (scoped storage)

### iOS
- No permissions needed (app sandbox)

## Usage Examples

### Navigate to Reports List
```dart
Navigator.pushNamed(context, AppRoutes.reportsList);
// or
AppRoutes.navigateToReportsList(context);
```

### Navigate to Report Detail
```dart
Navigator.pushNamed(
  context,
  AppRoutes.reportDetailApi,
  arguments: reportId,
);
// or
AppRoutes.navigateToReportDetailApi(
  context,
  reportId: reportId,
);
```

### Filter Reports by Status
```dart
final provider = context.read<ReportProvider>();
await provider.loadReports(status: ReportStatus.ready);
```

### Download Report
```dart
final provider = context.read<ReportProvider>();
final bytes = await provider.downloadReport(reportId);
```

## Testing Considerations

### Manual Testing Checklist
- [ ] Reports list loads correctly
- [ ] Pagination works (scroll to load more)
- [ ] Pull-to-refresh updates list
- [ ] Filter by status works
- [ ] Tapping report navigates to detail
- [ ] PDF displays correctly
- [ ] Download saves file to correct location
- [ ] Share opens native share dialog
- [ ] Permissions are requested properly
- [ ] Error states display correctly
- [ ] Empty state displays when no reports
- [ ] Loading states show during operations

### Edge Cases Handled
- No internet connection
- API errors
- Permission denied
- Storage full
- Invalid PDF URL
- Large PDF files
- Slow network

## Dependencies
- `provider: ^6.1.1` - State management
- `dio: ^5.4.0` - HTTP client
- `syncfusion_flutter_pdfviewer: ^28.1.33` - PDF viewing
- `path_provider: ^2.1.5` - File system paths
- `permission_handler: ^11.3.1` - Permissions
- `share_plus: ^7.2.2` - Native sharing

## Future Enhancements
- Offline PDF caching
- PDF annotations
- Print functionality
- Email report directly
- Report preview thumbnails
- Search within reports
- Report categories/tags
- Bulk download
- Report expiry dates

## Notes
- All screens follow Material Design guidelines
- Accessibility features included (semantic labels)
- Supports both light and dark themes
- Localization ready (uses AppLocalizations)
- Error handling with user-friendly messages
- Performance optimized with lazy loading

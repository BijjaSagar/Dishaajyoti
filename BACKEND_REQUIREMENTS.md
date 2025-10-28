# Backend API Requirements for DishaAjyoti

## Current Issue

The Flutter app is trying to access: `https://rhtechnology.in/Dishaajyoti/kundali/list`

But getting **404 Error**: "The route Dishaajyoti/kundali/list could not be found."

## Required Backend Routes

### Base URL
`https://rhtechnology.in/Dishaajyoti`

All routes should be directly under this base URL (no `/api/v1` prefix needed).

---

## Priority 1: Essential Routes (Needed Now)

### 1. Get Kundali List
**GET** `/kundali/list`

**Query Parameters:**
- `page` (integer, default: 1)
- `limit` (integer, default: 10)

**Response:**
```json
{
  "success": true,
  "data": {
    "kundalis": [
      {
        "kundali_id": 1,
        "id": 1,
        "name": "Rahul Kumar",
        "date_of_birth": "1990-05-15",
        "time_of_birth": "14:30:00",
        "place_of_birth": "Mumbai",
        "lagna": "Aries",
        "moon_sign": "Taurus",
        "created_at": "2024-10-20T10:30:00Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 5,
      "total_items": 50,
      "per_page": 10
    }
  }
}
```

### 2. Generate Kundali
**POST** `/kundali/generate`

**Request Body:**
```json
{
  "name": "Rahul Kumar",
  "date_of_birth": "1990-05-15",
  "time_of_birth": "14:30:00",
  "place_of_birth": "Mumbai",
  "latitude": 19.0760,
  "longitude": 72.8777,
  "timezone": "Asia/Kolkata"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Kundali generated successfully",
  "data": {
    "kundali_id": 123,
    "name": "Rahul Kumar",
    "lagna": "Aries",
    "moon_sign": "Taurus",
    "sun_sign": "Taurus",
    "pdf_url": "https://example.com/kundali_123.pdf"
  }
}
```

### 3. Get Specific Kundali
**GET** `/kundali/{kundaliId}`

**Response:**
```json
{
  "success": true,
  "data": {
    "kundali_id": 123,
    "name": "Rahul Kumar",
    "date_of_birth": "1990-05-15",
    "time_of_birth": "14:30:00",
    "place_of_birth": "Mumbai",
    "latitude": 19.0760,
    "longitude": 72.8777,
    "lagna": "Aries",
    "moon_sign": "Taurus",
    "planets": {},
    "houses": {},
    "pdf_url": "https://example.com/kundali_123.pdf"
  }
}
```

### 4. Delete Kundali
**DELETE** `/kundali/{kundaliId}`

**Response:**
```json
{
  "success": true,
  "message": "Kundali deleted successfully"
}
```

---

## Priority 2: Service Management

### 5. Get Services List
**GET** `/services/list`

**Response:**
```json
{
  "success": true,
  "data": {
    "services": [
      {
        "id": "1",
        "name": "AI Kundali Analysis",
        "description": "Comprehensive AI-powered Vedic astrology report",
        "category": "Astrology",
        "price": 499,
        "currency": "INR",
        "icon": "⭐",
        "features": [
          "Detailed birth chart analysis",
          "Career predictions",
          "Professional PDF report"
        ],
        "estimatedTime": "24-48 hours",
        "isActive": true
      }
    ]
  }
}
```

### 6. Get Service Details
**GET** `/services/{serviceId}`

---

## Priority 3: Other Services

### Palmistry
- **POST** `/palmistry/upload` - Upload palm images
- **POST** `/palmistry/analyze` - Analyze palmistry
- **GET** `/palmistry/list` - Get palmistry list

### Numerology
- **POST** `/numerology/calculate` - Calculate numerology
- **POST** `/numerology/analyze` - Generate analysis
- **GET** `/numerology/list` - Get numerology list

### Compatibility
- **POST** `/compatibility/check` - Check compatibility
- **GET** `/compatibility/list` - Get compatibility list

### Reports
- **GET** `/reports/list` - Get all reports
- **GET** `/reports/{reportId}` - Get specific report
- **GET** `/reports/{reportId}/download` - Download PDF

### Orders
- **POST** `/orders/create` - Create order
- **GET** `/orders/list` - Get orders
- **GET** `/orders/{orderId}` - Get order details
- **PUT** `/orders/{orderId}/status` - Update status

---

## Error Response Format

All errors should follow this format:

```json
{
  "success": false,
  "message": "Error message here",
  "errors": {
    "field_name": ["Error detail"]
  }
}
```

---

## Authentication

Most endpoints require JWT authentication:

**Header:**
```
Authorization: Bearer {jwt_token}
```

---

## Testing Notes

**All services are currently set to FREE (₹0) in the app for testing.**

When backend is ready:
1. Admin can set actual prices
2. Payment integration will be enabled
3. Report generation will be connected

---

## Quick Fix for Testing

**Option 1: Mock Endpoint**
Create a simple `/kundali/list` endpoint that returns empty array:

```json
{
  "success": true,
  "data": {
    "kundalis": [],
    "pagination": {
      "current_page": 1,
      "total_pages": 0,
      "total_items": 0,
      "per_page": 10
    }
  }
}
```

**Option 2: Sample Data**
Return some sample kundali data for testing the UI.

---

## Contact

For questions about API requirements, please refer to the complete API documentation in `API_ENDPOINTS.md`.

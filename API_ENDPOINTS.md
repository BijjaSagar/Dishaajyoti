# DishaAjyoti API Endpoints

Base URL: `https://rhtechnology.in/Dishaajyoti`

**Note**: All endpoints are directly under the base URL without `/api/v1` prefix.

## Authentication Endpoints

### Login
- **POST** `/auth/login`
- Body: `{ "email": "string", "password": "string" }`

### Register
- **POST** `/auth/register`
- Body: `{ "name": "string", "email": "string", "password": "string", "phone": "string" }`

### Logout
- **POST** `/auth/logout`
- Headers: `Authorization: Bearer {token}`

### Refresh Token
- **POST** `/auth/refresh`
- Body: `{ "refreshToken": "string" }`

### Reset Password
- **POST** `/auth/reset-password`
- Body: `{ "email": "string" }`

---

## Kundali Endpoints

### Generate Kundali
- **POST** `/kundali/generate`
- Headers: `Authorization: Bearer {token}`
- Body:
```json
{
  "name": "string",
  "date_of_birth": "YYYY-MM-DD",
  "time_of_birth": "HH:MM:SS",
  "place_of_birth": "string",
  "latitude": 0.0,
  "longitude": 0.0,
  "timezone": "string (optional)"
}
```

### Get Kundali List
- **GET** `/kundali/list?page=1&limit=10`
- Headers: `Authorization: Bearer {token}`

### Get Specific Kundali
- **GET** `/kundali/{kundaliId}`
- Headers: `Authorization: Bearer {token}`

### Generate Kundali Report
- **POST** `/kundali/generate_report`
- Headers: `Authorization: Bearer {token}`
- Body: `{ "kundali_id": 123 }`

### Delete Kundali
- **DELETE** `/kundali/{kundaliId}`
- Headers: `Authorization: Bearer {token}`

---

## Palmistry Endpoints

### Upload Palm Images
- **POST** `/palmistry/upload`
- Headers: `Authorization: Bearer {token}`, `Content-Type: multipart/form-data`
- Body: FormData with `left_hand` and `right_hand` image files

### Analyze Palmistry
- **POST** `/palmistry/analyze`
- Headers: `Authorization: Bearer {token}`
- Body:
```json
{
  "palmistry_id": 123,
  "notes": "string (optional)"
}
```

### Get Palmistry List
- **GET** `/palmistry/list?page=1&limit=10`
- Headers: `Authorization: Bearer {token}`

---

## Numerology Endpoints

### Calculate Numerology
- **POST** `/numerology/calculate`
- Headers: `Authorization: Bearer {token}`
- Body:
```json
{
  "full_name": "string",
  "date_of_birth": "YYYY-MM-DD"
}
```

### Analyze Numerology
- **POST** `/numerology/analyze`
- Headers: `Authorization: Bearer {token}`
- Body:
```json
{
  "full_name": "string",
  "date_of_birth": "YYYY-MM-DD"
}
```

### Get Numerology List
- **GET** `/numerology/list?page=1&limit=10`
- Headers: `Authorization: Bearer {token}`

---

## Compatibility Endpoints

### Check Compatibility
- **POST** `/compatibility/check`
- Headers: `Authorization: Bearer {token}`
- Body (Option 1 - Using existing Kundalis):
```json
{
  "person1_kundali_id": 123,
  "person2_kundali_id": 456
}
```
- Body (Option 2 - Using birth details):
```json
{
  "person1_birth_details": {
    "name": "string",
    "date_of_birth": "YYYY-MM-DD",
    "time_of_birth": "HH:MM:SS",
    "place_of_birth": "string",
    "latitude": 0.0,
    "longitude": 0.0
  },
  "person2_birth_details": {
    "name": "string",
    "date_of_birth": "YYYY-MM-DD",
    "time_of_birth": "HH:MM:SS",
    "place_of_birth": "string",
    "latitude": 0.0,
    "longitude": 0.0
  }
}
```

### Get Compatibility List
- **GET** `/compatibility/list?page=1&limit=10`
- Headers: `Authorization: Bearer {token}`

---

## Report Endpoints

### Get Reports List
- **GET** `/reports/list?page=1&limit=10&service_type=kundali`
- Headers: `Authorization: Bearer {token}`
- Query Params: `service_type` (optional): kundali, palmistry, numerology, compatibility

### Get Report Details
- **GET** `/reports/{reportId}`
- Headers: `Authorization: Bearer {token}`

### Download Report PDF
- **GET** `/reports/{reportId}/download`
- Headers: `Authorization: Bearer {token}`
- Response: Binary PDF file

---

## Service Endpoints

### Get Services List
- **GET** `/services/list`
- Headers: `Authorization: Bearer {token}` (optional)

### Get Service Details
- **GET** `/services/{serviceId}`
- Headers: `Authorization: Bearer {token}` (optional)

---

## Order Endpoints

### Create Order
- **POST** `/orders/create`
- Headers: `Authorization: Bearer {token}`
- Body:
```json
{
  "service_id": 123,
  "additional_data": {
    "key": "value"
  }
}
```

### Get Orders List
- **GET** `/orders/list?page=1&limit=10`
- Headers: `Authorization: Bearer {token}`

### Get Order Details
- **GET** `/orders/{orderId}`
- Headers: `Authorization: Bearer {token}`

### Update Order Status
- **PUT** `/orders/{orderId}/status`
- Headers: `Authorization: Bearer {token}`
- Body: `{ "status": "pending|processing|completed|failed|cancelled" }`

---

## Notification Endpoints

### Get Notifications
- **GET** `/notifications?page=1&limit=20`
- Headers: `Authorization: Bearer {token}`

### Mark Notification as Read
- **PUT** `/notifications/{notificationId}/read`
- Headers: `Authorization: Bearer {token}`

### Get Unread Count
- **GET** `/notifications/unread-count`
- Headers: `Authorization: Bearer {token}`

---

## Profile Endpoints

### Get Profile
- **GET** `/profile`
- Headers: `Authorization: Bearer {token}`

### Update Profile
- **PUT** `/profile`
- Headers: `Authorization: Bearer {token}`
- Body:
```json
{
  "name": "string",
  "phone": "string",
  "date_of_birth": "YYYY-MM-DD",
  "address": "string"
}
```

---

## Response Format

### Success Response
```json
{
  "success": true,
  "message": "Success message",
  "data": {
    // Response data
  }
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error message",
  "errors": {
    "field": ["error message"]
  }
}
```

---

## Status Codes

- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `422` - Validation Error
- `500` - Internal Server Error

---

## Testing Notes

**ALL SERVICES ARE CURRENTLY SET TO FREE (₹0) FOR TESTING**

Original prices (will be controlled by admin backend):
- Free Kundali: ₹0 (always free)
- AI Kundali Analysis: ₹499
- Palmistry Reading: ₹299
- Numerology Report: ₹199
- Marriage Compatibility: ₹399

---

## Authentication

Most endpoints require authentication. Include the JWT token in the Authorization header:

```
Authorization: Bearer {your_jwt_token}
```

Tokens expire after 15 minutes. Use the refresh token endpoint to get a new access token.

---

## Rate Limiting

- 100 requests per minute per user
- 1000 requests per hour per user

---

## Pagination

List endpoints support pagination:
- `page`: Page number (default: 1)
- `limit`: Items per page (default: 10, max: 100)

Response includes:
```json
{
  "data": {
    "items": [],
    "pagination": {
      "current_page": 1,
      "total_pages": 10,
      "total_items": 100,
      "per_page": 10
    }
  }
}
```

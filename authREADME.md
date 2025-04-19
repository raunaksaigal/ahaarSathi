# API Usage Guide with Djoser Authentication

## Authentication Endpoints

### Registration

```
POST auth/users/
Content-Type: application/json

{
  "username": "newuser",
  "email": "user@example.com",
  "password": "ComplexPassword123",
  "re_password": "ComplexPassword123"
}
```

### Login (JWT Token)

```
POST auth/jwt/create/
Content-Type: application/json

{
  "username": "newuser",
  "password": "ComplexPassword123"
}
```

Response:

```json
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}
```

### Refresh Token

```
POST auth/jwt/refresh/
Content-Type: application/json

{
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}
```

### Get Current User Details

```
GET auth/users/me/
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
```

### Change Password

```
POST auth/users/set_password/
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
Content-Type: application/json

{
  "current_password": "ComplexPassword123",
  "new_password": "NewComplexPassword456",
  "re_new_password": "NewComplexPassword456"
}
```

## Using Authentication Tokens

For all API requests, include the token in the Authorization header:

```
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
```

## User Profile Endpoints

### Get User Details

```
GET users/me/
Authorization: Bearer {token}
```

### Update User Profile

```
PATCH users/profile/
Authorization: Bearer {token}
Content-Type: application/json

{
  "bio": "I am a photography enthusiast"
}
```

## Data API Endpoints

### Submit Data (with authentication)

```
POST data/submit/
Authorization: Bearer {token}
Content-Type: application/json

{
  "data": {
    "name": "Example Data",
    "value": 42,
    "properties": {
      "category": "test",
      "tags": ["sample", "example"]
    }
  }
}
```

Response includes user information:

```json
{
  "id": 1,
  "user": {
    "id": 1,
    "username": "newuser",
    "email": "user@example.com",
    "first_name": "",
    "last_name": "",
    "profile": {
      "id": 1,
      "bio": "I am a photography enthusiast",
      "profile_image": null,
      "date_joined": "2025-04-19T12:34:56.789Z"
    }
  },
  "data": {
    "name": "Example Data",
    "value": 42,
    "properties": {
      "category": "test",
      "tags": ["sample", "example"]
    }
  },
  "timestamp": "2025-04-19T12:34:56.789Z"
}
```

### Get User's Data Entries

```
GET data/my-data/
Authorization: Bearer {token}
```

### Filter Data by Date Range (only user's data)

```
GET data/list/?start_date=2025-04-01&end_date=2025-04-19
Authorization: Bearer {token}
```

## Image API Endpoints

### Upload Image (with authentication)

```
POST images/upload/
Authorization: Bearer {token}
Content-Type: multipart/form-data

image: [binary image file]
```

Response:

```json
{
  "id": 1,
  "user": {
    "id": 1,
    "username": "newuser",
    "email": "user@example.com",
    "first_name": "",
    "last_name": "",
    "profile": {
      "id": 1,
      "bio": "I am a photography enthusiast",
      "profile_image": null,
      "date_joined": "2025-04-19T12:34:56.789Z"
    }
  },
  "image": "/media/images/abc123.jpg",
  "image_url": "http://localhost:8000/media/images/abc123.jpg",
  "timestamp": "2025-04-19T12:34:56.789Z",
  "prediction": "cat",
  "prediction_id": "550e8400-e29b-41d4-a716-446655440000",
  "prediction_detail": {
    "class": "cat",
    "confidence": 0.92
  }
}
```

### Submit Prediction Feedback

```
POST images/feedback/
Authorization: Bearer {token}
Content-Type: application/json

{
  "image": 1,
  "feedback_data": {
    "correct": true,
    "user_label": "cat",
    "comments": "Good prediction!"
  }
}
```

### Get User's Images

```
GET images/my-images/
Authorization: Bearer {token}
```

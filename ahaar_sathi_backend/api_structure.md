# AhaarSathi Django Backend API Structure

This document outlines the API structure needed for the AhaarSathi calorie tracker mobile application.

## API Endpoints

### User Management

```
GET /api/users/{user_id}/
POST /api/users/
PUT /api/users/{user_id}/
```

Example Response:
```json
{
  "id": "1",
  "name": "John Doe",
  "age": 30,
  "height": 175.0,
  "weight": 70.0,
  "gender": "Male",
  "daily_calorie_target": 2000,
  "daily_water_target": 2000
}
```

### Food Entries

```
GET /api/users/{user_id}/food/
GET /api/users/{user_id}/food/?date=YYYY-MM-DD
POST /api/users/{user_id}/food/
```

Example Response:
```json
[
  {
    "id": "123",
    "name": "Paneer Butter Masala",
    "calories": 450,
    "image_url": "http://your-server.com/media/food_images/paneer.jpg",
    "timestamp": "2023-04-19 14:30:00",
    "meal_type": "Lunch",
    "nutrition_info": {
      "carbs": 30,
      "protein": 15,
      "fat": 25
    }
  }
]
```

### Water Entries

```
GET /api/users/{user_id}/water/
GET /api/users/{user_id}/water/?date=YYYY-MM-DD
POST /api/users/{user_id}/water/
```

Example Response:
```json
[
  {
    "id": "456",
    "amount": 250,
    "timestamp": "2023-04-19 10:30:00"
  }
]
```

### Food Image Upload and Recognition

```
POST /api/users/{user_id}/food/image-upload/
POST /api/food-recognition/
```

Example Response for Image Upload:
```json
{
  "image_url": "http://your-server.com/media/food_images/image123.jpg"
}
```

Example Response for Food Recognition:
```json
{
  "name": "Chole Bhature",
  "calories": 650,
  "nutrition_info": {
    "carbs": 80,
    "protein": 22,
    "fat": 30
  }
}
```

### Dashboard Data

```
GET /api/users/{user_id}/dashboard/
```

Example Response:
```json
{
  "daily_summary": {
    "date": "2023-04-19",
    "total_calories": 1850,
    "total_water": 1500,
    "calorie_target": 2000,
    "water_target": 2000
  },
  "weekly_summary": {
    "start_date": "2023-04-13",
    "end_date": "2023-04-19",
    "days": [
      {
        "date": "2023-04-13",
        "calories": 1750
      },
      {
        "date": "2023-04-14",
        "calories": 1900
      }
      // ... other days
    ]
  },
  "monthly_summary": {
    "month": "April 2023",
    "average_daily_calories": 1820,
    "total_water": 45000
  }
}
```

## Models

### User Model
- id (UUID)
- name (String)
- age (Integer)
- height (Float, cm)
- weight (Float, kg)
- gender (String)
- daily_calorie_target (Integer)
- daily_water_target (Integer, ml)

### FoodEntry Model
- id (UUID)
- user (ForeignKey to User)
- name (String)
- calories (Integer)
- image_url (String)
- timestamp (DateTime)
- meal_type (String) - breakfast, lunch, dinner, snack
- nutrition_info (JSON) - protein, carbs, fat, etc.

### WaterEntry Model
- id (UUID)
- user (ForeignKey to User)
- amount (Integer, ml)
- timestamp (DateTime)

## Implementation Notes

1. **Django Project Setup**:
   - Django REST Framework for API
   - PostgreSQL for database
   - JWT for authentication

2. **Food Recognition**:
   - TensorFlow or another ML framework for food recognition
   - Pre-trained model for recognizing common Indian foods
   - Custom training for Indian dishes not in standard models

3. **Deployment**:
   - Docker for containerization
   - Nginx as reverse proxy
   - Gunicorn as WSGI server

4. **Security Considerations**:
   - HTTPS for all API calls
   - Rate limiting to prevent abuse
   - Input validation for all endpoints 
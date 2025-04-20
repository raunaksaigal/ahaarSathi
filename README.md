# Ahaar Saathi - Indian Calorie Tracker App

[![Flutter](https://img.shields.io/badge/Flutter-3.7.0-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.7.0-blue.svg)](https://dart.dev)
[![Python](https://img.shields.io/badge/Python-3.9+-blue.svg)](https://www.python.org)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.68.0-green.svg)](https://fastapi.tiangolo.com)
[![YOLOv8](https://img.shields.io/badge/YOLOv8-8.0.0-red.svg)](https://github.com/ultralytics/ultralytics)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Ahaar Saathi is a comprehensive nutrition tracking application designed specifically for Indian cuisine. It helps users track their daily calorie intake, monitor nutritional values, and maintain a healthy diet.

## Project Structure

```
ahaar_saathi/
├── ahaar_sathi/          # Flutter Frontend
├── backend/              # FastAPI Backend
└── ml_model/            # Machine Learning Models
```

## Prerequisites

### Frontend
- Flutter SDK (^3.7.0)
- Dart SDK (^3.7.0)
- Android Studio / VS Code with Flutter extensions
- Android SDK / iOS development tools

### Backend
- Python 3.9+
- pip (Python package manager)
- Virtual environment (recommended)

## Setup Instructions

### Frontend Setup

1. Navigate to the frontend directory:
   ```bash
   cd ahaar_sathi
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Update the API base URL:
   - Open `lib/services/api_services.dart`
   - Update the `baseUrl` variable with your local IP address:
     ```dart
     const String baseUrl = 'http://YOUR_LOCAL_IP:8000';
     ```

4. Run the application:
   ```bash
   flutter run
   ```

### Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Create and activate a virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

4. Start the backend server:
   ```bash
   uvicorn main:app --reload
   ```

## Key Features

- Indian food database with accurate nutritional information
- Daily calorie tracking
- Meal planning and scheduling
- Nutritional insights and recommendations
- User authentication and profile management
- Food image recognition using ML models

## Dependencies

### Frontend
- flutter: ^3.7.0
- http: ^1.1.0
- provider: ^6.1.1
- fl_chart: ^0.66.1
- intl: ^0.18.1
- camera: ^0.10.5+9
- path_provider: ^2.1.2
- shared_preferences: ^2.2.2
- image_picker: ^1.0.4
- table_calendar: ^3.0.9
- google_fonts: ^6.2.1
- flutter_secure_storage: ^9.0.0

### Backend
- FastAPI
- SQLAlchemy
- Pydantic
- Uvicorn
- Python-jose
- Passlib
- Python-multipart
- Pillow
- TensorFlow
- NumPy

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Indian Food Database
- Nutrition Analysis API
- Machine Learning Models for Food Recognition 
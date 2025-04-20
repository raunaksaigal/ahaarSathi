# AhaarSathi App Summary

AhaarSathi is a Flutter-based mobile application designed specifically for tracking calorie intake with a focus on Indian cuisine. The name combines "Aahaar" (food in Hindi) and "Sathi" (companion), representing a food companion for healthy eating.

## Architecture Overview

The application follows a clean architecture approach with the following components:

### Front-end (Flutter)
- **Models**: Data structures for User, FoodEntry, and WaterEntry
- **Providers**: State management using Provider pattern
- **Screens**: UI screens for different app functionalities
- **Widgets**: Reusable UI components
- **Services**: API communication layer

### Back-end (Django - to be implemented)
- RESTful API for data storage and retrieval
- Food recognition using machine learning
- User authentication and authorization
- Detailed in `api_structure.md`

## Key Components

### Models
- **User**: Contains user profile data such as name, age, height, weight, gender, and targets for calorie and water intake
- **FoodEntry**: Represents a food item consumed by the user, including name, calories, image, timestamp, meal type, and nutrition info
- **WaterEntry**: Tracks water intake with amount and timestamp

### Providers
- **UserProvider**: Manages user state and operations
- **NutritionProvider**: Handles food and water entries, and dashboard data

### Screens
1. **HomeScreen**: Main dashboard showing calorie and water intake summaries
2. **LogsScreen**: Calendar view of food entries
3. **FoodLoggingScreen**: Interface for adding food entries via camera or manual input
4. **GoalsScreen**: Settings for personal calorie and water intake targets
5. **ProfileScreen**: User profile management

### Widgets
- **DonutChart**: Circular progress indicator for visualizing goals vs. actual intake
- **FoodCard**: Card component for displaying food entries
- **AhaarSathiAppBar**: Custom app bar for consistent UI
- **AhaarSathiBottomNavBar**: Navigation bar with tabs for different sections

### Services
- **ApiService**: Handles all communications with the backend API

## Features

1. **Daily Summary**: Visual representation of daily calorie and water intake
2. **Food Logging**: Two methods to log food:
   - Taking a picture for automatic identification
   - Manual entry with customization options
3. **History Tracking**: Calendar view to browse past entries
4. **Goal Setting**: Customizable targets for daily calorie and water intake
5. **Profile Management**: Easy editing of personal information

## Technology Stack

- **Front-end**: Flutter/Dart
- **State Management**: Provider pattern
- **Charting**: fl_chart package for data visualization
- **Calendar**: table_calendar for date navigation
- **Camera Integration**: camera and image_picker packages
- **Data Persistence**: shared_preferences for local storage
- **HTTP Client**: http package for API communication

## Project Structure

```
lib/
├── models/
│   ├── user.dart
│   ├── food_entry.dart
│   └── water_entry.dart
├── providers/
│   ├── user_provider.dart
│   └── nutrition_provider.dart
├── screens/
│   ├── home_screen.dart
│   ├── logs_screen.dart
│   ├── food_logging_screen.dart
│   ├── goals_screen.dart
│   └── profile_screen.dart
├── services/
│   └── api_service.dart
├── utils/
│   └── (utility functions)
├── widgets/
│   ├── donut_chart.dart
│   ├── food_card.dart
│   ├── app_bar.dart
│   └── bottom_nav_bar.dart
└── main.dart
```

## Future Enhancements

1. **Authentication**: Implement user authentication and account creation
2. **Offline Support**: Enhance offline capability with local database
3. **Personalized Recommendations**: Suggest meals based on user preferences and nutritional needs
4. **Social Features**: Share progress and recipes with friends
5. **Advanced Analytics**: More detailed insights into nutritional patterns
6. **Multi-language Support**: Add support for Indian regional languages
7. **Food Database**: Comprehensive database of Indian foods with nutritional information

The AhaarSathi app provides a user-friendly interface for tracking nutrition with special attention to Indian dietary habits and cultural context. 
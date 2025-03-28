# Trailblaze - Frontend

Trailblaze is a hiking app that allows users to explore, create, and share trails with the community. This repository contains the frontend, built using **Flutter**, for cross-platform support.

## Features
- User authentication (Hikers & Emergency Responders)
- Trail creation & annotation with markers
- Community features (reviews, ratings, user profiles, real-time trail updates)
- Emergency response functionalities (SOS requests, live location sharing)
- Weather-based recommendations using OpenWeatherMap API
- Premium features (offline maps, advanced live location sharing)

## Tech Stack
- **Flutter** (Dart)
- **Supabase** (Direct SDK communication for user profiles, SOS, pictures, and trail coordinates)
- **Mapbox SDK** (for retrieving and displaying maps)
- **Node.js with Express.js** (Backend API for authentication, trail details, and user management)
- **Docker** (for containerized deployment)

## Compatibility
- **Android**: Supported on Android 12 and up
- **iOS**: Not available yet

## Setup Instructions

### Prerequisites
- Flutter SDK (latest stable version) - [Install Flutter](https://flutter.dev/docs/get-started/install)
- Dart
- Android Studio or VS Code with Flutter extension
- Supabase account (for database and authentication handling)

### Installation
1. Clone the repository:
   ```sh
   git clone https://github.com/yourusername/trailblaze-frontend.git
   cd trailblaze-frontend
   ```
2. Install dependencies:
   ```sh
   flutter pub get
   ```
3. Create a `.env` file in the root directory and add required API keys:
   ```env
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   WEATHER_API_KEY=your_openweathermap_api_key
   ```
4. Run the application:
   ```sh
   flutter run
   ```

## Contribution Guidelines
1. Fork the repository.
2. Create a new feature branch: `git checkout -b feature-name`
3. Commit changes and push to your branch.
4. Submit a pull request.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## License
This project is licensed under the MIT License.

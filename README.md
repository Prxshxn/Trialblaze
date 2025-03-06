# Trail Tracker App

A trail navigation and sharing application with user profiles, similar to AllTrails.

## Project Structure

```
trail-tracker/
├── lib/               # Flutter frontend
├── backend/           # Node.js backend
└── pubspec.yaml       # Flutter dependencies
```

## Setup Instructions

### Frontend (Flutter)

1. Install Flutter and set up your development environment
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the app

### Backend (Node.js)

1. Navigate to the backend directory: `cd backend`
2. Install dependencies: `npm install`
3. Create a `.env` file with your MongoDB connection string
4. Start the server: `npm run dev`

## Features

- User profile with cover photo and profile picture
- Follower and following count
- Stats tracking (miles hiked, time spent)
- Feed, photos, and reviews tabs (placeholder)

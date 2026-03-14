# Todo List and Clock App

## Project Overview

This is a Flutter application that combines a todo list with a clock feature, built with modern Flutter practices. The app provides a clean and intuitive UI with cross-platform support for Android, iOS, Web, Linux, macOS, and Windows.

The application features:
- Todo list functionality to manage tasks
- Pomodoro timer functionality for focus sessions
- Responsive UI that adapts to different screen sizes
- Dark/light theme support
- SQLite database integration for data persistence
- Music player interface during focus sessions

## Project Structure

```
lib/
├── main.dart          # Main entry point with navigation rail
├── enums/             # Enum definitions
├── models/            # Data models (Task, Pomodoro)
├── pages/             # UI screens (TodoPage, FocusPage)
├── providers/         # State management (TodoProvider)
├── utils/             # Utility functions (DatabaseHelper, ScreenDisplay)
└── widgets/           # Reusable UI components (TaskCard, PomodoroTimer)
```

## Building and Running

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK (bundled with Flutter)
- Platform-specific development tools (Android Studio, Xcode, etc.)

### Installation
1. Clone the repository:
```bash
git clone <repository-url>
cd todo_list_and_clock
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run
```

### Build for Production
To build for production, use the appropriate command for your target platform:

```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

## Key Features

### Focus Page (foucs_page.dart)
The application includes a responsive Focus Page that implements a Pomodoro timer with music player functionality:
- **Responsive Layout**: Adapts between desktop (side-by-side layout) and mobile (vertical stacked layout) views
- **Focus Timer**: Implements a Pomodoro technique with configurable focus and rest periods
- **Music Player**: Includes play/pause, previous, and next controls during focus sessions
- **Visual Elements**: Features song information card with simulated night sky imagery, progress indicators, and control buttons
- **Data Persistence**: Saves completed and interrupted Pomodoro sessions to the database

### State Management
The application uses the Provider package for state management, with TodoProvider managing the list of tasks.

### Theming
The app supports both light and dark themes with Material Design 3 components and uses the Noto Sans SC font for Chinese character support.

## Development Conventions

- Uses Material Design 3 guidelines
- Follows Flutter's recommended project structure
- Implements responsive design principles
- Uses Provider for state management
- Includes proper database handling with sqflite
- Implements proper resource disposal patterns

## Dependencies

- flutter: SDK
- path: ^1.9.1
- shared_preferences: ^2.5.4
- sqflite: ^2.4.2
- sqflite_common_ffi: ^2.3.7+1 (for desktop platforms)
- provider: ^6.1.2

## Testing

Unit and widget tests can be run using:
```bash
flutter test
```

## Additional Notes

The application has platform-specific initialization for desktop platforms in the main.dart file, initializing the TaskDatabaseFactory for Windows, Linux, and macOS.
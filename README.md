# Todo List and Clock App

A Flutter application that combines a todo list with a clock feature, built with modern Flutter practices.

## Features

- Todo list functionality to manage tasks
- Clock display
- Clean and intuitive UI
- Cross-platform support (Android, iOS, Web, Linux, macOS, Windows)

## Project Structure

```
lib/
├── main.dart          # Main entry point
├── models/            # Data models
├── pages/             # UI screens
├── utils/             # Utility functions
└── widgets/           # Reusable UI components
```

## Getting Started

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

## Development

### Code Generation

This project uses standard Flutter development patterns. New pages, models, and widgets can be added to their respective directories.

### Assets

Assets such as fonts and images are stored in the `assets/` directory.

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

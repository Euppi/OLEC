# OLEC - Event Discovery App

OLEC is an iOS app that helps users discover and join events happening around them in real-time. The app uses location-based services, AI-driven recommendations, and social features to create a seamless event discovery experience.

## Features

- 🗺️ Real-time event discovery based on location
- 👥 Social networking and chat functionality
- 🎯 Personalized event recommendations
- 📅 Event creation and management
- 🔔 Push notifications for event updates
- 🎨 Modern SwiftUI interface
- 📱 Native iOS experience

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.0+
- CocoaPods or Swift Package Manager
- Firebase account
- Google Maps API key

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/olec.git
cd olec
```

2. Install XcodeGen if you haven't already:
```bash
brew install xcodegen
```

3. Generate the Xcode project:
```bash
xcodegen generate
```

4. Open the project in Xcode:
```bash
open OLEC.xcodeproj
```

5. Set up Firebase:
   - Create a new Firebase project
   - Add your iOS app to the project
   - Download the `GoogleService-Info.plist` file
   - Add it to the project root

6. Set up environment variables:
   - Create a `.env` file in the project root
   - Add your development team ID:
     ```
     DEVELOPMENT_TEAM=YOUR_TEAM_ID
     ```

7. Build and run the project in Xcode

## Project Structure

```
OLEC/
├── Sources/
│   ├── App/
│   │   ├── OLECApp.swift
│   │   └── ContentView.swift
│   ├── Features/
│   │   ├── Discover/
│   │   ├── Events/
│   │   ├── Chat/
│   │   └── Profile/
│   ├── Core/
│   │   ├── Models/
│   │   ├── Networking/
│   │   └── Location/
│   └── UI/
│       ├── Components/
│       └── Styles/
├── Resources/
│   ├── Assets.xcassets/
│   └── LaunchScreen.storyboard
└── project.yml
```

## Architecture

The app follows a clean architecture pattern with MVVM:

- **Models**: Core data structures
- **Views**: SwiftUI views
- **ViewModels**: Business logic and state management
- **Services**: Network, location, and other system services

## Development Workflow

1. Create a new feature branch:
```bash
git checkout -b feature/your-feature-name
```

2. Implement the feature following the MVVM pattern
3. Write unit tests for the ViewModel
4. Create a pull request for review

## Testing

Run the tests in Xcode:
- ⌘U to run all tests
- ⌘⌥U to run specific tests

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [SwiftUI](https://developer.apple.com/xcode/swiftui/)
- [Firebase](https://firebase.google.com)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)

## Contact

For any questions or feedback, please contact:
- Email: contact@olec.app
- Twitter: [@olecapp](https://twitter.com/olecapp) 
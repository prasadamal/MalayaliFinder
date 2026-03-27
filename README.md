# 🌴 MalayaliFinder

> **Find your Mallu tribe** — A cross-platform Flutter app for Android & iOS that helps Malayalees discover each other wherever they are in the world.

---

## ✨ Features

### 📡 Radar (Main Highlight)
- Animated radar that sweeps and plots nearby Malayalees as glowing dots
- Toggle ON/OFF with one button
- Adjustable detection range: 1 km · 5 km · 10 km · 25 km · 50 km
- Verified Malayalees shown in bright green; unverified in amber
- Live user count and distance display

### 🗺 Map View (OpenStreetMap — Free, No API Key)
- Nearby Malayalees shown as map markers
- Upcoming events shown as category-icon markers
- Filter toggles for Users / Events
- Tap a user marker to see their profile bottom sheet
- "Locate Me" button to re-centre the map

### 🎉 Event Planner
- Browse upcoming Malayalee meetups (food, sports, cultural, music, travel)
- Create events with title, description, category, location, date/time, and max participants
- **Minimum 3 participants required** — events are auto-cancelled if not met
- Join / Leave events; progress bar shows spots filled
- My Events tab for personal event management
- Real-time participant count and "spots left" display

### 🧠 Malayalee Verification Quiz
- 10-question Kerala knowledge quiz (culture, language, geography, festivals)
- Need **7/10 correct** to earn the verified badge
- Verified users get a green badge on the radar and map
- Re-take anytime from the Profile screen

### 👤 Profile
- Personal info: name, home district, current city
- Verification status badge
- Points system for engagement
- Feature overview

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.0.0
- Android Studio / Xcode
- Android device/emulator (API 21+) or iOS device/simulator (iOS 12+)

### Installation

```bash
# Clone the repo
git clone https://github.com/prasadamal/MalayaliFinder.git
cd MalayaliFinder

# Install dependencies
flutter pub get

# Run on Android
flutter run

# Run on iOS
flutter run --device-id <your-ios-device>

# Build release APK
flutter build apk --release

# Build iOS IPA
flutter build ipa --release
```

### Required Permissions
| Permission | Purpose |
|---|---|
| `ACCESS_FINE_LOCATION` | Radar & map centering |
| `INTERNET` | OpenStreetMap tiles |
| `CAMERA` | Profile photo |
| `NSLocationWhenInUseUsageDescription` | iOS location prompt |

---

## 🏗 Project Structure

```
lib/
├── main.dart                    # App entry point & theme
├── models/
│   ├── user_model.dart          # User data & distance calculation
│   ├── event_model.dart         # Event data with min-participant logic
│   └── questionnaire_model.dart # Kerala verification questions
├── providers/
│   ├── user_provider.dart       # Current user, radar, nearby users
│   ├── location_provider.dart   # GPS tracking
│   └── events_provider.dart     # Events CRUD & auto-cancel logic
├── screens/
│   ├── splash_screen.dart       # Animated splash → routing
│   ├── onboarding_screen.dart   # Name / District / City setup
│   ├── home_screen.dart         # Bottom nav scaffold
│   ├── radar_screen.dart        # 📡 MAIN: animated radar
│   ├── map_screen.dart          # OpenStreetMap view
│   ├── events_screen.dart       # Event list (All / My Events)
│   ├── create_event_screen.dart # Event creation form
│   ├── event_detail_screen.dart # Event detail + join/leave
│   ├── profile_screen.dart      # User profile
│   └── questionnaire_screen.dart# Kerala verification quiz
├── widgets/
│   ├── radar_widget.dart        # CustomPainter radar animation
│   └── event_card.dart          # Event list card with join button
└── utils/
    ├── app_colors.dart          # Brand colour palette
    └── constants.dart           # App-wide constants
```

---

## 📦 Key Dependencies

| Package | Purpose |
|---|---|
| `flutter_map` | Free OpenStreetMap integration |
| `latlong2` | Lat/lon coordinate handling |
| `geolocator` | GPS location services |
| `provider` | State management |
| `shared_preferences` | Local user data persistence |
| `uuid` | Unique ID generation |
| `intl` | Date/time formatting |
| `image_picker` | Profile photo selection |

> **No Google Maps API key required** — the app uses OpenStreetMap tiles via `flutter_map`.

---

## 🎨 Design

- Deep Kerala-green and night-blue dark theme
- Radar green accent (`#00E676`) for verified Malayalees
- Warm saffron (`#FF6F00`) for events and categories
- Fully dark UI optimised for night-time use

---

## 🔜 Roadmap

- [ ] Firebase Firestore for real-time user/event sync
- [ ] Push notifications for event reminders
- [ ] In-app chat between nearby Malayalees
- [ ] Malayalam language UI option
- [ ] Community leaderboard by city

---

## 📄 License

MIT © 2024 MalayaliFinder Contributors

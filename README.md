# NutriPal

NutriPal is a SwiftUI-based iOS app for tracking daily nutrition, logging meals, and visualizing macro/micronutrient intake trends. It integrates with FatSecret for food data and HealthKit for health data access.

## Features

- **Dashboard:** View daily macro and micronutrient progress with visual bars.
- **Meal Log:** Log foods for each meal (breakfast, lunch, dinner, snacks) and review your daily intake.
- **Food Search:** Search for foods using the FatSecret API, view detailed nutrition facts, and add them to your log.
- **History:** Visualize your nutrition history with calendar selection, nutrient summaries, and trend graphs.
- **Settings:** Edit personal details (weight, height, birthday, gender), adjust macro goals, and manage preferences.
- **Auto Goal Calculation:** Automatically generate macro goals based on your profile.
- **HealthKit Integration:** Request permissions to sync nutrition data with Apple Health.

## Project Structure

```
NutriPal/
├── ContentView.swift
├── NutriPalApp.swift
├── Assets.xcassets/
├── Models/
├── Persistence/
├── Services/
├── ViewModels/
├── Views/
└── ...
```

- **Models/**: Data models (e.g., `FoodItem`, `LoggedFood`, `UserProfile`)
- **Persistence/**: Data persistence logic ([`PersistenceManager`](NutriPal/Persistence/PersistenceManager.swift))
- **Services/**: API integrations ([`FatSecretAPI`](NutriPal/Services/FatSecretAPI.swift), [`HealthKitManager`](NutriPal/Services/HealthKitManager.swift))
- **ViewModels/**: State management for views
- **Views/**: SwiftUI views for all app screens

## Getting Started

1. **Clone the repository:**
   ```sh
   git clone https://github.com/yourusername/NutriPal.git
   cd NutriPal
   ```

2. **Open in Xcode:**
   - Open `NutriPal.xcodeproj` in Xcode.

3. **FatSecret API Setup:**
   - Register for a FatSecret developer account.
   - Add your `clientId` and `clientSecret` in [`FatSecretAPI`](NutriPal/Services/FatSecretAPI.swift).

4. **Build and Run:**
   - Select a simulator or device and run the app.

## Dependencies

- SwiftUI (iOS 16+ recommended for best experience)
- [Charts](https://developer.apple.com/documentation/charts) (for trends visualization, iOS 16+)
- HealthKit (for health data integration)


---

**Note:** This app is for educational and personal use. Always consult a professional for dietary

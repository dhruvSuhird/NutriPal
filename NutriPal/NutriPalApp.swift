import SwiftUI

@main
struct NutriPalApp: App {
    // Shared view models for the whole app
    @StateObject var mealLogVM = MealLogViewModel()
    @StateObject var dashboardVM = MacroDashboardViewModel(userProfile: UserProfile())
    @StateObject var userVM = UserProfileViewModel()
    @StateObject var historyVM = IntakeHistoryViewModel()
    @StateObject var profile = UserProfile()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(mealLogVM)
                .environmentObject(dashboardVM)
                .environmentObject(userVM)
                .environmentObject(historyVM)
                .environmentObject(profile)
        }
    }
}

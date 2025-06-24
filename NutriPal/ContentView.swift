import SwiftUI

struct ContentView: View {
    @EnvironmentObject var mealLogVM: MealLogViewModel
    @EnvironmentObject var dashboardVM: MacroDashboardViewModel
    @EnvironmentObject var userVM: UserProfileViewModel
    @EnvironmentObject var historyVM: IntakeHistoryViewModel

    var body: some View {
        TabView {
            NavigationStack {
                MacroDashboardView(dashboardVM: dashboardVM)
            }
            .tabItem {
                Label("Dashboard", systemImage: "house")
            }
            
            NavigationStack {
                MealLogView()
            }
            .tabItem {
                Label("Meal Log", systemImage: "fork.knife")
            }
            
            NavigationStack {
                FoodSearchView()
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }

            NavigationStack {
                HistoryView()
            }
            .tabItem {
                Label("History", systemImage: "calendar")
            }
            
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
        }
        .onAppear {
            // Initial loading and cross-VM updates
            mealLogVM.load()
//            dashboardVM.updateLoggedFoods(mealLogVM.loggedFoods)
            historyVM.load(from: mealLogVM.loggedFoods)
        }
        .onChange(of: mealLogVM.loggedFoods) { newLoggedFoods in
//            dashboardVM.updateLoggedFoods(newLoggedFoods)
            historyVM.load(from: newLoggedFoods)
        }
        .tint(Color(hex: "#2a477a"))
    }
}

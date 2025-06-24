import SwiftUI

struct MacroDashboardView: View {
    @ObservedObject var dashboardVM: MacroDashboardViewModel
    @EnvironmentObject var mealLogVM: MealLogViewModel
    @EnvironmentObject var profile: UserProfile
    
    let barColor = Color(hex: "#2a477a")
    
    var todayFoods: [LoggedFood] {
        mealLogVM.foods(on: Date())
    }
    
    // Macro totals
    var totalCalories: Double { todayFoods.reduce(0) { $0 + $1.food.calories * Double($1.servings) } }
    var totalProtein: Double { todayFoods.reduce(0) { $0 + $1.food.protein * Double($1.servings) } }
    var totalCarbs: Double { todayFoods.reduce(0) { $0 + $1.food.carbs * Double($1.servings) } }
    var totalFat: Double { todayFoods.reduce(0) { $0 + $1.food.fats * Double($1.servings) } }
    var totalSugar: Double { todayFoods.reduce(0) { $0 + $1.food.sugar * Double($1.servings) } }
    var totalSodium: Double { todayFoods.reduce(0) { $0 + $1.food.sodium * Double($1.servings) } }
    var totalCalcium: Double { todayFoods.reduce(0) { $0 + $1.food.calcium * Double($1.servings) } }

    var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Daily Goals")
                        .font(.title3)
                        .bold()
                        .padding(.top, 12)

                    // Progress bars for each nutrient
                    MacroBar(title: "Calories",
                             value: totalCalories,
                             goal: Double(profile.calorieGoal),
                             unit: "kcal"
                             )
                    MacroBar(title: "Protein",
                             value: totalProtein,
                             goal: Double(profile.proteinGoal),
                             unit: "g"
                             )
                    MacroBar(title: "Carbs",
                             value: totalCarbs,
                             goal: Double(profile.carbGoal),
                             unit: "g"
                             )
                    MacroBar(title: "Fat",
                             value: totalFat,
                             goal: Double(profile.fatGoal),
                             unit: "g"
                             )
                    MacroBar(title: "Sugar",
                             value: totalSugar,
                             goal: Double(profile.sugarGoal),
                             unit: "g"
                             )
                    MacroBar(title: "Calcium",
                             value: totalCalcium,
                             goal: Double(profile.calciumGoal),
                             unit: "mg"
                             )

                    Text("Today's Food")
                        .font(.headline)
                        .padding(.top, 8)

                    let recentFoods = todayFoods.suffix(4).reversed()
                    if recentFoods.isEmpty {
                        Text("No foods logged.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else {
                        ForEach(recentFoods) { log in
                            DashboardFoodRow(log: log)
                        }
                    }
                    
                }
                .padding([.leading, .trailing])
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("NutriPal")
                        .font(.largeTitle.bold())
                }
            }
    }
}

// MARK: - MacroBar

struct MacroBar: View {
    let title: String
    let value: Double
    let goal: Double
    let unit: String
    
    let barColor = Color(hex: "#2a477a")

    var percent: Double {
        guard goal > 0 else { return 0 }
        return min(value / goal, 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .bold()
                Spacer()
                Text("\(Int(value))/\(Int(goal)) \(unit)")
                    .font(.subheadline)
            }
            ProgressView(value: percent)
                .accentColor(barColor)
                .frame(height: 6)
                .background(Color(.systemGray5))
                .cornerRadius(3)
        }
    }
}

// MARK: - DashboardFoodRow

struct DashboardFoodRow: View {
    let log: LoggedFood

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: systemImageName(for: log.mealType))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.gray)
                )
            VStack(alignment: .leading, spacing: 2) {
                Text("\(log.mealType.displayName): \(log.food.name)")
                    .font(.subheadline)
                Text("\(Int(log.food.calories)) kcal")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }

    func systemImageName(for meal: MealType) -> String {
        switch meal {
        case .breakfast: return "sunrise"
        case .lunch: return "fork.knife"
        case .dinner: return "moon.stars"
        case .snacks: return "takeoutbag.and.cup.and.straw"
        }
    }
}


// MARK: - Color Hex Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6: 
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: 1)
    }
}

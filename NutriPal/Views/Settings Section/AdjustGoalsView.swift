import SwiftUI

struct MacroBreakdown {
    let calories: Int
    let proteinGrams: Int
    let fatGrams: Int
    let carbGrams: Int
    let sugarLimitGrams: Int
    let calciumMg: Int
}

func recommendedSugarLimit(gender: Gender) -> Int {
    return gender == .male ? 36 : 25 // in grams
}

func recommendedCalciumIntake(age: Int) -> Int {
    switch age {
    case ..<19:
        return 1300
    case 19...50:
        return 1000
    default:
        return 1200
    }
}

func calculateMacros(
    weightKg: Int,
    heightCm: Int,
    age: Int,
    gender: Gender,
    activityLevel: Double = 1.55, // Moderately active
    goal: String = "maintain"
) -> MacroBreakdown {
    
    let bmr: Double
    switch gender {
    case .male:
        bmr = 10 * Double(weightKg) + 6.25 * Double(heightCm) - 5 * Double(age) + 5
    case .female:
        bmr = 10 * Double(weightKg) + 6.25 * Double(heightCm) - 5 * Double(age) - 161
    }
    
    var tdee = bmr * activityLevel
    
    switch goal.lowercased() {
    case "cut":
        tdee *= 0.8
    case "bulk":
        tdee *= 1.1
    default:
        break
    }
    
    
    let proteinGrams = Int(weightKg * 2)
    let proteinCalories = Double(proteinGrams) * 4
    let fatGrams = Int(Double(weightKg) * 0.9)
    let fatCalories = Double(fatGrams) * 9
    let remainingCalories = tdee - proteinCalories - fatCalories
    let carbGrams = Int(remainingCalories / 4)
    let sugarLimit = recommendedSugarLimit(gender: gender)
    let calcium = recommendedCalciumIntake(age: age)
    return MacroBreakdown(
        calories: Int(tdee.rounded()),
        proteinGrams: proteinGrams,
        fatGrams: fatGrams,
        carbGrams: carbGrams,
        sugarLimitGrams: sugarLimit,
        calciumMg: calcium
    )
}

struct AdjustGoalsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var profile: UserProfile

    var onSave: ((Int, Int, Int, Int) -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Circle()
                        .fill(Color(.systemGray6))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "chevron.left")
                                .foregroundColor(.black)
                                .font(.system(size: 20, weight: .semibold))
                        )
                }
                Text("Adjust goals")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.leading, 8)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 18)
            .padding(.bottom, 24)

            VStack(spacing: 20) {
                GoalCardView(
                    icon: "flame.fill",
                    iconColor: .black,
                    title: "Calorie goal(kcal)",
                    value: $profile.calorieGoal
                )
                GoalCardView(
                    icon: "bolt.fill",
                    iconColor: Color(red: 1, green: 0.32, blue: 0.34),
                    title: "Protein goal(g)",
                    value: $profile.proteinGoal
                )
                GoalCardView(
                    icon: "leaf.fill",
                    iconColor: Color.orange,
                    title: "Carb goal(g)",
                    value: $profile.carbGoal
                )
                GoalCardView(
                    icon: "drop.fill",
                    iconColor: Color(red: 1.0, green: 0.84, blue: 0.0),
                    title: "Fat goal(g)",
                    value: $profile.fatGoal
                )
                GoalCardView(
                    icon: "cube.fill",
                    iconColor: Color(red: 1.0, green: 0.75, blue: 0.8),
                    title: "Sugar goal(g)",
                    value: $profile.sugarGoal
                )
                GoalCardView(
                    icon: "pill.fill",
                    iconColor: Color(red: 0.8, green: 0.9, blue: 1.0),
                    title: "Calcium goal(mg)",
                    value: $profile.calciumGoal
                )


            }
            .padding(.horizontal)

            Spacer()

            Button(action: {
                let macros = calculateMacros(
                    weightKg: profile.currentWeight,
                    heightCm: profile.height,
                    age: profile.age,
                    gender: profile.gender,
                    activityLevel: 1.55,
                    goal: "maintain"
                )
                profile.calorieGoal = macros.calories
                profile.proteinGoal = macros.proteinGrams
                profile.carbGoal = macros.carbGrams
                profile.fatGoal = macros.fatGrams
                profile.sugarGoal = macros.sugarLimitGrams
                profile.calciumGoal = macros.calciumMg
            }) {
                Text("Auto Generate Goals")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color.gray, lineWidth: 1.2)
                    )
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .background(Color(.systemBackground))
        .ignoresSafeArea(edges: .bottom)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .onDisappear {
            onSave?(profile.calorieGoal, profile.proteinGoal, profile.carbGoal, profile.fatGoal)
        }
    }
}

struct GoalCardView: View {
    var icon: String
    var iconColor: Color
    var title: String
    @Binding var value: Int
    
    // Use a static formatter to avoid recreating it every time
    static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color(.systemGray4), lineWidth: 6)
                    .frame(width: 56, height: 56)
                Image(systemName: icon)
                    .font(.system(size: 23, weight: .bold))
                    .foregroundColor(iconColor)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundColor(.secondary)
                TextField("", value: $value, formatter: GoalCardView.numberFormatter)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .keyboardType(.numberPad)
            }
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.systemGray6).opacity(0.3))
        )
    }
}

#Preview {
    AdjustGoalsView()
}

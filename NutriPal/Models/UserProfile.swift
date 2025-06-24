
import Foundation

enum Gender: String, CaseIterable, Identifiable {
    case male, female
    var id: String { rawValue }
}

final class UserProfile: ObservableObject{
    @Published var goalWeight: Int = 85
    @Published var currentWeight: Int = 85
    @Published var height: Int = 175
    @Published var dob: String = "23/09/2003"
    @Published var gender: Gender = .male
    var activityLevel: ActivityLevel = .moderatelyActive
    @Published var goal: WeightGoal = .maintain

    // Macro goals
    @Published var calorieGoal: Int = 2280
    @Published var proteinGoal: Int = 185
    @Published var carbGoal: Int = 242
    @Published var fatGoal: Int = 63
    @Published var sugarGoal: Int = 25
    @Published var calciumGoal: Int = 1000

    // Helpers
    var age: Int {
        let comps = dob.split(separator: "/")
        guard comps.count == 3,
            let day = Int(comps[0]), let month = Int(comps[1]), let year = Int(comps[2]) else { return 22 }
        let calendar = Calendar.current
        let birthDate = calendar.date(from: DateComponents(year: year, month: month, day: day)) ?? Date()
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: Date())
        return ageComponents.year ?? 0
    }
}


enum WeightGoal: String, CaseIterable, Codable {
    case gain, maintain, lose
}

enum ActivityLevel: Double, CaseIterable, Codable {
    case sedentary = 1.2
    case lightlyActive = 1.375
    case moderatelyActive = 1.55
    case veryActive = 1.725
    case extraActive = 1.9

    var label: String {
        switch self {
        case .sedentary: return "Sedentary"
        case .lightlyActive: return "Lightly Active"
        case .moderatelyActive: return "Moderately Active"
        case .veryActive: return "Very Active"
        case .extraActive: return "Extra Active"
        }
    }
}

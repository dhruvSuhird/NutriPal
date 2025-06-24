
import Foundation

enum MealType: String, CaseIterable, Identifiable, Codable {
    case breakfast, lunch, dinner, snacks
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .breakfast: return "Breakfast"
        case .lunch: return "Lunch"
        case .dinner: return "Dinner"
        case .snacks: return "Snacks"
        }
    }
}

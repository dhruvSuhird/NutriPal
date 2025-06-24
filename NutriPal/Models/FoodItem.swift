import Foundation

struct FoodItem: Identifiable, Codable {
    let id: String
    let name: String
    let servingDescription: String
    let protein: Double
    let carbs: Double
    let fats: Double
    let calories: Double
    let sugar: Double
    var sodium: Double
    var calcium: Double
}

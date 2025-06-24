import Foundation

struct LoggedFood: Identifiable, Codable, Equatable {
    static func == (lhs: LoggedFood, rhs: LoggedFood) -> Bool {
        lhs.id == rhs.id
    }

    let id: UUID
    let food: FoodItem
    let mealType: MealType
    let date: Date
    let servings: Int

    init(food: FoodItem, mealType: MealType, date: Date = Date(), servings: Int = 1) {
        self.id = UUID()
        self.food = food
        self.mealType = mealType
        self.date = Calendar.current.startOfDay(for: date)
        self.servings = servings
    }

    // Custom decoder for backward compatibility
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        food = try container.decode(FoodItem.self, forKey: .food)
        mealType = try container.decode(MealType.self, forKey: .mealType)
        date = try container.decode(Date.self, forKey: .date)
        servings = try container.decodeIfPresent(Int.self, forKey: .servings) ?? 1
    }
}

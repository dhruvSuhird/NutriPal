import Foundation

struct MacroHistoryDay: Identifiable {
    let id = UUID()
    let date: Date
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let sugar: Double
    let sodium: Double
    let calcium: Double
}

class IntakeHistoryViewModel: ObservableObject {
    @Published var history: [MacroHistoryDay] = []
    
        func load(from loggedFoods: [LoggedFood]) {
            let grouped = Dictionary(grouping: loggedFoods) { $0.date }
            history = grouped.map { (date, foods) in
                MacroHistoryDay(
                    date: date,
                    calories: foods.reduce(0) { $0 + $1.food.calories * Double($1.servings) },
                    protein: foods.reduce(0) { $0 + $1.food.protein * Double($1.servings) },
                    carbs: foods.reduce(0) { $0 + $1.food.carbs * Double($1.servings) },
                    fat: foods.reduce(0) { $0 + $1.food.fats * Double($1.servings) },
                    sugar: foods.reduce(0) { $0 + $1.food.sugar * Double($1.servings) },
                    sodium: foods.reduce(0) { $0 + $1.food.sodium * Double($1.servings) },
                    calcium: foods.reduce(0) { $0 + $1.food.calcium * Double($1.servings) }
                )
            }.sorted { $0.date > $1.date }
    }
}


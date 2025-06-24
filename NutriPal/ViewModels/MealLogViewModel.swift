import Foundation

class MealLogViewModel: ObservableObject {
    @Published var loggedFoods: [LoggedFood] = []
    
    func logFood(_ food: FoodItem, to mealType: MealType, on date: Date = Date(), servings: Int = 1) {
        let entry = LoggedFood(food: food, mealType: mealType, date: date, servings: servings)
        loggedFoods.append(entry)
        PersistenceManager.shared.saveLoggedFoods(loggedFoods)
    }
    
    func foods(for meal: MealType, on date: Date) -> [LoggedFood] {
        let day = Calendar.current.startOfDay(for: date)
        return loggedFoods.filter { $0.mealType == meal && $0.date == day }
    }
    
    func foods(on date: Date) -> [LoggedFood] {
        let day = Calendar.current.startOfDay(for: date)
        return loggedFoods.filter { Calendar.current.isDate($0.date, inSameDayAs: day) }
    }
    
    func load() {
        loggedFoods = PersistenceManager.shared.loadLoggedFoods()
    }
}

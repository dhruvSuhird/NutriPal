import Foundation

class UserProfileViewModel: ObservableObject {
    @Published var macroGoal: MacroGoal
    
    init() {
        self.macroGoal = PersistenceManager.shared.loadMacroGoal() ?? MacroGoal(calories: 2000, protein: 150, carbs: 200, fat: 60, sugar: 50, sodium: 2300, calcium: 1000)

    }
    
    func save() {
        PersistenceManager.shared.saveMacroGoal(macroGoal)
    }
}

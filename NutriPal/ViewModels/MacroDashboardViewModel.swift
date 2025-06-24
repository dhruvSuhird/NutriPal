import Foundation
import Combine

class MacroDashboardViewModel: ObservableObject {
    @Published var macroGoal: MacroGoal

    private var cancellables = Set<AnyCancellable>()

    init(userProfile: UserProfile) {
        self.macroGoal = MacroGoal(
            calories: Double(userProfile.calorieGoal),
            protein: Double(userProfile.proteinGoal),
            carbs: Double(userProfile.carbGoal),
            fat: Double(userProfile.fatGoal),
            sugar: 50,
            sodium: 2300,
            calcium: 1000
        )

        Publishers.CombineLatest4(
            userProfile.$calorieGoal,
            userProfile.$proteinGoal,
            userProfile.$carbGoal,
            userProfile.$fatGoal
        )
        .sink { [weak self] cal, pro, carb, fat in
            self?.macroGoal = MacroGoal(
                calories: Double(cal),
                protein: Double(pro),
                carbs: Double(carb),
                fat: Double(fat),
                sugar: 50,
                sodium: 2300,
                calcium: 1000
            )
        }
        .store(in: &cancellables)
    }
}

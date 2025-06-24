import Foundation

class FoodSearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var searchResults: [FoodItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var accessToken: String?
    
    func searchFoods() {
        guard !searchText.isEmpty else { return }
        isLoading = true
        FatSecretAPI.shared.searchFoods(query: searchText) { [weak self] result in
            DispatchQueue.main.async {
                self?.accessToken = FatSecretAPI.shared.accessToken
                switch result {
                case .success(let summaries):
                    // Fetch details for each summary and use the first serving
                    let group = DispatchGroup()
                    var items: [FoodItem] = []
                    for summary in summaries {
                        group.enter()
                        FatSecretAPI.shared.getFoodDetails(foodId: summary.id) { detailResult in
                            if case .success(let foodItem) = detailResult {
                                items.append(foodItem)
                            }
                            group.leave()
                        }
                    }
                    group.notify(queue: .main) {
                        self?.searchResults = items
                        self?.isLoading = false
                    }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.isLoading = false
                }
            }
        }
    }
    
    func fetchDetails(for foodId: String, completion: @escaping (FoodItem?) -> Void) {
        FatSecretAPI.shared.getFoodDetails(foodId: foodId) { result in
            DispatchQueue.main.async {
                self.accessToken = FatSecretAPI.shared.accessToken
                switch result {
                case .success(let foodItem):
                    completion(foodItem)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    completion(nil)
                }
            }
        }
    }
}

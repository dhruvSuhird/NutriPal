import SwiftUI

struct FoodSearchView: View {
    @StateObject var searchVM = FoodSearchViewModel()
    @EnvironmentObject var mealLogVM: MealLogViewModel
    @State private var selectedMeal: MealType = .lunch
    @State private var selectedFood: FoodItem? = nil
    @State private var recentFoods: [FoodItem] = []
    @State private var debounceTimer: Timer?

    var body: some View {
        VStack(spacing: 0) {
            // NavBar
            HStack {
                Text("Add Food")
                    .font(.largeTitle)
                    .bold()
                Spacer()
            }
            .padding([.horizontal, .top, .bottom])

            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search", text: $searchVM.searchText)
                    .font(.body)
                    .padding(.vertical, 10)
                    .onSubmit { searchVM.searchFoods() }
                Button("Search") { searchVM.searchFoods() }
            }
            .padding(.horizontal)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.top, 8)
            // Live search - debounce and call searchFoods on change
            .onChange(of: searchVM.searchText) {
                debounceTimer?.invalidate()
                let trimmed = searchVM.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else {
                    searchVM.searchResults = []
                    return
                }
                debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                    searchVM.searchFoods()
                }
            }
            
            Spacer()
            
            Picker("Meal", selection: $selectedMeal) {
                ForEach(MealType.allCases) { meal in
                    Text(meal.displayName).tag(meal)
                }
            }
            .pickerStyle(.segmented)
            .padding([.leading, .trailing])

            // Results Label
            HStack {
                Text(searchVM.searchText.isEmpty ? "Recent" : "Results")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                Spacer()
            }
            .padding([.leading, .top], 16)

            // List of Results or Recent
            List {
                if searchVM.searchText.isEmpty {
                    ForEach(recentFoods) { food in
                        Button(action: {
                            selectedFood = nil
                            // When tapping a recent, fetch details and show detail view
                            searchVM.fetchDetails(for: food.id) { detailedFood in
                                if let detailedFood = detailedFood {
                                    selectedFood = detailedFood
                                    print("Selectedfood: \(String(describing: selectedFood))")
                                }
                            }
                        }) {
                            FoodSummaryRow(food: food)
                        }
                    }
                } else {
                    ForEach(searchVM.searchResults) { food in
                        Button(action: {
                            selectedFood = nil
                            // When tapping a search result, fetch details and show detail view
                            searchVM.fetchDetails(for: food.id) { detailedFood in
                                if let detailedFood = detailedFood {
                                    selectedFood = detailedFood
                                    addToRecents(food)
                                }
                            }
                        }) {
                            FoodSummaryRow(food: food)
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
            .background(Color.clear)

        }
        .background(Color(.systemBackground))
        .ignoresSafeArea(edges: .bottom)
        .sheet(item: $selectedFood) { food in
            FoodDetailView(food: food, mealType: selectedMeal)
                .environmentObject(mealLogVM)
        }
        .onAppear {
            loadRecents()
        }
    }

    func addToRecents(_ food: FoodItem) {
        var foods = recentFoods.filter { $0.id != food.id }
        foods.insert(food, at: 0)
        recentFoods = Array(foods.prefix(5))
        saveRecents()
    }

    func loadRecents() {
        if let data = UserDefaults.standard.data(forKey: "recentFoods"),
           let decoded = try? JSONDecoder().decode([FoodItem].self, from: data) {
            recentFoods = decoded
        }
    }

    func saveRecents() {
        if let data = try? JSONEncoder().encode(recentFoods) {
            UserDefaults.standard.set(data, forKey: "recentFoods")
        }
    }
}

struct FoodSummaryRow: View {
    let food: FoodItem
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(food.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                Text(food.servingDescription)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
}

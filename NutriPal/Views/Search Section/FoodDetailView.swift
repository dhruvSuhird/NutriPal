import SwiftUI

struct FoodDetailView: View {
    let food: FoodItem
    @EnvironmentObject var mealLogVM: MealLogViewModel
    @Environment(\.dismiss) var dismiss
    @StateObject var searchVM = FoodSearchViewModel()
    let mealType: MealType

    @State var servings: Int = 1
    
    static let servingsFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimum = 1
        return formatter
    }()

    var macroPercents: (fat: Int, carbs: Int, protein: Int) {
        let fat = food.fats * Double(servings) * 9
        let carbs = food.carbs * Double(servings) * 4
        let protein = food.protein * Double(servings) * 4
        let total = fat + carbs + protein

        guard total > 0 else { return (0, 0, 0) }

        // Calculate initial integer parts
        let rawFat = fat / total * 100
        let rawCarbs = carbs / total * 100
        let rawProtein = protein / total * 100

        var fatInt = Int(rawFat)
        var carbsInt = Int(rawCarbs)
        var proteinInt = Int(rawProtein)

        // Calculate remainder
        let sum = fatInt + carbsInt + proteinInt
        let diff = 100 - sum

        let decimals: [(macro: String, value: Double)] = [
            ("fat", rawFat - Double(fatInt)),
            ("carbs", rawCarbs - Double(carbsInt)),
            ("protein", rawProtein - Double(proteinInt))
        ].sorted { $0.value > $1.value }

        for i in 0..<abs(diff) {
            if diff > 0 {
                switch decimals[i % 3].macro {
                case "fat": fatInt += 1
                case "carbs": carbsInt += 1
                case "protein": proteinInt += 1
                default: break
                }
            } else if diff < 0 {
                switch decimals.reversed()[i % 3].macro {
                case "fat": fatInt -= 1
                case "carbs": carbsInt -= 1
                case "protein": proteinInt -= 1
                default: break
                }
            }
        }
        return (fat: fatInt, carbs: carbsInt, protein: proteinInt)
    }

    var body: some View {
        let (fatPercent, carbsPercent, proteinPercent) = (macroPercents.fat, macroPercents.carbs, macroPercents.protein)
        
        // Use fractions (0.0–1.0) for the trim parameters:
        let fatFraction = Double(fatPercent) / 100
        let carbsFraction = Double(carbsPercent) / 100
        
        ScrollView {
            VStack(spacing: 20) {
                HStack(){
                    // Circular Calorie Chart
                    ZStack {
                        Circle()
                        Circle()
                            .trim(from: 0, to: CGFloat(fatFraction))
                            .stroke(Color(hex: "#eb5649"), lineWidth: 10)
                            .rotationEffect(.degrees(-90))
                        
                        Circle()
                            .trim(from: CGFloat(fatFraction), to: CGFloat(fatFraction + carbsFraction))
                            .stroke(Color(hex: "#6bc9ed"), lineWidth: 10)
                            .rotationEffect(.degrees(-90))
                        Circle()
                            .trim(from: CGFloat(fatFraction + carbsFraction), to: CGFloat(100))
                            .stroke(Color(hex: "#f1c861"), lineWidth: 10)
                            .rotationEffect(.degrees(-90))
                        VStack(spacing: 4) {
                            Text("\(Int(food.calories))")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            Text("Calories")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(width: 150, height: 150)
                    
                    // Macro Breakdown
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Circle().fill(Color(hex: "#eb5649")).frame(width: 8, height: 8)
                            Text("fat:")
                                .font(.callout)
                            Text("\(food.fats, specifier: "%.2f")g (\(fatPercent)%)")
                                .bold()
                                .font(.callout)
                        }
                        HStack {
                            Circle().fill(Color(hex: "#6bc9ed")).frame(width: 8, height: 8)
                            Text("carbs:")
                                .font(.callout)
                            Text("\(food.carbs, specifier: "%.2f")g (\(carbsPercent)%)")
                                .bold()
                                .font(.callout)
                        }
                        HStack {
                            Circle().fill(Color(hex: "#f1c861")).frame(width: 8, height: 8)
                            Text("protein:")
                                .font(.callout)
                            Text("\(food.protein, specifier: "%.2f")g (\(proteinPercent)%)")
                                .bold()
                                .font(.callout)
                        }
                    }

                    .padding(.horizontal, 16)
                }
                .padding(.leading, 16)
                .padding(.vertical, 15)
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6))
                        .overlay(
                            
                            VStack(alignment: .leading, spacing: 8) {
                            
                            Text("There are ")
                                .font(.body)
                            + Text("\(Int(food.calories)) calories ").bold()
                                .font(.body)
                            + Text("in 1 serving \(food.name).")
                                .font(.body)
                            
                            Text("Calorie breakdown: \(Int(fatPercent))% fat, \(Int(carbsPercent))% carbs, \(Int(proteinPercent))% protein")
                                .font(.callout)
                            }
                            .padding(7)
                        )
                        .frame(height: 105)
                .padding(.horizontal, 16)

                // Nutrition Facts Label
                NutritionFactsView(food: food)
                    .padding(.horizontal, 0)
                
                HStack{
                    
                    // No. of servings input
                    HStack {
                        Text("No. of servings:")
                            .font(.headline)
                        TextField("Servings", value: $servings, formatter: FoodDetailView.servingsFormatter)
                            .frame(width: 50)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    Divider()
                        .font(.largeTitle)
                    
                    Button(action: {
                        mealLogVM.logFood(food, to: mealType, servings: servings)
                        dismiss()
                    }) {
                        Text("Add to \(mealType)")
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .font(.subheadline)
                            .shadow(color: Color.blue.opacity(0.4), radius: 4, x: 0, y: 2)
                    }
                    .padding(.top, 8)
                    
                }
            }
            .padding(.top, 24)
        }
        .background(Color(.systemBackground))
    }
}

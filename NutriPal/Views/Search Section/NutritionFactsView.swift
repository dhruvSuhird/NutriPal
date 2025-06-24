import SwiftUI

struct NutritionFactsView: View {
    let food: FoodItem

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Nutrition Facts")
                .font(.title).bold()
                .padding(.bottom, 4)
            Spacer()
            Divider()
            HStack {
                Text("Serving Size")
                Spacer()
                Text(food.servingDescription)
            }.font(.subheadline)
                .fontWeight(.light)
            .padding(.vertical, 4)
            Divider()
            HStack {
                Text("Amount Per Serving")
                    .font(.subheadline).bold()
                Spacer()
            }.padding(.vertical, 2)
            HStack {
                Text("Calories")
                Spacer()
                Text("\(Int(food.calories))")
            }
            .font(.title2).bold()
            Divider()
            Group {
                NutritionFactRow(label: "Total Fat", value: String(format: "%.2f", food.fats) + "g")
                NutritionFactRow(label: "Sodium", value: "798 mg")
                NutritionFactRow(label: "Total Carbohydrate", value: String(format: "%.2f", food.carbs) + "g")
                NutritionFactRow(label: "Sugars", value: String(format: "%.2f", food.sugar) + "g")
                NutritionFactRow(label: "Protein", value: String(format: "%.2f", food.protein) + "g")
                NutritionFactRow(label: "Calcium", value: String(format: "%.2f", food.calcium) + "mg")
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.systemGray3), lineWidth: 2)
                .background(Color(.systemBackground))
        )
        .padding(.top, 8)
    }
}

struct NutritionFactRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.body)
            Spacer()
            Text(value)
                .font(.body)
        }
        .padding(.vertical, 6)
    }
}

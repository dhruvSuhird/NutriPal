import SwiftUI

struct MealLogView: View {
    @EnvironmentObject var mealLogVM: MealLogViewModel

    @State private var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    @State private var weekStartDate: Date = {
        let today = Calendar.current.startOfDay(for: Date())
        let weekday = Calendar.current.component(.weekday, from: today)
        return Calendar.current.date(byAdding: .day, value: -(weekday - 1), to: today)!
    }()

    var body: some View {
        VStack(spacing: 0) {
            // Week Header with Date strip and heading
            MealLogWeekHeader(selectedDate: $selectedDate, weekStartDate: $weekStartDate)
                .padding(.top, 16)
                .padding(.bottom, 8)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    ForEach(MealType.allCases, id: \.self) { meal in
                        let foods = mealLogVM.foods(for: meal, on: selectedDate)
                        if !foods.isEmpty {
                            Text(meal.displayName)
                                .font(.title3)
                                .bold()
                                .padding(.bottom, 4)
                                .padding(.leading, 8)
                            VStack(spacing: 16) {
                                ForEach(foods) { log in
                                    FoodLogRow(log: log) {
                                        withAnimation {
                                            mealLogVM.remove(loggedFood: log)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Food Row with Remove

struct FoodLogRow: View {
    let log: LoggedFood
    let onRemove: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top, spacing: 12) {
                FoodImageView(mealType: log.mealType)
                    .frame(width: 42, height: 42)
                    .cornerRadius(10)
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(log.food.name)
                            .font(.body)
                            .fontWeight(.medium)
                        Spacer()
                        Button(action: onRemove) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    Text("\(Int(log.food.calories * Double(log.servings))) cal (\(log.servings)x)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.bottom, 2)

            Divider().padding(.vertical, 2)

            // Nutrients grid (2 columns)
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Carbs")
                        .font(.caption2)
                        .foregroundColor(.blue)
                    Text("\(Int(log.food.carbs * Double(log.servings)))g")
                        .font(.caption)
                    Text("Fat")
                        .font(.caption2)
                        .foregroundColor(.blue)
                    Text("\(Int(log.food.fats * Double(log.servings)))g")
                        .font(.caption)
                }
                Spacer()
                VStack(alignment: .leading, spacing: 2) {
                    Text("Protein")
                        .font(.caption2)
                        .foregroundColor(.blue)
                    Text("\(Int(log.food.protein * Double(log.servings)))g")
                        .font(.caption)
                    Text("Calories")
                        .font(.caption2)
                        .foregroundColor(.blue)
                    Text("\(Int(log.food.calories * Double(log.servings)))g")
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(14)
    }
}

// MARK: - Food Image View

struct FoodImageView: View {
    let mealType: MealType

    var body: some View {
        switch mealType {
        case .breakfast:
            Image(systemName: "sunrise").resizable().scaledToFit()
                .background(Color.gray.opacity(0.1))
        case .lunch:
            Image(systemName: "fork.knife").resizable().scaledToFit()
                .background(Color.gray.opacity(0.1))
        case .dinner:
            Image(systemName: "moon.stars").resizable().scaledToFit()
                .background(Color.gray.opacity(0.1))
        case .snacks:
            Image(systemName: "takeoutbag.and.cup.and.straw").resizable().scaledToFit()
                .background(Color.gray.opacity(0.1))
        }
    }
}

// MARK: - Week Header with Date Strip

struct MealLogWeekHeader: View {
    @Binding var selectedDate: Date
    @Binding var weekStartDate: Date

    private var today: Date { Calendar.current.startOfDay(for: Date()) }

    private var weekDates: [Date] {
        (0..<7).compactMap { Calendar.current.date(byAdding: .day, value: $0, to: weekStartDate) }
    }

    private var heading: String {
        let calendar = Calendar.current
        if calendar.isDate(selectedDate, inSameDayAs: today) {
            return "Today"
        } else if calendar.isDate(selectedDate, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: today)!) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, d MMMM"
            return formatter.string(from: selectedDate)
        }
    }

    private var canMoveToPrevWeek: Bool {
        // At least one day before today in the previous week
        let prevWeekStart = Calendar.current.date(byAdding: .day, value: -7, to: weekStartDate)!
        return prevWeekStart <= today
    }
    private var canMoveToNextWeek: Bool {
        // Only allow moving to weeks containing today but not beyond
        let nextWeekStart = Calendar.current.date(byAdding: .day, value: 7, to: weekStartDate)!
        return nextWeekStart <= today
    }

    var body: some View {
        VStack(spacing: 6) {
            Text(heading)
                .font(.title)
                .bold()
                .padding(.bottom, 2)

            HStack(spacing: 0) {
                Button(action: { moveWeek(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(canMoveToPrevWeek ? .black : .gray)
                        .frame(width: 36, height: 36)
                }
                .disabled(!canMoveToPrevWeek)
                .accessibilityLabel("Previous week")

                Spacer(minLength: 0)

                ForEach(weekDates, id: \.self) { date in
                    let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                    let isFuture = date > today
                    VStack(spacing: 2) {
                        Text(shortWeekdayString(for: date))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Button(action: {
                            if !isFuture {
                                selectedDate = date
                            }
                        }) {
                            VStack(spacing: 2) {
                                Text("\(Calendar.current.component(.day, from: date))")
                                    .font(.body)
                                    .foregroundColor(isSelected ? .black : (isFuture ? .gray : .black))
                                    .fontWeight(isSelected ? .bold : .regular)
                                if isSelected {
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 6, height: 6)
                                } else {
                                    Circle()
                                        .fill(Color.clear)
                                        .frame(width: 6, height: 6)
                                }
                            }
                        }
                        .disabled(isFuture)
                        .buttonStyle(PlainButtonStyle())
                    }
                    .frame(maxWidth: .infinity)
                }

                Spacer(minLength: 0)
                Button(action: { moveWeek(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(canMoveToNextWeek ? .black : .gray)
                        .frame(width: 36, height: 36)
                }
                .disabled(!canMoveToNextWeek)
                .accessibilityLabel("Next week")
            }
        }
        .padding(.horizontal)
    }

    private func shortWeekdayString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }

    private func moveWeek(by offset: Int) {
        let calendar = Calendar.current
        guard let newWeekStart = calendar.date(byAdding: .day, value: offset * 7, to: weekStartDate) else { return }
        let today = self.today
        // Don't allow moving to weeks entirely after today
        if offset > 0 {
            if newWeekStart > today { return }
        }
        weekStartDate = newWeekStart
        // Clamp selectedDate to today if in future, else keep to same weekday in new week
        let weekday = calendar.component(.weekday, from: selectedDate)
        let newSelectedDate = calendar.date(byAdding: .day, value: weekday - 1, to: newWeekStart)!
        selectedDate = newSelectedDate > today ? today : newSelectedDate
    }
}

// MARK: - ViewModel Extension for Remove

extension MealLogViewModel {
    func remove(loggedFood: LoggedFood) {
        if let idx = loggedFoods.firstIndex(where: { $0.id == loggedFood.id }) {
            loggedFoods.remove(at: idx)
            PersistenceManager.shared.saveLoggedFoods(loggedFoods)
        }
    }
}

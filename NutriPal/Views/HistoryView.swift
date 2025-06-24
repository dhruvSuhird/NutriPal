import SwiftUI

// MARK: - CalendarDay Struct
struct CalendarDay: Identifiable {
    let id = UUID()
    let day: Int
    let date: Date
    let isToday: Bool
    let isStart: Bool
    let isEnd: Bool
    let isBetween: Bool
    let isFuture: Bool
}

// MARK: - Main HistoryView
struct HistoryView: View {
    @StateObject private var calendarVM = HistoryCalendarViewModel()
    @StateObject var mealLogVM = MealLogViewModel()
    @StateObject var intakeHistoryVM = IntakeHistoryViewModel()

    private let weekDaysShort = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]

    // Filter history for the selected range
    private func selectedRangeData(_ history: [MacroHistoryDay], start: Date, end: Date) -> [MacroHistoryDay] {
        let calendar = Calendar.current
        return history.filter { day in
            let d = calendar.startOfDay(for: day.date)
            return d >= calendar.startOfDay(for: start) && d <= calendar.startOfDay(for: end)
        }
    }

    // Aggregate macros for the range
    private func macroData(for days: [MacroHistoryDay]) -> (Double, [String: CGFloat]) {
        let protein = days.reduce(0) { $0 + $1.protein }
        let carbs = days.reduce(0) { $0 + $1.carbs }
        let fat = days.reduce(0) { $0 + $1.fat }
        let total = protein + carbs + fat
        let macro: [String: CGFloat] = [
            "Protein": CGFloat(protein / (total == 0 ? 1 : total)),
            "Carbs": CGFloat(carbs / (total == 0 ? 1 : total)),
            "Fat": CGFloat(fat / (total == 0 ? 1 : total))
        ]
        return (total, macro)
    }

    // Aggregate other nutrients for the range
    private func aggregate(for days: [MacroHistoryDay], keyPath: KeyPath<MacroHistoryDay, Double>) -> Double {
        days.reduce(0) { $0 + $1[keyPath: keyPath] }
    }

    // Calorie graph: last 7 days (use the last 7 days in the selected range)
    private func last7Days(_ days: [MacroHistoryDay]) -> [MacroHistoryDay] {
        Array(days.suffix(7))
    }
    private func caloriesLast7(_ days: [MacroHistoryDay]) -> [Double] {
        days.map { $0.calories }
    }
    private func avgCalories(_ calories: [Double]) -> Int {
        let count = max(1, calories.count)
        return Int(calories.reduce(0, +) / Double(count))
    }
    private func lastWeekAvgValue(_ days: [MacroHistoryDay]) -> Double {
        let lastWeek = Array(days.dropLast(7).suffix(7)).map { $0.calories }
        return lastWeek.isEmpty ? 0 : lastWeek.reduce(0, +) / Double(lastWeek.count)
    }
    private func percentChange(_ avgCalories: Int, _ lastWeekAvg: Double) -> Int {
        lastWeekAvg == 0 ? 0 : Int(round(((Double(avgCalories) - lastWeekAvg) / lastWeekAvg) * 100))
    }

    var body: some View {
        let history = intakeHistoryVM.history
        let start = calendarVM.startDate
        let end = calendarVM.endDate
        let selectedDays = selectedRangeData(history, start: start, end: end)
        let (totalMacros, macroDict) = macroData(for: selectedDays)
        let totalCalories = aggregate(for: selectedDays, keyPath: \.calories)
        let totalProtein = aggregate(for: selectedDays, keyPath: \.protein)
        let totalCarbs = aggregate(for: selectedDays, keyPath: \.carbs)
        let totalFat = aggregate(for: selectedDays, keyPath: \.fat)
        let totalSugar = aggregate(for: selectedDays, keyPath: \.sugar)
        let totalSodium = aggregate(for: selectedDays, keyPath: \.sodium)
        let totalCalcium = aggregate(for: selectedDays, keyPath: \.calcium)

        let last7 = last7Days(selectedDays)
        let calories7 = caloriesLast7(last7)
        let avgCal = avgCalories(calories7)
        let lastWeekAvg = lastWeekAvgValue(selectedDays)
        let pctChange = percentChange(avgCal, lastWeekAvg)

        VStack(spacing: 0) {
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Title
                    Text("Daily Nutrient Totals")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 16)
                        .padding(.horizontal)
                    
                    Spacer(minLength: 25)

                    // CALENDAR SECTION
                    HistoryCalendarView(calendarVM: calendarVM)
                        .padding(.horizontal)
                        .padding(.top, 8)

                    Divider().padding(.vertical, 16)

                    // NUTRIENT VALUES (summed for the range)
                    HStack {
                        VStack(alignment: .leading, spacing: 20) {

                                NutrientStat(title: "Calories", value: "\(Int(totalCalories)) kcal")

                                NutrientStat(title: "Carbohydrates", value: "\(Int(totalCarbs)) g")

                                NutrientStat(title: "Sugar", value: "\(Int(totalSugar)) g")

                                NutrientStat(title: "Calcium", value: "\(Int(totalCalcium)) mg")
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 20){
                            NutrientStat(title: "Protein", value: "\(Int(totalProtein)) g")
                            
                            NutrientStat(title: "Fat", value: "\(Int(totalFat)) g")
                            
                            NutrientStat(title: "Sodium", value: "\(Int(totalSodium)) mg")
                            
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 25)

                    Divider().padding(.vertical, 16)

                    // CALORIE INTAKE OVER TIME (last 7 in range)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Calorie Intake Over Time")
                            .font(.headline)
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text("\(avgCal) kcal")
                                .font(.system(size: 32, weight: .bold))
                            Spacer()
                        }
                        
                        LineGraph(data: calories7.map { CGFloat($0) })
                            .frame(height: 80)
                            .padding(.top, 4)
                        HStack {
                            ForEach(weekDaysShort, id: \.self) { day in
                                Text(day.prefix(3))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)

                    // MACRONUTRIENT DISTRIBUTION (summed for the range)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Macronutrient Distribution")
                            .font(.headline)
                        HStack(alignment: .lastTextBaseline, spacing: 6) {
                            Text("\(Int(totalMacros))g")
                                .font(.system(size: 28, weight: .bold))
                            Spacer()
                        }
                        .padding(.bottom, 6)
                        HStack(alignment: .bottom, spacing: 24) {
                            ForEach(["Protein", "Carbs", "Fat"], id: \.self) { macro in
                                MacroBarNew(title: macro, percent: macroDict[macro] ?? 0)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
            }
            .background(Color.white)
        }
        .background(Color(.systemGray6).ignoresSafeArea())
        .onAppear {
            mealLogVM.load()
            intakeHistoryVM.load(from: mealLogVM.loggedFoods)
        }
        .onChange(of: mealLogVM.loggedFoods) { newFoods in
            intakeHistoryVM.load(from: newFoods)
        }
    }
}

// MARK: - HistoryCalendarView
struct HistoryCalendarView: View {
    @ObservedObject var calendarVM: HistoryCalendarViewModel
    let weekDaysShort = ["S", "M", "T", "W", "T", "F", "S"]

    var calendar: Calendar { calendarVM.calendar }
    var today: Date { calendar.startOfDay(for: Date()) }
    var daysRange: Range<Int> {
        calendar.range(of: .day, in: .month, for: calendarVM.displayedMonth) ?? 1..<31
    }
    var firstWeekday: Int {
        calendar.component(.weekday, from: calendarVM.displayedMonth)
    }
    private var calendarDays: [CalendarDay] {
        daysRange.map { day in
            let date = calendar.date(byAdding: .day, value: day - 1, to: calendarVM.displayedMonth)!
            let isToday = calendar.isDate(date, inSameDayAs: today)
            let isStart = calendar.isDate(date, inSameDayAs: calendarVM.startDate)
            let isEnd = calendar.isDate(date, inSameDayAs: calendarVM.endDate)
            let isBetween = (date > calendarVM.startDate && date < calendarVM.endDate)
            let isFuture = date > today
            return CalendarDay(
                day: day,
                date: date,
                isToday: isToday,
                isStart: isStart,
                isEnd: isEnd,
                isBetween: isBetween,
                isFuture: isFuture
            )
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Button {
                    calendarVM.moveMonth(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }
                Spacer()
                Text(calendarVM.displayedMonth, formatter: monthYearFormatter)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Button {
                    calendarVM.moveMonth(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.black)
                }
            }
            .padding(.bottom, 4)
            HStack {
                ForEach(weekDaysShort, id: \.self) { day in
                    Text(day)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            let emptySlots = Array(repeating: "", count: max(0, firstWeekday - 1))
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(0..<emptySlots.count, id: \.self) { _ in
                    Text("").frame(height: 28)
                }
                ForEach(calendarDays) { day in
                    ZStack {
                        if day.isBetween && !day.isFuture {
                            // Light gray background for range (exclude start/end)
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray5))
                                .frame(width: 32, height: 32)
                        }
                        Button(action: { calendarVM.select(date: day.date) }) {
                            ZStack {
                                if (day.isStart || day.isEnd) && !day.isFuture {
                                    Circle().fill(Color.blue).frame(width: 35, height: 35)
                                }
                                Text("\(day.day)")
                                    .font(.body)
                                    .foregroundColor(
                                        day.isFuture
                                            ? .gray
                                            : (day.isStart || day.isEnd
                                                ? .white
                                                : (day.isBetween ? .black : .black))
                                    )
                                    .frame(width: 32, height: 32)
                                    .fontWeight(day.isToday ? .bold : .regular)
                            }
                        }
                        .disabled(day.isFuture)
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(.top, 6)
            .padding(.bottom, 4)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color(.white)))
        }
    }

    var monthYearFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "LLLL yyyy"
        return f
    }
}

// MARK: - NutrientStat
struct NutrientStat: View {
    let title: String
    let value: String
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            Text(value)
                .font(.body)
        }
    }
}

// MARK: - LineGraph (Simple Mock)
struct LineGraph: View {
    let data: [CGFloat]
    var body: some View {
        GeometryReader { geo in
            Path { path in
                guard data.count > 1 else { return }
                let w = geo.size.width
                let h = geo.size.height
                let maxVal = data.max() ?? 1
                let minVal = data.min() ?? 0
                let range = maxVal - minVal == 0 ? 1 : maxVal - minVal
                let stepX = w / CGFloat(data.count - 1)
                path.move(to: CGPoint(x: 0, y: h - (data[0] - minVal) / range * h))
                for i in 1..<data.count {
                    path.addLine(to: CGPoint(x: stepX * CGFloat(i), y: h - (data[i] - minVal) / range * h))
                }
            }
            .stroke(Color(red: 0.28, green: 0.35, blue: 0.47), lineWidth: 2)
        }
    }
}

// MARK: - MacroBarNew
struct MacroBarNew: View {
    let title: String
    let percent: CGFloat
    var body: some View {
        VStack(spacing: 2) {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(.systemGray5))
                    .frame(width: 38, height: 84)
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(.systemGray3))
                    .frame(width: 38, height: 84 * percent)
            }
            .overlay(
                Rectangle()
                    .fill(Color.black)
                    .frame(height: 2)
                    .offset(y: -84 * percent)
                ,alignment: .bottom
            )
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, 2)
        }
    }
}

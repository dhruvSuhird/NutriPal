import SwiftUI

struct SetBirthdayView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var profile: UserProfile

    let years: [Int] = Array(1900...Calendar.current.component(.year, from: Date()))
    let months: [String] = DateFormatter().monthSymbols

    @State private var selectedYear: Int
    @State private var selectedMonth: Int // 0-based index
    @State private var selectedDay: Int

    var onSave: (String) -> Void

    // Custom initializer
    init(initialDate: String, onSave: @escaping (String) -> Void) {
        self.onSave = onSave
        let comps = initialDate.split(separator: "/")
        let day = Int(comps[safe: 0] ?? "1") ?? 1
        let month = (Int(comps[safe: 1] ?? "6") ?? 6) - 1 // 0-based
        let year = Int(comps[safe: 2] ?? "2003") ?? 2003
        _selectedDay = State(initialValue: day)
        _selectedMonth = State(initialValue: month)
        _selectedYear = State(initialValue: year)
    }

    var daysInSelectedMonth: [Int] {
        var comps = DateComponents()
        comps.year = selectedYear
        comps.month = selectedMonth + 1 // DateComponents months are 1-based
        let calendar = Calendar.current
        let date = calendar.date(from: comps)!
        let range = calendar.range(of: .day, in: .month, for: date)!
        return Array(range)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Circle()
                        .fill(Color(.systemGray6))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "chevron.left")
                                .foregroundColor(.black)
                                .font(.system(size: 20, weight: .semibold))
                        )
                }
                Spacer()
                Text("Set Birthday")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Spacer().frame(width: 40)
            }
            .padding(.top, 18)
            .padding(.horizontal)
            .padding(.bottom, 18)

            Spacer()

            // Wheel Pickers
            HStack(spacing: 0) {
                // Month
                Picker("", selection: $selectedMonth) {
                    ForEach(months.indices, id: \.self) { idx in
                        Text(months[idx])
                            .tag(idx)
                    }
                }
                .frame(width: 120, height: 120)
                .clipped()
                .pickerStyle(WheelPickerStyle())

                // Day
                Picker("", selection: $selectedDay) {
                    ForEach(daysInSelectedMonth, id: \.self) { day in
                        Text("\(day)")
                            .tag(day)
                    }
                }
                .frame(width: 80, height: 120)
                .clipped()
                .pickerStyle(WheelPickerStyle())

                // Year
                Picker("", selection: $selectedYear) {
                    ForEach(years.reversed(), id: \.self) { year in
                        Text(String(format: "%d", year))
                            .tag(year)
                    }
                }
                .frame(width: 90, height: 120)
                .clipped()
                .pickerStyle(WheelPickerStyle())
            }
            .frame(maxHeight: 180)
            .onChange(of: selectedMonth) { _ in
                let days = daysInSelectedMonth
                if !days.contains(selectedDay) {
                    selectedDay = days.last ?? 1
                }
            }
            .onChange(of: selectedYear) { _ in
                let days = daysInSelectedMonth
                if !days.contains(selectedDay) {
                    selectedDay = days.last ?? 1
                }
            }

            Spacer()

            Button(action: {
                let dateString = String(format: "%02d/%02d/%04d", selectedDay, selectedMonth+1, selectedYear)
                onSave(dateString)
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Save changes")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(28)
                    .padding(.horizontal)
            }
            .padding(.bottom, 36)
        }
        .background(Color(.systemBackground))
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .ignoresSafeArea(edges: .bottom)
    }
}

fileprivate extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    SetBirthdayView(initialDate: "23/06/2003", onSave: { _ in })
}

import Foundation


class HistoryCalendarViewModel: ObservableObject {
    @Published var displayedMonth: Date
    @Published var startDate: Date
    @Published var endDate: Date
    let calendar: Calendar = .current

    init() {
        let today = calendar.startOfDay(for: Date())
        self.displayedMonth = today.startOfMonth(using: calendar)
        self.startDate = today
        self.endDate = today
    }

    func moveMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: displayedMonth) {
            displayedMonth = newMonth.startOfMonth(using: calendar)
        }
    }

    func select(date: Date) {
        let tapped = calendar.startOfDay(for: date)
        if startDate == endDate {
            // Start new range from tapped date
            if tapped == startDate { return }
            if tapped < startDate {
                startDate = tapped
            } else {
                endDate = tapped
            }
        } else {
            // If tapped inside range, start a new selection
            if tapped >= startDate && tapped <= endDate {
                startDate = tapped
                endDate = tapped
            } else if tapped < startDate {
                startDate = tapped
            } else {
                endDate = tapped
            }
        }
        // Ensure startDate <= endDate
        if startDate > endDate {
            swap(&startDate, &endDate)
        }
    }

    func isInRange(_ date: Date) -> Bool {
        let d = calendar.startOfDay(for: date)
        return d >= startDate && d <= endDate
    }
}


extension Date {
    func startOfMonth(using calendar: Calendar) -> Date {
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components)!
    }
    func endOfMonth(using calendar: Calendar) -> Date {
        var comps = DateComponents()
        comps.month = 1
        comps.day = -1
        return calendar.date(byAdding: comps, to: startOfMonth(using: calendar))!
    }
    func isInSameMonth(as other: Date, using calendar: Calendar) -> Bool {
        calendar.isDate(self, equalTo: other, toGranularity: .month)
    }
    func isToday(_ calendar: Calendar) -> Bool {
        calendar.isDateInToday(self)
    }
    func startOfDay(using calendar: Calendar) -> Date {
        calendar.startOfDay(for: self)
    }
}

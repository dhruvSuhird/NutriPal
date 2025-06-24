import SwiftUI
import Charts

struct MacroTrendsView: View {
    @ObservedObject var historyVM: IntakeHistoryViewModel
    
    var body: some View {
        VStack {
            if #available(iOS 16.0, *) {
                Chart(historyVM.history) { day in
                    BarMark(
                        x: .value("Date", day.date, unit: .day),
                        y: .value("Calories", day.calories)
                    )
                    .foregroundStyle(.green)
                }
                .frame(height: 200)
                .padding()
            } else {
                Text("Charts require iOS 16+")
            }
        }
        .navigationTitle("Macro Trends")
    }
}

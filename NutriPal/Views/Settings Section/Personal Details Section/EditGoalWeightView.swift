import SwiftUI

struct EditWeightGoalView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedWeight: Int = 85
    @State private var goalType: GoalType = .maintain // Change as needed

    let minWeight = 40
    let maxWeight = 150

    var body: some View {
        VStack {
            // Top Bar
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Circle()
                        .fill(Color(.systemGray6))
                        .frame(width: 48, height: 48)
                        .overlay(
                            Image(systemName: "arrow.left")
                                .foregroundColor(.black)
                                .font(.system(size: 22, weight: .medium))
                        )
                }
                Spacer()
            }
            .padding(.leading, 24)
            .padding(.top, 32)

            // Title
            Text("Edit Weight Goal")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(Color(.label))
                .frame(maxWidth: .infinity)
                .padding(.top, 8)

            Spacer()

            // Goal Type
            Text(goalType.displayText)
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(Color(.label))
                .padding(.bottom, 8)

            // Selected Weight
            Text("\(selectedWeight) kg")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(Color(.label))

            // Down Arrow
            Image(systemName: "chevron.down")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color(.label))
                .padding(.bottom, 8)

            // Ruler
            WeightRulerView(selectedWeight: $selectedWeight, minWeight: minWeight, maxWeight: maxWeight)
                .frame(height: 100)
                .padding(.bottom, 32)

            Spacer()

            // Done Button
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Done")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(Color(.label))
                    .cornerRadius(32)
                    .padding(.horizontal, 24)
            }
            .padding(.bottom, 32)
        }
        .background(Color.white.ignoresSafeArea())
    }
}

enum GoalType {
    case gain, lose, maintain

    var displayText: String {
        switch self {
        case .gain: return "Gain Weight"
        case .lose: return "Lose Weight"
        case .maintain: return "Maintain Weight"
        }
    }
}

struct WeightRulerView: View {
    @Binding var selectedWeight: Int
    let minWeight: Int
    let maxWeight: Int

    @GestureState private var dragOffset: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0

    let tickSpacing: CGFloat = 16

    var body: some View {
        GeometryReader { geo in
            let totalTicks = maxWeight - minWeight + 1
            let rulerWidth = CGFloat(totalTicks - 1) * tickSpacing
            let centerX = geo.size.width / 2

            ZStack {
                // Ruler
                HStack(spacing: 0) {
                    ForEach(minWeight...maxWeight, id: \.self) { weight in
                        VStack {
                            Rectangle()
                                .fill(weight == selectedWeight ? Color(.label) : Color(.systemGray3))
                                .frame(width: 2, height: weight % 5 == 0 ? 40 : 24)
                            if weight % 5 == 0 {
                                Text("\(weight) kg")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(.label))
                                    .frame(height: 20)
                            } else {
                                Spacer().frame(height: 20)
                            }
                        }
                        .frame(width: tickSpacing)
                    }
                }
                .offset(x: scrollOffset + dragOffset)
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { value, state, _ in
                            state = value.translation.width
                        }
                        .onEnded { value in
                            let totalOffset = scrollOffset + value.translation.width
                            let centerIndex = Int(round(-totalOffset / tickSpacing)) + (selectedWeight - minWeight)
                            let newWeight = min(max(minWeight, centerIndex + minWeight), maxWeight)
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                selectedWeight = newWeight
                                scrollOffset = -CGFloat(selectedWeight - minWeight) * tickSpacing
                            }
                        }
                )
                .onAppear {
                    scrollOffset = -CGFloat(selectedWeight - minWeight) * tickSpacing
                }
                .onChange(of: selectedWeight) { newValue in
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        scrollOffset = -CGFloat(newValue - minWeight) * tickSpacing
                    }
                }

                // Center Indicator
                Rectangle()
                    .fill(Color(.label))
                    .frame(width: 3, height: 60)
                    .position(x: centerX, y: 40)
            }
        }
    }
}

struct WeightGoalView_Previews: PreviewProvider {
    static var previews: some View {
        EditWeightGoalView()
    }
}



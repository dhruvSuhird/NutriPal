import SwiftUI

struct SetHeightWeightView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var profile: UserProfile

    // Accept initial values and completion callback
    var initialHeight: Double
    var initialWeight: Int
    var onSave: (Double, Int) -> Void

    @State private var selectedHeightCm: Int
    @State private var selectedWeightKg: Int

    let minHeightCm = 100, maxHeightCm = 230
    let minWeightKg = 30, maxWeightKg = 200

    // Helper initializer
    init(initialHeight: Double, initialWeight: Int, onSave: @escaping (Double, Int) -> Void) {
        self.initialHeight = initialHeight
        self.initialWeight = initialWeight
        self.onSave = onSave

        _selectedHeightCm = State(initialValue: Int(initialHeight))
        _selectedWeightKg = State(initialValue: initialWeight)
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
                Text("Set Height & Weight")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Spacer().frame(width: 40)
            }
            .padding(.horizontal)
            .padding(.top, 18)
            .padding(.bottom, 18)

            Spacer()

            HStack(alignment: .center, spacing: 32) {
                // Height Picker
                VStack(alignment: .center, spacing: 15) {
                    Text("Height")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.black)
                    Picker("", selection: $selectedHeightCm) {
                        ForEach(minHeightCm...maxHeightCm, id: \.self) { value in
                            Text("\(value) cm")
                                .tag(value)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(height: 120)
                    .clipped()
                }
                // Weight Picker
                VStack(alignment: .center, spacing: 15) {
                    Text("Weight")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.black)
                    Picker("", selection: $selectedWeightKg) {
                        ForEach(minWeightKg...maxWeightKg, id: \.self) { value in
                            Text("\(value) kg")
                                .tag(value)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(height: 120)
                    .clipped()
                }
            }
            .padding(.bottom, 0)
            .frame(maxHeight: 180)

            Spacer()

            Button(action: {
                // Pass back the selected values in metric
                let heightCm = Double(selectedHeightCm)
                let weightKg = selectedWeightKg
                onSave(heightCm, weightKg)
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

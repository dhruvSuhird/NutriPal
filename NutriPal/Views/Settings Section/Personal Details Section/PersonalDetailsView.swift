import SwiftUI

struct PersonalDetailsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var profile: UserProfile
    
    // For macro goals (optional, can be stored elsewhere)
    @State private var calorieGoal: String = "2280"
    @State private var proteinGoal: String = "185"
    @State private var carbGoal: String = "242"
    @State private var fatGoal: String = "63"
    
    // Navigation triggers
    @State private var navToHeightWeightWeight = false
    @State private var navToHeightWeightHeight = false
    @State private var navToBirthday = false
    @State private var navToGender = false
    
    @State private var isEditingGoal = false
    @State private var goalWeight: Int = 85
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
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
                    Text("Personal details")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.leading, 8)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 18)
                .padding(.bottom, 32)
                    
                    // Details Card
                    VStack() {
                        NavigationLink(
                            destination: SetHeightWeightView(
                                initialHeight: Double(profile.height),
                                initialWeight: profile.currentWeight,
                                onSave: { newHeight, newWeight in
                                    self.profile.currentWeight = newWeight
                                }
                            ),
                            isActive: $navToHeightWeightWeight
                        ) {
                            EditableDetailRow(
                                label: "Current Weight",
                                value: "\(profile.currentWeight) kg",
                                isBold: false,
                                pencilAction: { navToHeightWeightWeight = true }
                            )
                        }
                        NavigationLink(
                            destination: SetHeightWeightView(
                                initialHeight: Double(profile.height),
                                initialWeight: profile.currentWeight,
                                onSave: { newHeight, newWeight in
                                    self.profile.height = Int(newHeight)
                                }
                            ),
                            isActive: $navToHeightWeightHeight
                        ) {
                            EditableDetailRow(
                                label: "Height",
                                value: "\(profile.height) cm",
                                isBold: false,
                                pencilAction: { navToHeightWeightHeight = true }
                            )
                        }
                        NavigationLink(
                            destination: SetBirthdayView(
                                initialDate: profile.dob,
                                onSave: { newDate in self.profile.dob = newDate }
                            ),
                            isActive: $navToBirthday
                        ) {
                            EditableDetailRow(
                                label: "Date of birth",
                                value: profile.dob,
                                isBold: true,
                                pencilAction: { navToBirthday = true }
                            )
                        }
                        NavigationLink(
                            destination: GenderSelectionView(
                                selectedGender: profile.gender,
                                onSave: { newGender in self.profile.gender = newGender }
                            ),
                            isActive: $navToGender
                        ) {
                            EditableDetailRow(
                                label: "Gender",
                                value: profile.gender.rawValue,
                                isBold: false,
                                pencilAction: { navToGender = true }
                            )
                        }
                    }
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color(.systemGray5), lineWidth: 1)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color(.systemBackground))
                            )
                    )
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    Spacer()
                }
                .background(Color(.systemBackground))
                .ignoresSafeArea(edges: .bottom)
                .navigationBarBackButtonHidden(true)
                .toolbar(.hidden, for: .tabBar)
            }
        }
    }


struct EditableDetailRow: View {
    var label: String
    var value: String
    var isBold: Bool = false
    var pencilAction: () -> Void

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .fontWeight(isBold ? .bold : .regular)
                .foregroundColor(.black)
            Button(action: pencilAction) {
                Image(systemName: "pencil")
                    .foregroundColor(Color(.systemGray3))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}

#Preview {
    PersonalDetailsView().environmentObject(UserProfile())
}

import SwiftUI

struct GenderSelectionView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var profile: UserProfile

    @State private var selectedGender: Gender
    
    let genders = Gender.allCases
    var onSave: (Gender) -> Void

    // Custom initializer
    init(selectedGender: Gender, onSave: @escaping (Gender) -> Void) {
        self._selectedGender = State(initialValue: selectedGender)
        self.onSave = onSave
    }

    var body: some View {
        VStack {
            // Header
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
                Spacer()
                Text("Set Gender")
                    .font(.headline)
                    .bold()
                Spacer()
                Spacer().frame(width: 44)
            }
            .padding(.horizontal)
            .padding(.top, 10)
            Spacer()
            // Gender Options
            ForEach(genders, id: \.self) { gender in
                Button(action: {
                    selectedGender = gender
                }) {
                    Text(gender.rawValue.capitalized)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(selectedGender == gender ? .white : .black)
                        .background(
                            selectedGender == gender ? Color.black : Color(.systemGray6)
                        )
                        .cornerRadius(14)
                        .padding(.horizontal)
                }
                .padding(.vertical, 4)
            }
            Spacer()
            // Save Button
            Button(action: {
                onSave(selectedGender)
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Save changes")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(25)
                    .padding(.horizontal)
            }
            .padding(.bottom, 30)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }
}

struct GenderSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        GenderSelectionView(selectedGender: .male, onSave: { _ in })
    }
}

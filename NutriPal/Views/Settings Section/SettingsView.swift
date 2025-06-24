import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var profile: UserProfile
    
    @State private var burnedCaloriesEnabled: Bool = false
    @State private var showPersonalDetails: Bool = false
    @State private var showAdjustGoals: Bool = false

    var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    Text("Settings")
                        .font(.system(size: 34, weight: .bold))
                        .padding(.top, 16)
                        .padding(.bottom, 32)
                        .padding(.horizontal)

                    // User stats
                    VStack(spacing: 24) {
                        HStack {
                            Text("Age")
                            Spacer()
                            Text("\(profile.age)")
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            Text("Height")
                            Spacer()
                            Text("\(profile.height) cm")
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            Text("Current Weight")
                            Spacer()
                            Text("\(profile.currentWeight) kg")
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                        }
                    }
                    .font(.system(size: 20))
                    .padding(.horizontal)
                    .padding(.bottom, 28)
                    
                    Divider().padding(.vertical, 8)

                    // --- Customization Section ---
                    Text("Customization")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.bottom, 8)

                    VStack(spacing: 0) {
                        NavigationLink(destination: PersonalDetailsView(), isActive: $showPersonalDetails) {
                            SettingsRow(title: "Personal details")
                        }
                        .buttonStyle(PlainButtonStyle())

                        NavigationLink(destination: AdjustGoalsView(), isActive: $showAdjustGoals) {
                            SettingsRow(
                                title: "Adjust goals",
                                subtitle: "Calories, carbs, fats, and protein"
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .background(Color(.systemBackground))
                    .padding(.bottom, 24)

                    Divider().padding(.vertical, 8)

                    // --- Legal Section ---
                    Text("Legal")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.bottom, 8)

                    VStack(spacing: 0) {
                        SettingsRow(title: "Terms and Conditions", showChevron: true)
                        SettingsRow(title: "Privacy Policy", showChevron: true)
                        SettingsRow(title: "Support Email", showChevron: true)
                    }
                    .background(Color(.systemBackground))
                    .padding(.bottom, 24)
                }
            }
    }
}

struct SettingsRow: View {
    var title: String
    var subtitle: String? = nil
    var showChevron: Bool = true

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            if showChevron {
                Image(systemName: "chevron.right")
                    .foregroundColor(Color(.systemGray3))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 16)
        .background(Color(.systemGray6).opacity(0.01))
    }
}

#Preview {
    SettingsView().environmentObject(UserProfile())
}

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    @State private var showingEditProfile = false
    @State private var showingSettings = false
    @State private var showingAbout = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    profileHeaderSection
                    
                    // Quick Stats
                    quickStatsSection
                    
                    // Menu Items
                    VStack(spacing: 0) {
                        profileMenuItem(
                            icon: "person.circle.fill",
                            title: "Edit Profile",
                            subtitle: "Update your personal information"
                        ) {
                            showingEditProfile = true
                        }
                        
                        Divider().padding(.leading, 60)
                        
                        profileMenuItem(
                            icon: "heart.fill",
                            title: "Favorite Shops",
                            subtitle: "Manage your favorite coffee shops"
                        ) {
                            // TODO: Navigate to favorites
                        }
                        
                        Divider().padding(.leading, 60)
                        
                        profileMenuItem(
                            icon: "creditcard.fill",
                            title: "Payment Methods",
                            subtitle: "Manage cards and payment options"
                        ) {
                            // TODO: Navigate to payment methods
                        }
                        
                        Divider().padding(.leading, 60)
                        
                        profileMenuItem(
                            icon: "bell.fill",
                            title: "Notifications",
                            subtitle: "Order updates and promotional offers"
                        ) {
                            // TODO: Navigate to notifications settings
                        }
                        
                        Divider().padding(.leading, 60)
                        
                        profileMenuItem(
                            icon: "gear.circle.fill",
                            title: "Settings",
                            subtitle: "App preferences and privacy"
                        ) {
                            showingSettings = true
                        }
                        
                        Divider().padding(.leading, 60)
                        
                        profileMenuItem(
                            icon: "questionmark.circle.fill",
                            title: "Help & Support",
                            subtitle: "Get help with your orders"
                        ) {
                            // TODO: Navigate to help
                        }
                        
                        Divider().padding(.leading, 60)
                        
                        profileMenuItem(
                            icon: "info.circle.fill",
                            title: "About Muggo",
                            subtitle: "App version and legal information"
                        ) {
                            showingAbout = true
                        }
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    
                    // Sign Out Button
                    signOutButton
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
    }
    
    private var profileHeaderSection: some View {
        VStack(spacing: 16) {
            // Profile Image
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 100, height: 100)
                .overlay {
                    if let user = authManager.currentUser {
                        Text(String(user.name.prefix(1)).uppercased())
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.blue)
                    } else {
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                    }
                }
            
            // User Info
            VStack(spacing: 4) {
                if let user = authManager.currentUser {
                    Text(user.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let phone = user.phoneNumber {
                        Text(phone)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text("Guest User")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Sign in to save your preferences")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var quickStatsSection: some View {
        HStack(spacing: 20) {
            StatCard(
                icon: "cup.and.saucer.fill",
                title: "Orders",
                value: "12",
                color: .brown
            )
            
            StatCard(
                icon: "heart.fill",
                title: "Favorites",
                value: "3",
                color: .red
            )
            
            StatCard(
                icon: "star.fill",
                title: "Reviews",
                value: "8",
                color: .yellow
            )
        }
    }
    
    private func profileMenuItem(
        icon: String,
        title: String,
        subtitle: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 28)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var signOutButton: some View {
        Button(action: {
            authManager.logout()
        }) {
            HStack {
                Image(systemName: "arrow.right.square.fill")
                    .font(.title3)
                Text("Sign Out")
                    .font(.headline)
                    .fontWeight(.medium)
            }
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
}

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authManager: AuthenticationManager
    
    @State private var name = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Personal Information") {
                    TextField("Full Name", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                }
                
                Section("Preferences") {
                    HStack {
                        Text("Default Payment Method")
                        Spacer()
                        Text("Apple Pay")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Notifications")
                        Spacer()
                        Text("Enabled")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // TODO: Save profile changes
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            if let user = authManager.currentUser {
                name = user.name
                email = user.email
                phoneNumber = user.phoneNumber ?? ""
            }
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var notificationsEnabled = true
    @State private var locationEnabled = true
    @State private var darkModeEnabled = false
    @State private var biometricsEnabled = true
    
    var body: some View {
        NavigationView {
            Form {
                Section("Notifications") {
                    Toggle("Order Updates", isOn: $notificationsEnabled)
                    Toggle("Promotional Offers", isOn: .constant(false))
                    Toggle("New Shop Alerts", isOn: .constant(true))
                }
                
                Section("Privacy") {
                    Toggle("Location Services", isOn: $locationEnabled)
                    Toggle("Use Biometrics", isOn: $biometricsEnabled)
                }
                
                Section("Appearance") {
                    Toggle("Dark Mode", isOn: $darkModeEnabled)
                }
                
                Section("Data") {
                    Button("Clear Cache") {
                        // TODO: Clear cache
                    }
                    
                    Button("Reset Preferences") {
                        // TODO: Reset preferences
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // App Icon and Info
                    VStack(spacing: 16) {
                        Image(systemName: "cup.and.saucer.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.brown)
                        
                        VStack(spacing: 8) {
                            Text("Muggo")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("Version 1.0.0")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("Your favorite coffee companion")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding()
                    
                    // Legal Links
                    VStack(spacing: 16) {
                        Button("Privacy Policy") {
                            // TODO: Open privacy policy
                        }
                        .foregroundColor(.blue)
                        
                        Button("Terms of Service") {
                            // TODO: Open terms of service
                        }
                        .foregroundColor(.blue)
                        
                        Button("Acknowledgments") {
                            // TODO: Open acknowledgments
                        }
                        .foregroundColor(.blue)
                    }
                    
                    // Copyright
                    Text("© 2024 Muggo. All rights reserved.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 32)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthenticationManager())
}
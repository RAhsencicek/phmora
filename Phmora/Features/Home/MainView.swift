import SwiftUI

enum MainTab {
    case home, search, fdaSearch, notifications
}

struct MainView: View {
    @State private var selectedTab: MainTab = .home
    @State private var showAddMedicationSheet = false
    @State private var showProfileSheet = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                HomeView(showAddMedicationSheet: $showAddMedicationSheet)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                showProfileSheet = true
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.blue.opacity(0.6), Color.green.opacity(0.4)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 36, height: 36)
                                        .shadow(color: .blue.opacity(0.3), radius: 4)
                                    
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
            }
            .tabItem {
                Label("Harita", systemImage: "map.fill")
            }
            .tag(MainTab.home)
            
            NavigationView {
                SearchView()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                showProfileSheet = true
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.blue.opacity(0.6), Color.green.opacity(0.4)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 36, height: 36)
                                        .shadow(color: .blue.opacity(0.3), radius: 4)
                                    
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
            }
            .tabItem {
                Label("Arama", systemImage: "magnifyingglass")
            }
            .tag(MainTab.search)
            
            NavigationView {
                FDADrugSearchView()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                showProfileSheet = true
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.blue.opacity(0.6), Color.green.opacity(0.4)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 36, height: 36)
                                        .shadow(color: .blue.opacity(0.3), radius: 4)
                                    
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
            }
            .tabItem {
                Label("FDA", systemImage: "pill.fill")
            }
            .tag(MainTab.fdaSearch)
            
            NavigationView {
                NotificationsView()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                showProfileSheet = true
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.blue.opacity(0.6), Color.green.opacity(0.4)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 36, height: 36)
                                        .shadow(color: .blue.opacity(0.3), radius: 4)
                                    
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
            }
            .tabItem {
                Label("Bildirimler", systemImage: "bell.fill")
            }
            .tag(MainTab.notifications)
        }
        .accentColor(Color.blue)
        .tint(Color.blue)
        .sheet(isPresented: $showAddMedicationSheet) {
            AddMedicationView { newMedication in
                // İlaç ekleme işlemi
                showAddMedicationSheet = false
            }
        }
        .sheet(isPresented: $showProfileSheet) {
            NavigationView {
                ProfileView()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Kapat") {
                                showProfileSheet = false
                            }
                            .foregroundColor(.blue)
                        }
                    }
            }
        }
    }
}

#Preview {
    MainView()
} 
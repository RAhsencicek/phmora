import SwiftUI

enum MainTab {
    case home, search, profile, notifications
}

struct MainView: View {
    @State private var selectedTab: MainTab = .home
    @State private var showAddMedicationSheet = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                HomeView(showAddMedicationSheet: $showAddMedicationSheet)
            }
            .tabItem {
                Label("Harita", systemImage: "map")
            }
            .tag(MainTab.home)
            
            NavigationView {
                SearchView()
            }
            .tabItem {
                Label("Arama", systemImage: "magnifyingglass")
            }
            .tag(MainTab.search)
            
            NavigationView {
                ProfileView()
            }
            .tabItem {
                Label("Profil", systemImage: "person")
            }
            .tag(MainTab.profile)
            
            NavigationView {
                NotificationsView()
            }
            .tabItem {
                Label("Bildirimler", systemImage: "bell")
            }
            .tag(MainTab.notifications)
        }
        .accentColor(Color(red: 0.4, green: 0.5, blue: 0.4))  // Tab bar seçili rengi
        .tint(Color(red: 0.4, green: 0.5, blue: 0.4))  // iOS 15+ için
        .sheet(isPresented: $showAddMedicationSheet) {
            AddMedicationView { newMedication in
                // İlaç ekleme işlemi
                showAddMedicationSheet = false
            }
        }
    }
}

#Preview {
    MainView()
} 
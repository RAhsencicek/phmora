//
//  PhmoraApp.swift
//  Phmora
//
//  Created by Ahsen on 25.03.2025.
//

import SwiftUI

@main
struct PhmoraApp: App {
    
    init() {
        // Mock user data setup for testing
        MockDataSetup.setupMockUserData()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

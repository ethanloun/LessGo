//
//  ContentView.swift
//  LessGo
//
//  Created by Ethan on 8/9/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        MainTabView()
            .environmentObject(authViewModel)
            .background(Color.blue)
    }
}

#Preview {
    ContentView()
}

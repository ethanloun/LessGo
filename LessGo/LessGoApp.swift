//
//  LessGoApp.swift
//  LessGo
//
//  Created by Ethan on 8/9/25.
//

import SwiftUI

@main
struct LessGoApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.viewContext)
        }
    }
}

//
//  SpendingTrackerApp.swift
//  SpendingTracker
//
//  Created by Саид-Насир Исмаилов on 2023/07/20.
//

import SwiftUI

@main
struct SpendingTrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

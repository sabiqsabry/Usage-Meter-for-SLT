//
//  SLT_Usage_MeterApp.swift
//  SLT Usage Meter
//
//  Created by Prabhashwara on 2024-06-30.
//

import SwiftUI

@main
struct SLT_Usage_MeterApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                #if os(macOS)
                .frame(minWidth: 375, minHeight: 650)
                #endif
        }
    }
}

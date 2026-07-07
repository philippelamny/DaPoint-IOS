//
//  DaPointApp.swift
//  DaPoint
//
//  Created by philippe on 07/07/2026.
//

import SwiftUI
import SwiftData

@main
struct DaPointApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            GameSession.self,
            SessionPlayer.self,
            RoundScore.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // Schéma modifié en développement — on repart sur un store vierge
            let appSupport = FileManager.default
                .urls(for: .applicationSupportDirectory, in: .userDomainMask)
                .first
            if let base = appSupport {
                let store = base.appendingPathComponent("default.store")
                try? FileManager.default.removeItem(at: store)
                try? FileManager.default.removeItem(at: base.appendingPathComponent("default.store-wal"))
                try? FileManager.default.removeItem(at: base.appendingPathComponent("default.store-shm"))
            }
            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
        }
        .modelContainer(sharedModelContainer)
    }
}

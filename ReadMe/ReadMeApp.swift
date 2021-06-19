//
//  ReadMeApp.swift
//  ReadMe
//
//  Created by bogdanov on 16.06.21.
//

import SwiftUI

@main
struct ReadMeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(Library())
        }
    }
}

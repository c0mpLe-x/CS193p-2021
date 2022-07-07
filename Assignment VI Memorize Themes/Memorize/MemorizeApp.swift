//
//  MemorizeApp.swift
//  Memorize
//
//  Created by Він on 07.07.2021.
//

import SwiftUI

@main
struct MemorizeApp: App {
    @StateObject var themes = ThemeStore(named: "Default")

    var body: some Scene {
        WindowGroup {
            ThemeChooser()
                .environmentObject(themes)
        }
    }
}

//
//  SetApp.swift
//  Set
//
//  Created by Він on 07.11.2021.
//

import SwiftUI

@main
struct SetApp: App {
    let game = ClassicSetGame()
    var body: some Scene {
        WindowGroup {
            ClassicSetGameView(game: game)
        }
    }
}

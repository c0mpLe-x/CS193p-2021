//
//  ThemeStore.swift
//  Memorize
//
//  Created by Він on 24.08.2021.
//

import Foundation

struct MemoryTheme: Equatable, Identifiable, Codable, Hashable {
    var name: String
    var emojis: String {
        willSet {
            let removedEmoji = emojis.filter { !newValue.contains($0) }
            removedEmojis += removedEmoji
            removedEmojis.removeAll(where: { newValue.contains($0) } )
        }
        
        didSet {
            emojis = emojis.removingDuplicateCharacters.filter({ $0.isEmoji })
        }
    }
    var removedEmojis: String = ""
    var numberOfPairs: Int
    var color: RGBAColor
    var id: Int
    
    init(name: String, emojis: String, numberOfPairs: Int, color: RGBAColor, id: Int) {
        self.name = name
        self.emojis = emojis
        self.numberOfPairs = numberOfPairs
        self.color = color
        self.id = id
    }
    
    struct RGBAColor: Codable, Equatable, Hashable {
        static let red = RGBAColor(red: 1, green: 0, blue: 0)
        static let green = RGBAColor(red: 0, green: 1, blue: 0)
        static let blue = RGBAColor(red: 0, green: 0, blue: 1)
        static let yellow = RGBAColor(red: 1, green: 1, blue: 0)
        static let purple = RGBAColor(red: 1, green: 0, blue: 1)
        static let orange = RGBAColor(red: 1, green: 0.5, blue: 0)
        static let black = RGBAColor(red: 0, green: 0, blue: 0)
        
        static let colorPalette = [red, green, blue, yellow, purple, orange, black]
        
        let red: Double
        let green: Double
        let blue: Double
        let alpha: Double
        
        init(red: Double, green: Double, blue: Double, alpha: Double = 1) {
            self.red = red
            self.green = green
            self.blue = blue
            self.alpha = alpha
        }
    }
    
}

class ThemeStore: ObservableObject {
    typealias RGBAColor = MemoryTheme.RGBAColor
    
    let name: String
    
    @Published var themes = [MemoryTheme]() {
        didSet {
            storeInUserDefault()
        }
    }
    
    private var storeDefaultsKet: String {
        "ThemeStore:" + name
    }
    
    private func storeInUserDefault() {
        UserDefaults.standard.set(try? JSONEncoder().encode(themes), forKey: storeDefaultsKet)
    }
    
    private func restoreFromeUserDefaults() {
        if let jsonData = UserDefaults.standard.data(forKey: storeDefaultsKet),
           let decodedThemes = try? JSONDecoder().decode(Array<MemoryTheme>.self, from: jsonData) {
            themes = decodedThemes
        }
    }
    
    init(named name: String) {
        self.name = name
        restoreFromeUserDefaults()
        if themes.isEmpty {
            insertTheme(
                named: "Picnic",
                emojis: "🍎🍌🍇🍓🥐🥯🥓🌭🍔🍟🍕🥪🌮🌯🍦🍬🍩🧃🥤🧋🥡",
                numberOfPairs: 10,
                color: .blue
            )
            insertTheme(
                named: "Olympic Games",
                emojis: "🏟🎾⚽️🏐🏓🏸🏒🏹🥊🥋⛸🎿🏊🏻‍♀️🚵🏆🥇🥈🥉",
                numberOfPairs: 10,
                color: .red
            )
            insertTheme(
                named: "Travel",
                emojis: "🚌🚲🚞🛩⛵️🛳🚏🗺🗽🗼🏖🏕🌁🧭📸🛎🚩🎒",
                numberOfPairs: 10,
                color: .orange
            )
            insertTheme(
                named: "Animals",
                emojis: "🐶🐭🐰🦊🐼🐯🦁🐷🐮🐵🐸🦉🦇🐝🦋🐞🪲🕷🐢🐍🐙🐳🦈🐠🦭🦓🐫🐓🦔",
                numberOfPairs: 10,
                color: .yellow
            )
            insertTheme(
                named: "Plants",
                emojis: "🌵🌲🌳🌴🌱🌿☘️🍀🎍🪴🍁🍄🪸🌾🌷🌹🪷🌺🌸🌼🌻",
                numberOfPairs: 5,
                color: .green
            )
            insertTheme(
                named: "Hearts",
                emojis: "❤️🧡💛💚💙💜🖤🤍🤎💔❤️‍🔥❤️‍🩹❣️💕💞💓💗💖💘💝",
                numberOfPairs: 10,
                color: .purple
            )
        }
    }
    
    //  MARK: - Intent
    
    func insertTheme(named: String? = nil, emojis: String? = nil, numberOfPairs: Int? = nil, color: RGBAColor? = nil, at index: Int = 0) {
        let unique = (themes.max(by: { $0.id < $1.id })?.id ?? 0) + 1
        let theme = MemoryTheme(name: named ?? "New Theme", emojis: emojis ?? "🆕🆓", numberOfPairs: numberOfPairs ?? 2, color: color ?? .red, id: unique)
        let safeIndex = min(max(index, 0), themes.count)
        themes.insert(theme, at: safeIndex)
    }
    
    func choose(at index: Int) -> MemoryTheme {
        let safeIndex = min(max(index, 0), themes.count - 1)
        return themes[safeIndex]
    }

}

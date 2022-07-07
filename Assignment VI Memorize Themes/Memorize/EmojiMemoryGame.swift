//
//  EmojiMemoryGame.swift
//  Memorize
//
//  Created by Він on 19.08.2021.
//

import SwiftUI

class EmojiMemoryGame: ObservableObject {
    typealias Card = MemoryGame<String>.Card
    
    @Published private var memoryGame: MemoryGame<String>
 
    var cards: Array<MemoryGame<String>.Card> {
        memoryGame.cards
    }
    
    var theme: MemoryTheme {
        didSet {
            if theme != oldValue {
                newGame()
            }
        }
    }
    
    var score: Double {
        memoryGame.score
    }
    
    init(_ theme: MemoryTheme) {
        self.theme = theme
        memoryGame = EmojiMemoryGame.createMemoryGame(byUsing: theme)
    }
    
    static func createMemoryGame(byUsing theme: MemoryTheme) -> MemoryGame<String> {
        var emojis = [String]()
        theme.emojis.forEach({ emojis.append($0.description) })
        return MemoryGame<String>(numberOfPairsOfCards: theme.numberOfPairs) { index in
            emojis[index] }
    }
    
   
//    MARK: - Intent(s)
    func choose(_ card: MemoryGame<String>.Card) {
        memoryGame.choose(card)
    }
    
    func newGame() {
        memoryGame = EmojiMemoryGame.createMemoryGame(byUsing: theme)
    }
}
    

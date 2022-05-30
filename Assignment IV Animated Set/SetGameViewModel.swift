//  
//  SetGameViewModel.swift
//  Set
//
//  Created by Він on 07.11.2021.
//

import SwiftUI

class SetGameViewModel: ObservableObject {
    typealias GameCard = CardsGame.GameCard
    typealias CardContent = Card.Content
    
    @Published private var model: CardsGame
    
    init() {
        model = CardsGame()
        SetGameViewModel.numberOfCardsInDeck = model.deck.count
    }
    
    //    MARK: - Relationship to the model
    private(set) static var numberOfCardsInDeck: Int = 0
    
    var gameCards: [GameCard] {
        table + deck
    }
    
    var deck: [GameCard] {
        model.deck
    }
    
    var discardPile: [GameCard] {
        model.discardPile
    }
    
    var table: [GameCard] {
        model.table
    }
    
    var numberOfCardsToDeal: Int? {
        model.numberOfCardsCanBeOpened
    }
    
    var set: Bool {
        table.contains(where: { $0.gameStatus == .isMatched })
    }
    
    var numberOfSetsFound: Int {
        discardPile.count / 3
    }

    var playerScore: Int {
        model.score
    }
    
    var bonusScore: Int {
        model.bonusScore
    }
    
    var timerLimit: Double {
        model.bonusTimeLimit
    }
    
    var multiplierForBonusScore: Int {
        model.multiplierForBonusScore
    }
    
    var nextBonusScore: Int {
        bonusScore * multiplierForBonusScore
    }
    
    var isConsumingBonusTime: Bool {
        model.isConsumingBonusTime
    }
    
    var bonusReamaining: Double {
        model.bonusReamaining
    }
    
    var bonusTimeRemaining: Double {
        model.bonusTimeRemaining
    }
    
    var newBonusTimer: Bool {
        if isConsumingBonusTime, set {
            return true
        }
        return false
    }
    
    //    MARK: - Intent(s)
    func choose( _ card: GameCard) {
        model.chooseCard(card: card)
    }
    
    func dealMoreCards(){
        model.dealTheCards()
    }
    
    func newGame() {
        model.newGame()
    }
   
    func findSetOnTable() {
        model.cheat()
    }
    
}
//    MARK: - Extension Card Structure
extension Card.Content {
    var numberOfShapes: Int {
        switch self.firstOption {
        case .firstState:
            return 1
        case .secondState:
            return 2
        case .thirdState:
            return 3
        }
    }
    
    enum Shape {
        case diamond
        case squiggle
        case oval
    }
    
    var shape: Shape {
        switch self.secondOption {
        case .firstState:
            return .diamond
        case .secondState:
            return .squiggle
        case .thirdState:
            return .oval
        }
    }
    
    enum Shading {
        case solid
        case striped
        case open
    }
    
    var shading: Shading {
        switch self.thirdOption {
        case .firstState:
            return .solid
        case .secondState:
            return .striped
        case .thirdState:
            return .open
        }
    }
    
    var color: Color {
        switch self.fourthOption {
        case .firstState:
            return .green
        case .secondState:
            return .purple
        case .thirdState:
            return .red
        }
    }
    
}

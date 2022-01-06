//  Game
//  ClassicSetGame.swift
//  Set
//
//  Created by Він on 07.11.2021.
//

import SwiftUI

class ClassicSetGame: ObservableObject {
    typealias Card = SetGame.Card

    init() {
        model = SetGame()
    }
    //    MARK: - Relationship to the model
    @Published private var model: SetGame
    
    var deck : Bool {
        if model.deck.isEmpty {
            return true
        }
        return false
    }
    
    var cards: [Card] {
        model.cardsOnTable
    }
    
    var numberOfSetsFound: Int {
        model.numberOfSetsFound
    }
    
    var scoreFirstPlayer: Int {
        model.score[0]
    }
    
    var scoreSecondPlayer: Int {
        model.score[1]
    }
    
    var actviveAnotherPlayer: Color {
        if model.firstPlayer {
            return Color.blue
        }
        return Color.green
    }
    
    //    MARK: - Intent(s)
    func choose( _ card: Card) {
        model.choose(card)
    }
    
    func dealThreeMoreCard() {
        model.dealThreeMoreCard()
    }
    
    func newGame() {
        model = SetGame()
    }
   
    func findSetOnTable() {
        model.autoSelectSet()
    }
    func anotherPlayer() {
        model.anotherPlayer()
    }
}

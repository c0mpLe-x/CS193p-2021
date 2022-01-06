//  Model
//  SetGame.swift
//  Set
//
//  Created by Він on 07.11.2021.
//

import Foundation

struct SetGame {
    private(set) var deck: [Card]
    private(set) var cardsOnTable: [Card]
    private(set) var numberOfSetsFound: Int
    private(set) var score: [Int]
    private(set) var firstPlayer: Bool
    private var extraScoreTimer: Date
    
    private var indexesOfChosenCards: [Int] {
       cardsOnTable.indices.filter { cardsOnTable[$0].isChoosen }
    }
    
    private var cardIndexForSetOnTheTable: [Int]? {
        for firstCard in 0..<cardsOnTable.count - 2 {
            for secondCard in (firstCard + 1)..<cardsOnTable.count - 1 {
                for thirdCard in (secondCard + 1)..<cardsOnTable.count {
                    if checkForMatches(cardsOnTable[firstCard].numberOfSymbol, cardsOnTable[secondCard].numberOfSymbol, cardsOnTable[thirdCard].numberOfSymbol),
                       checkForMatches(cardsOnTable[firstCard].color, cardsOnTable[secondCard].color, cardsOnTable[thirdCard].color),
                       checkForMatches(cardsOnTable[firstCard].symbol, cardsOnTable[secondCard].symbol, cardsOnTable[thirdCard].symbol),
                       checkForMatches(cardsOnTable[firstCard].shading, cardsOnTable[secondCard].shading, cardsOnTable[thirdCard].shading)
                    {
                        return [firstCard, secondCard, thirdCard]
                    }
                }
            }
        }
        return nil
    }
 
    mutating func choose( _ card: Card) {
        if replaceSetFromTheTable() {
            extraScoreTimer = Date(timeIntervalSinceNow: 20)
            numberOfSetsFound += 1
        }
        if let indexOfChoosenCard = cardsOnTable.firstIndex(where: { $0.id == card.id}),
            !cardsOnTable[indexOfChoosenCard].isMatched {
           if indexesOfChosenCards.count == 2,
              !cardsOnTable[indexOfChoosenCard].isChoosen
           {
               cardsOnTable[indexOfChoosenCard].isChoosen = true
               if checkSetInChoosenCards() {
                   indexesOfChosenCards.forEach { cardsOnTable[$0].isMatched = true }
                   cardsOnTable.indices.forEach( { cardsOnTable[$0].isChoosen = false } )
                   if extraScoreTimer >= Date.now {
                      scoreOfChoosenPlayer(point: Int(Date.now.distance(to: extraScoreTimer)))
                   }
                   scoreOfChoosenPlayer(point: 3)
                   firstPlayer = true
               } else {
                   indexesOfChosenCards.forEach { cardsOnTable[$0].isNotMatched = true }
                   cardsOnTable.indices.forEach( { cardsOnTable[$0].isChoosen = false } )
                   scoreOfChoosenPlayer(point: -1)
                   firstPlayer = true
               }
           } else {
               if cardsOnTable[indexOfChoosenCard].isChoosen {
                   cardsOnTable[indexOfChoosenCard].isChoosen = false
               } else {
                   cardsOnTable[indexOfChoosenCard].isChoosen = true
               }
               cardsOnTable.indices.forEach { cardsOnTable[$0].isNotMatched = false }
           }
       }
    }
    private mutating func scoreOfChoosenPlayer(point: Int) {
        if point > 0 {
            if firstPlayer {
                score[0] += point
            } else {
                score[1] += point
            }
        }
        if point < 0 {
            if firstPlayer {
                score[0] -= (-point)
            } else {
                score[1] -= (-point)
            }
        }
    }
    
    mutating func anotherPlayer() {
        firstPlayer = false
    }
    
    mutating func autoSelectSet() {
        if cardsOnTable.first(where: { $0.isMatched }) == nil {
            if let autoSelectCard = cardIndexForSetOnTheTable {
                cardsOnTable.indices.forEach { cardsOnTable[$0].isNotMatched = false }
                cardsOnTable.indices.forEach( { cardsOnTable[$0].isChoosen = false } )
                autoSelectCard.forEach { cardsOnTable[$0].isMatched = true }
            }
        }
    }
    
    mutating func dealThreeMoreCard() {
        if !replaceSetFromTheTable() {
            if cardIndexForSetOnTheTable != nil {
                score.indices.forEach({ score[$0] -= 3 })
            }
            for _ in 0..<3 {
                if let moreCard = deck.first {
                    cardsOnTable.append(moreCard)
                    deck.removeFirst()
                }
            }
        } else {
            numberOfSetsFound += 1
        }
    }
    
    private mutating func replaceSetFromTheTable() -> Bool {
        var beenReplacedCards = false
        for card in cardsOnTable.indices {
            if cardsOnTable[card].isMatched == true {
                if !deck.isEmpty {
                    cardsOnTable[card] = deck.removeFirst()
                }
                beenReplacedCards = true
            }
        }
        cardsOnTable = cardsOnTable.filter( { $0.isMatched == false } )
        return beenReplacedCards
    }
    
    private mutating func checkSetInChoosenCards() -> Bool {
        if checkForMatches(firstOfChoosen.numberOfSymbol, secondOfChoosen.numberOfSymbol, thirdOfChoosen.numberOfSymbol),
           checkForMatches(firstOfChoosen.color, secondOfChoosen.color, thirdOfChoosen.color),
           checkForMatches(firstOfChoosen.symbol, secondOfChoosen.symbol, thirdOfChoosen.symbol),
           checkForMatches(firstOfChoosen.shading, secondOfChoosen.shading, thirdOfChoosen.shading)
        {
            return true
        }
        return false
    }
    
    private func checkForMatches<T>(_ a: T, _ b: T, _ c: T) -> Bool where T: Equatable {
            if a == b, b == c {
                return true
            } else if a != b, b != c, a != c {
                return true
            }
            return false
        }
    
    
    init () {
        deck = []
        cardsOnTable = []
        numberOfSetsFound = 0
        score = [0, 0]
        firstPlayer = true
        extraScoreTimer = Date(timeIntervalSinceNow: 20)
        var cardId: Int = 0
        for contentCount in PossibleState.allCases {
            for color in PossibleState.allCases {
                for content in PossibleState.allCases {
                    for shading in PossibleState.allCases {
                        deck.append(Card(numberOfSymbol: contentCount, color: color, symbol: content, shading: shading, id: cardId))
                        cardId += 1
                    }
                }
            }
        }
        deck.shuffle()
        for _ in 0..<12 {
            cardsOnTable.append(deck.removeFirst())
        }
    }
    
    struct Card: Identifiable, Hashable {
        var isMatched = false
        var isNotMatched = false
        var isChoosen = false
        let numberOfSymbol: PossibleState
        let color: PossibleState
        let symbol: PossibleState
        let shading: PossibleState
        let id: Int
    }
}

enum PossibleState: CaseIterable {
    case firstPossibility
    case secondPossibility
    case thirdPossibility
}

private extension SetGame {
    var firstOfChoosen: Card {
       cardsOnTable[indexesOfChosenCards[0]]
    }
    var secondOfChoosen: Card {
        cardsOnTable[indexesOfChosenCards[1]]
    }
    var thirdOfChoosen: Card {
        cardsOnTable[indexesOfChosenCards[2]]
    }
}

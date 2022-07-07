//
//  MemoryGame.swift
//  Memorize
//
//  Created by Він on 19.08.2021.
//

import Foundation

struct MemoryGame <CardContent> where CardContent: Equatable {
    private(set) var cards: Array<Card>
    private(set) var score: Double
    private var seenCards: Set<Int>
    
    private var indexOfTheOneAndOnlyFaceUpCard: Int? {
        get {cards.indices.filter ({cards[$0].isFaceUp}).oneAndOnly}
        set {cards.indices.forEach {cards[$0].isFaceUp = ($0  == newValue)}}
    }
  
    mutating func choose (_ card: Card) {
        if let chosenIndex = cards.firstIndex(where: {$0.id == card.id}),
           !cards[chosenIndex].isFaceUp,
           !cards[chosenIndex].isMatched {
            if let potentialMatchIndex = indexOfTheOneAndOnlyFaceUpCard {
                if cards[chosenIndex].content == cards[potentialMatchIndex].content {
                    cards[chosenIndex].isMatched = true
                    cards[potentialMatchIndex].isMatched = true
                    score += 2 + (cards[chosenIndex].bonusRemaining
                                 + cards[potentialMatchIndex].bonusRemaining)
                }
                if cards[potentialMatchIndex].isMatched {
                    score += 0
                } else if seenCards.contains(potentialMatchIndex) && seenCards.contains(chosenIndex) {
                    score -= 2
                } else if seenCards.contains(potentialMatchIndex) || seenCards.contains(chosenIndex) {
                    score -= 1
                } else {
                    seenCards.insert(chosenIndex)
                    seenCards.insert(potentialMatchIndex)
                }
                cards[chosenIndex].isFaceUp = true
            } else {
                indexOfTheOneAndOnlyFaceUpCard = chosenIndex
            }
        }
    }
    
    init (numberOfPairsOfCards:Int, createCardContent: (Int) -> CardContent) {
        seenCards = []
        score = 0
        cards = []
        for pairIndex in 0..<numberOfPairsOfCards {
            let content = createCardContent (pairIndex)
            cards.append(Card( content: content, id: pairIndex * 2))
            cards.append(Card( content: content, id: pairIndex * 2 + 1))
        }
        cards.shuffle()
    }
    
    struct Card: Identifiable {
        var isFaceUp = false {
            didSet {
                if isFaceUp {
                    startUsingBonusTime()
                } else {
                    stopUsingBonusTime()
                }
            }
        }
        var isMatched = false{
            didSet {
                stopUsingBonusTime()
            }
        }
        let content: CardContent
        let id: Int
        
        // MARK: - Bonus Time
        
        // this could give matching bonus points
        // if the user matches the card
        // before a certain amount of time passes during which the card is face up
        
        // can be zero which means "no bonus available" for this card
        var bonusTimeLimit: TimeInterval = 6
        
        // how long this card has ever been face up
        private var faceUpTime: TimeInterval {
            if let lastFaceUpDate = self.lastFaceUpDate {
                return pastFaceUpTime + Date().timeIntervalSince(lastFaceUpDate)
            } else {
                return pastFaceUpTime
            }
        }
        // the last time this card was turned face up (and is still face up)
        var lastFaceUpDate: Date?
        // the accumulated time this card has been face up in the past
        // (i.e. not including the current time it's been face up if it is currently so)
        var pastFaceUpTime: TimeInterval = 0
        
        // how much time left before the bonus opportunity runs out
        var bonusTimeRemaining: TimeInterval {
            max(0, bonusTimeLimit - faceUpTime)
        }
        // percentage of the bonus time remaining
        var bonusRemaining: Double {
            (bonusTimeLimit > 0 && bonusTimeRemaining > 0) ? bonusTimeRemaining/bonusTimeLimit : 0
        }
        // whether the card was matched during the bonus time period
        var hasEarnedBonus: Bool {
            isMatched && bonusTimeRemaining > 0
        }
        // whether we are currently face up, unmatched and have not yet used up the bonus window
        var isConsumingBonusTime: Bool {
            isFaceUp && !isMatched && bonusTimeRemaining > 0
        }
        
        // called when the card transitions to face up state
        private mutating func startUsingBonusTime() {
            if isConsumingBonusTime, lastFaceUpDate == nil {
                lastFaceUpDate = Date()
            }
        }
        // called when the card goes back face down (or gets matched)
        private mutating func stopUsingBonusTime() {
            pastFaceUpTime = faceUpTime
            self.lastFaceUpDate = nil
        }
    }
}

//
//  CardsGameModel.swift
//  Set
//
//  Created by Він on 29.01.2022.
//

import Foundation

struct Card {
    var isFaceUp: Bool = false
    let content: Content
    
    struct Content: Equatable {
        let firstOption: PossibleState
        let secondOption: PossibleState
        let thirdOption: PossibleState
        let fourthOption: PossibleState
        
        enum PossibleState: CaseIterable {
            case firstState
            case secondState
            case thirdState
        }
    }
}

struct CardsGame {
    
    struct GameCard: Identifiable {
        var card: Card
        var gameStatus: PossibleStatus = .none
        let id: Int
        
        enum PossibleStatus {
            case none
            case isChosen
            case isMatched
            case isMismatched
        }
    }
    
    private(set) var deck = [GameCard]() {
        didSet {
            if let openCard = deck.firstIndex(where: { $0.card.isFaceUp }) {
                if matchedCards.isEmpty {
                    table.append(deck.remove(at: openCard))
                } else {
                    replace(on: deck.remove(at: openCard))
                }
            }
        }
    }
    
    private(set) var table = [GameCard]() {
        didSet {
            if !isConsumingBonusTime {
                resetBonusTime()
            }
            let notMatching = oldValue.filter({ $0.gameStatus == .isMismatched })
            if chosenCards.count == 3 {
                if match(firstCard: chosenCards[0], secondCard: chosenCards[1], thirdCard: chosenCards[2]) {
                    chosenCards.forEach { isMatched(card: $0) }
                    startUsingBonusTime()
                    addBonusScore(bonusScore)
                } else {
                    chosenCards.forEach { isMismatched(card: $0) }
                    score -= bonusScore
                }
            } else if chosenCards.count == 1 && (matchedCards.count == 3 || notMatching.count == 3 ) {
                matchedCards.forEach { discard($0) }
                mismatchedCards.forEach { unstatus(card: $0) }
            }
        }
    }
    
    private(set) var discardPile = [GameCard]()
    private(set) var score: Int = 0
    
    //    MARK: - Bonus Time
    
    var isConsumingBonusTime: Bool {
        if bonusTimeRemaining > 0 {
            return true
        }
        return false
    }
    let bonusScore = 50
    private(set) var multiplierForBonusScore = 1
    private(set) var bonusTimeLimit: TimeInterval = 20
    private(set) var pastBonusTimeRemained: TimeInterval = 0
    private(set) var timerStartDate: Date?
    
    var searchingTime: TimeInterval? {
        if let timerStartDate = timerStartDate {
            return Date().timeIntervalSince(timerStartDate)
        }
        return nil
    }
    
    var bonusTimeRemaining: TimeInterval {
        if let searchingTime = searchingTime {
            return bonusTimeLimit - searchingTime
        }
        return 0
    }
    
    var bonusReamaining: Double {
        (bonusTimeLimit > 0 && bonusTimeRemaining > 0) ? bonusTimeRemaining/bonusTimeLimit : 0
    }
    
    private mutating func addBonusScore(_ number: Int) {
        score += number * multiplierForBonusScore
        multiplierForBonusScore += 1
    }
    
    private mutating func startUsingBonusTime() {
        if timerStartDate == nil {
            timerStartDate = Date.now
        } else {
            continueToUseBonusTime()
        }
    }
    
    private mutating func continueToUseBonusTime() {
        pastBonusTimeRemained = bonusTimeRemaining
        timerStartDate = Date.now
        bonusTimeLimit = 20 + pastBonusTimeRemained
    }
    
    private mutating func resetBonusTime() {
        multiplierForBonusScore = 1
        bonusTimeLimit = 20
        pastBonusTimeRemained = 0
        timerStartDate = nil
    }
    
    //    MARK: - TABLE (Status Cards)
    private var chosenCards: [GameCard] {
        table.filter { $0.gameStatus == .isChosen }
    }
    private var matchedCards: [GameCard] {
        table.filter { $0.gameStatus == .isMatched }
    }
    private var mismatchedCards: [GameCard] {
        table.filter { $0.gameStatus == .isMismatched }
    }
  
    //    MARK: - Typealias
    
    typealias content = Card.Content
    
    //    MARK: - Initialization

    init() {
        newGame()
    }
    
    private mutating func createAllGameCards() -> [GameCard] {
        var allGameCards: [GameCard] = []
        var cardId: Int = 0
        
        for firstOptionState in content.PossibleState.allCases {
            for secondOptionState in content.PossibleState.allCases {
                for thirdOptionState in content.PossibleState.allCases {
                    for fourthOptionState in content.PossibleState.allCases {
                        allGameCards.append(GameCard(
                                card: Card(content: Card.Content(
                                    firstOption: firstOptionState, secondOption: secondOptionState, thirdOption: thirdOptionState, fourthOption: fourthOptionState)),
                                id: cardId))
                        cardId += 1
                    }
                }
            }
        }
        return allGameCards.shuffled()
    }
    //    MARK: - Private metod & computed properties
    
    private mutating func isFaceUp(_ card: GameCard) {
        if let indexOfClosedCard = deck.index(matching: card) {
            deck[indexOfClosedCard].card.isFaceUp = true
        }
    }
    
    private mutating func unstatus(card: GameCard) {
        if let mismatchedCardIndex = table.firstIndex(where: { $0.id == card.id }) {
            table[mismatchedCardIndex].gameStatus = .none
        }
    }
    
    private mutating func discard(_ card: GameCard) {
        if let discardCardIndex = table.firstIndex(where: { $0.id == card.id }) {
            discardPile.append(table.remove(at: discardCardIndex))
        }
    }
    
    private mutating func isMatched(card: GameCard) {
        if let matchedCardIndex = table.firstIndex(where: { $0.id == card.id }) {
            table[matchedCardIndex].gameStatus = .isMatched
        }
    }
    
    private mutating func isMismatched(card: GameCard) {
        if let matchedCardIndex = table.firstIndex(where: { $0.id == card.id }) {
            table[matchedCardIndex].gameStatus = .isMismatched
        }
    }
    
    private mutating func replace(on card: GameCard) {
        if let indexOfReplaceableCard = table.firstIndex(where: { $0.gameStatus == .isMatched }) {
            let replacementCard = table[indexOfReplaceableCard]
            table[indexOfReplaceableCard] = card
            discardPile.append(replacementCard)
        }
    }
    
    var numberOfCardsCanBeOpened: Int? {
        if table.isEmpty, discardPile.isEmpty {
                    return 12
        } else if deck.count >= 3 {
            return 3
        } else if !deck.isEmpty {
            return deck.count
        } else {
            return nil
        }
    }
    
    private func match(firstCard: GameCard, secondCard: GameCard, thirdCard: GameCard ) -> Bool  {
        let firstContentCards = (firstCard.card.content.firstOption, secondCard.card.content.firstOption, thirdCard.card.content.firstOption )
        let secondContentCards = (firstCard.card.content.secondOption, secondCard.card.content.secondOption, thirdCard.card.content.secondOption )
        let thirdContentCards = (firstCard.card.content.thirdOption, secondCard.card.content.thirdOption, thirdCard.card.content.thirdOption )
        let fourthContentCards = (firstCard.card.content.fourthOption, secondCard.card.content.fourthOption, thirdCard.card.content.fourthOption )
        
        
        func contentStateComparison(_ first: Card.Content.PossibleState, _ second: Card.Content.PossibleState, _ third: Card.Content.PossibleState) -> Bool {
             (first == second && second == third ) || (first != second && second != third && first != third)
        }
        if contentStateComparison(firstContentCards.0, firstContentCards.1, firstContentCards.2),
           contentStateComparison(secondContentCards.0, secondContentCards.1, secondContentCards.2),
           contentStateComparison(thirdContentCards.0, thirdContentCards.1, thirdContentCards.2),
           contentStateComparison(fourthContentCards.0, fourthContentCards.1, fourthContentCards.2)
        {
            return true
        }
        return false
    }
    
    private var firstThreeMatchedCards: (GameCard, GameCard, GameCard)? {
        for firstCard in table {
            for secondCard in table {
                for thirdCard in table {
                    if firstCard.id != secondCard.id && firstCard.id != thirdCard.id && secondCard.id != thirdCard.id,
                       match(firstCard: firstCard, secondCard: secondCard, thirdCard: thirdCard) {
                        return (firstCard, secondCard, thirdCard)
                    }
                }
            }
        }
        return nil
    }
   
    //    MARK: - Play solo game
    
    mutating func newGame() {
        table.removeAll()
        discardPile.removeAll()
        score = 0
        resetBonusTime()
        deck = createAllGameCards()
    }
    
    mutating func dealTheCards() {
        if let numberOfCardsCanBeOpened = numberOfCardsCanBeOpened {
            if firstThreeMatchedCards != nil, matchedCards.isEmpty {
                score -= bonusScore
            }
            for _ in 0..<numberOfCardsCanBeOpened {
                isFaceUp(deck.first!)
            }
        }
    }
    
    mutating func chooseCard(card: GameCard) {
        if let indexOfChosenCard = table.index(matching: card),
           table[indexOfChosenCard].gameStatus != .isMatched
        {
            if table[indexOfChosenCard].gameStatus == .isChosen {
                table[indexOfChosenCard].gameStatus = .none
            } else {
                table[indexOfChosenCard].gameStatus = .isChosen
            }
        }
    }
    
    mutating func cheat() {
        if let (firstCard, secondCard, thirdCard) = firstThreeMatchedCards,
           matchedCards.isEmpty
        {
            table.forEach({ unstatus(card: $0) })
            isMatched(card: firstCard)
            isMatched(card: secondCard)
            isMatched(card: thirdCard)
        }
    }
    
}

//    MARK: - Extension(s)

extension Collection where Element: Identifiable {
    func index(matching element: Element) -> Self.Index? {
        firstIndex(where: { $0.id == element.id })
    }
}

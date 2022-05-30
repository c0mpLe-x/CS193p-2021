//
//  SetGameView.swift
//  Set
//
//  Created by Він on 07.11.2021.
//

import SwiftUI

struct SetGameView: View {
    //    MARK: - Game`s properties
    @ObservedObject var game: SetGameViewModel
    @Namespace private var cardRepositionNamespace
    
    //    MARK: - Body
    var body: some View {
        VStack {
            indicatorsBody
            Spacer()
            VStack {
                tableBody
                HStack {
                    deckBody
                    Spacer()
                    bonusTimerBody
                    Spacer()
                    discardPileBody
                }
                .padding(.horizontal)
            }
            HStack {
                newGame
                Spacer()
                findeSetOnTable
            }
            .padding(.horizontal)
        }
    }
   
    //    MARK: - State var(s)
    
    @State private var dealt = Set<Int>()
    @State private var flipped = Set<Int>()
    @State private var discarded = Set<Int>()
    @State private var numberOfLastDealCards: Int = 0
    @State private var degreesForBarCards = randomDegrees(number: SetGameViewModel.numberOfCardsInDeck)
    
    //    MARK: - Private Metods
    private func onTapTableCard(_ card: SetGameViewModel.GameCard) {
        withAnimation {
            if game.set {
                game.choose(card)
                discardPlayedCards()
            } else {
                game.choose(card)
            }
        }
    }
    
    private func onTapDeckCard() {
        let numberOfCardsToDeal = game.numberOfCardsToDeal
        withAnimation {
            if game.set {
                cardReplacement(numberOfCardsToDeal ?? 0)
            } else {
                cardDeal(numberOfCardsToDeal ?? 0)
            }
        }
        numberOfLastDealCards = dealt.count
    }
    
    private func cardDeal(_ number: Int) {
        withAnimation {
            game.dealMoreCards()
            introduceNewGameCards(number)
        }
    }
    
    private func cardReplacement(_ number: Int) {
        withAnimation {
            game.dealMoreCards()
            discardPlayedCards()
            introduceNewGameCards(number)
        }
    }
    
    private func introduceNewGameCards(_ number: Int) {
        for card in game.table {
            withAnimation(dealAnimation(numberOfCards: number )) {
                if isUndealt(card) {
                    deal(card)
                    withAnimation(flipAnimation(numberOfCards: number )) {
                        flip(card)
                    }
                }
            }
        }
    }
    
    private func discardPlayedCards() {
        for discarded in game.discardPile {
            if notDiscarded(discarded) {
                withAnimation(discardAnimation()) {
                    discard(discarded)
                }
            }
        }
    }
    
    private func zIndex(of card: SetGameViewModel.GameCard) -> Double {
        -Double(game.gameCards.firstIndex(where: { $0.id == card.id }) ?? 0)
    }
    
    private func isUndealt(_ card: SetGameViewModel.GameCard) -> Bool {
        !dealt.contains(card.id)
    }
    
    private func notDiscarded(_ card: SetGameViewModel.GameCard) -> Bool {
        !discarded.contains(card.id)
    }
    
    private func deal(_ card: SetGameViewModel.GameCard) {
        dealt.insert(card.id)
    }
    
    private func discard(_ card: SetGameViewModel.GameCard) {
        if let indexForDiscardedCard = dealt.firstIndex(where: { card.id == $0 }),
           let indexForDealtCard = flipped.firstIndex(where: { card.id == $0 })
        {
            dealt.remove(at: indexForDiscardedCard)
            flipped.remove(at: indexForDealtCard)
            discarded.insert(card.id)
        }
        numberOfLastDealCards = dealt.count
    }
    
    private func flip(_ card: SetGameViewModel.GameCard) {
        flipped.insert(card.id)
    }
    
    private func flipAnimation(numberOfCards: Int) -> Animation {
        let totalDelay = Double(numberOfCards) * CardConstants.dealDelayForCard
        let delay = -Double((game.table.count - dealt.count - numberOfCards)) * (totalDelay / Double(numberOfCards))
        return Animation.easeInOut(duration: CardConstants.flipDuration).delay(delay)
        }
    
    private func dealAnimation(numberOfCards: Int) -> Animation {
        let totalDelay = Double(numberOfCards) * CardConstants.dealDelayForCard
        let delay = -Double((game.table.count - dealt.count - numberOfCards)) * (totalDelay / Double(numberOfCards))
        return Animation.easeInOut(duration: CardConstants.dealDuration).delay(delay)
        }
    
    private func discardAnimation() -> Animation {
        let delay = -Double(game.discardPile.count - discarded.count - 3) * (CardConstants.dealDuration / Double(3))
        return Animation.easeInOut(duration: CardConstants.discardDuration).delay(delay)
        }
    
    private static func randomDegrees(number: Int) -> [Double] {
        var degrees: [Double] = []
        for index in 0..<number {
            let randomDouble = Double(Int.random(in: CardConstants.rangeForRandomPosition))
            degrees.insert(randomDouble, at: index)
        }
        return degrees
    }
    
    private func sloppyCardRotation(for card: SetGameViewModel.GameCard) -> Angle {
        let cardIndex = card.id
        let degreeForTheCard: Double? = degreesForBarCards[cardIndex]
        if let degree = degreeForTheCard {
            return Angle(degrees: degree)
        }
        return Angle(degrees: 0)
    }
    
    //    MARK: - Body Views
    
    var tableBody: some View {
        AspectVGrid(items: game.table, aspectRatio: CardConstants.aspectRatio, minWhith: CardConstants.minWhith) { card in
            if isUndealt(card) {
                Color.clear
            } else {
                CardView(gameCard: card, isFaceUp: flipped.contains(card.id) )
                    .statusify(card)
                    .matchedGeometryEffect(id: card.id, in: cardRepositionNamespace)
                    .padding(2)
                    .zIndex(zIndex(of: card))
                    .onTapGesture {
                        onTapTableCard(card)
                    }
            }
        }
        .foregroundColor(CardConstants.color)
    }
        
    var deckBody: some View {
        ZStack {
            ForEach(game.gameCards.filter(isUndealt)) { card in
                CardView(gameCard: card, isFaceUp: false)
                    .rotationEffect(sloppyCardRotation(for: card))
                    .zIndex(zIndex(of: card))
                    .matchedGeometryEffect(id: card.id, in: cardRepositionNamespace)
            }
        }
        .frame(width: CardConstants.undealtWidth, height: CardConstants.undealtHeight)
        .foregroundColor(CardConstants.color)
        .onTapGesture {
           onTapDeckCard()
        }
    }
    
    var discardPileBody: some View {
        ZStack {
            ForEach(game.discardPile) { card in
                if notDiscarded(card) {
                    Color.clear
                } else {
                    CardView(gameCard: card, isFaceUp: true)
                        .matchedGeometryEffect(id: card.id, in: cardRepositionNamespace)
//                        .zIndex(zIndex(of: card))
                        .rotationEffect(sloppyCardRotation(for: card))
                }
            }
        }
        .frame(width: CardConstants.undealtWidth, height: CardConstants.undealtHeight)
    }
    
    var indicatorsBody: some View {
        HStack(spacing: 55.0) {
            VStack(alignment: .leading) {
                Text("Score")
                    .fontWeight(.bold)
                Text("\(game.playerScore)")
            }
            VStack(alignment: .center) {
                Text("Multiplayer")
                    .fontWeight(.bold)
                Text("x\(game.multiplierForBonusScore)")
                    .font(.headline)
                    .foregroundColor(Color.red)
                    .multilineTextAlignment(.center)
            }
            VStack(alignment: .trailing) {
                Text("Found Sets")
                    .fontWeight(.bold)
                Text("\(game.numberOfSetsFound)")
            }
        }
        .padding(.horizontal)
    }
    
    var bonusTimerBody: some View {
        ZStack {
            if game.newBonusTimer {
                TimerView(bonusReamaining: game.bonusReamaining, bonusTimeRemaining: game.bonusTimeRemaining)
            } else if game.isConsumingBonusTime {
                TimerView(bonusReamaining: game.bonusReamaining, bonusTimeRemaining: game.bonusTimeRemaining)
            }
            Text("+\(game.nextBonusScore)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.green)
                .multilineTextAlignment(.center)
                
        }
    }
    
    var newGame: some View {
        Button("\(Image(systemName: "arrow.triangle.2.circlepath.circle")) New Game") {
            withAnimation {
                dealt.removeAll()
                discarded.removeAll()
                flipped.removeAll()
                game.newGame()
                numberOfLastDealCards = 0
                degreesForBarCards = SetGameView.randomDegrees(number: SetGameViewModel.numberOfCardsInDeck)
            }
        }
        .buttonStyle(.bordered)
    }
    
    var findeSetOnTable: some View {
        Button("\(Image(systemName: "binoculars"))Find Set") {
            withAnimation {
                game.findSetOnTable()
            }
        }
        .buttonStyle(.bordered)
    }
    //    MARK: - Card Constant Structure
    
    private struct CardConstants {
        static let minWhith: CGFloat = 70
        static let dealDelayForCard: Double = 0.30
        static let dealDuration: Double = 0.4
        static let flipDuration: Double = 0.6
        static let discardDuration: Double = 0.7
        static let color = Color.pink
        static let aspectRatio: CGFloat = 2/3
        static let undealtHeight: CGFloat = 90
        static let undealtWidth = undealtHeight * aspectRatio
        static var rangeForRandomPosition = -9...9
    }
}


//    MARK: - Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let game = SetGameViewModel()
        SetGameView(game: game)
            .preferredColorScheme(.light)
    }
}

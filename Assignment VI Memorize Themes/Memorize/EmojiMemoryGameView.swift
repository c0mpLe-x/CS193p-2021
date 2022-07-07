//
//  EmojiMemoryGameView.swift
//  Memorize
//
//  Created by Він on 07.07.2021.
//

import SwiftUI

struct EmojiMemoryGameView: View {
    
    @EnvironmentObject var game: EmojiMemoryGame
    
    @Namespace private var dealingNamespace
    
    var body: some View {
        VStack {
            gameBody
        }
        .alert(isPresented: $gameOver) {
            gameOverAlert
        }
        .toolbar {
            ToolbarItem {
                newGame
            }
        }
        .navigationTitle(game.theme.name)
    }
    
    @State var gameOver: Bool = false
    
    private var gameOverAlert: Alert {
        Alert(
            title: Text("Game Over"),
            message: Text("You collected \(game.score) points"),
            dismissButton: .default(Text("Restart")) {
                game.newGame()
            }
        )
    }
    
    var color: Color {
        Color(rgbaColor: game.theme.color)
    }
    
    var gameBody: some View {
        AspectVGrid (items:game.cards,aspectRatio: 2/3) { card in
            if card.isMatched && !card.isFaceUp {
                Color.clear
            } else {
                CardView(card: card)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .padding(4)
                    .transition(AnyTransition
                                .asymmetric(insertion: .identity, removal: .scale))
                    .onTapGesture {
                        withAnimation  {
                            game.choose(card)
                            game.cards.allSatisfy({ $0.isMatched }) ?
                            gameOver = true :
                            nil
                        }
                    }
            }
        }
        .foregroundColor(color)
    }
    
    var newGame: some View {
        Button("New Game") {
            withAnimation {
                game.newGame()
            }
        }
    }
    
    private struct CardConstants {
        static let aspectRatio: CGFloat = 2/3
    }
}

struct CardView: View {
    let card: EmojiMemoryGame.Card
    @State private var animatedBonusRemaining = 0.0
    
    var body: some View {
        GeometryReader{ geometry in
            ZStack {
                Group {
                    if card.isConsumingBonusTime {
                        Pie(startAngle: Angle(degrees: 0 - 90),
                            endAngle: Angle(degrees: (1 - animatedBonusRemaining) * 360 - 90 ))
                            .onAppear {
                                animatedBonusRemaining = card.bonusRemaining
                                withAnimation(.linear(duration: card.bonusTimeRemaining)) {
                                    animatedBonusRemaining = 0
                                }
                            }
                    } else {
                        Pie(startAngle: Angle(degrees: 0 - 90),
                            endAngle: Angle(degrees: (1 - card.bonusRemaining) * 360 - 90 ))
                        
                    }
                }
                .padding(5)
                .opacity(0.6)
                Text(card.content)
                    .rotationEffect(Angle.degrees(card.isMatched ? 360 : 0))
                    .animation(Animation.linear(duration: 1)
                                .repeatForever(autoreverses: false))
                    .font(Font.system(size: DrawingConstants.fontSize))
                    .scaleEffect(scale (thatFits: geometry.size))
            }
            .cardify(isFaceUp: card.isFaceUp)
        }
    }
    
    private func scale(thatFits size: CGSize) -> CGFloat {
        min(size.width, size.height) / (DrawingConstants.fontSize / DrawingConstants.fontScale)
    }
    
    private struct DrawingConstants {
        static let fontScale:CGFloat = 0.7
        static let fontSize: CGFloat = 32
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let store = ThemeStore(named: "Game").choose(at: 0)
        let game = EmojiMemoryGame(store)
        EmojiMemoryGameView()
            .environmentObject(game)
    }
}

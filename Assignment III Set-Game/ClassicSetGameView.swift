//
//  ContentView.swift
//  Set
//
//  Created by Він on 07.11.2021.
//

import SwiftUI

struct ClassicSetGameView: View {
    @ObservedObject var game: ClassicSetGame

    var body: some View {
        VStack {
            Button(action: { game.anotherPlayer() } ) {
                Text("\(Image(systemName: "person.2.circle")) Another Player")
            }.buttonStyle(.bordered).rotationEffect(.degrees(180)).buttonStyle(.bordered).foregroundColor(game.actviveAnotherPlayer)
            Button(action: { game.newGame() } ) {
                Text("\(Image(systemName: "arrow.triangle.2.circlepath.circle")) New Game")
            }.buttonStyle(.bordered)
            Spacer()
            HStack {
                Text("Found Sets: \(game.numberOfSetsFound)")
                Spacer()
                Text("Score: \(game.scoreSecondPlayer)")
            }.rotationEffect(.degrees(180))
            AspectVGrid(items: game.cards, aspectRatio: 2/3, minWhith: 70) { card in
                CardView(card: card)
                    .padding(2)
                    .onTapGesture {
                        game.choose(card)
                    }
            }
            VStack {
                HStack {
                    Text("Found Sets: \(game.numberOfSetsFound)")
                    Spacer()
                    Text("Score: \(game.scoreFirstPlayer)")
                }
                HStack {
                    Button(action: { game.dealThreeMoreCard() }) {
                        Text("\(Image(systemName: "plus.rectangle.portrait")) Deal 3 More Cards")
                    }.disabled(game.deck)
                    Spacer()
                    Button(action: { game.findSetOnTable() }) {
                        Text("\(Image(systemName: "binoculars"))Find Set on Table")
                    }
                }
                .buttonStyle(.bordered)
            .padding(.horizontal, 5.0)
            }
        }
    }
}

struct CardView: View {
    var card: ClassicSetGame.Card
    
    var body: some View {
            ZStack {
                let shape = RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius)
                let content = CardContent(card: card)
                if card.isChoosen {
                    shape.stroke(lineWidth: 4).foregroundColor(.orange)
                    content
                } else {
                    shape.stroke(lineWidth: DrawingConstants.lineWidth).foregroundColor(.gray)
                    content
                }
                if card.isNotMatched {
                    shape.foregroundColor(.red).opacity(0.2)
                    shape.stroke(lineWidth: DrawingConstants.lineWidth).foregroundColor(.gray)
                    content
                }
                if card.isMatched {
                    shape.foregroundColor(.green).opacity(0.2)
                    shape.stroke(lineWidth: DrawingConstants.lineWidth).foregroundColor(.gray)
                    content
                }
            }
    }

    private func font(in size: CGSize) -> Font {
        Font.system(size: min(size.width, size.height) * DrawingConstants.fontScale)
    }

    private struct DrawingConstants {
        static let cornerRadius: CGFloat = 8
        static let lineWidth: CGFloat = 2
        static let fontScale: CGFloat = 0.3
        static let degrees: Double = 270
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let game = ClassicSetGame()
        ClassicSetGameView(game: game)
    }
}

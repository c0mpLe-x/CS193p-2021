//
//  CardContent.swift
//  Set
//
//  Created by Він on 13.12.2021.
//

import SwiftUI

struct CardContent: View {
    var card: SetGame.Card
    
    var body: some View {
        VStack {
            let color = getColor(card.color)
            let shapeCount = 0..<getShapeCount(card.numberOfSymbol)
            Spacer()
            ForEach(shapeCount, id: \.self) { shape in
                switch card.symbol {
                case .firstPossibility:
                        getShading(card.shading, for: Diamond())
                case .secondPossibility:
                        getShading(card.shading, for: Squiggle())
                case .thirdPossibility:
                        getShading(card.shading, for: RoundedRectangle(cornerRadius: 20))
                }
            }
            .foregroundColor(color)
            .aspectRatio(2/1, contentMode: .fit)
            Spacer()
        }
        .padding()
    }
    
   private func getColor( _ color: PossibleState) -> Color {
        switch color {
            case .firstPossibility:
                return Color.green
            case .secondPossibility:
                return Color.blue
            case .thirdPossibility:
                return Color.red
        }
    }
    
    private func getShapeCount( _ count: PossibleState) -> Int  {
        switch count {
        case .firstPossibility:
            return 1
        case .secondPossibility:
            return 2
        case .thirdPossibility:
            return 3
        }
    }
   
    @ViewBuilder
    private func getShading<T>( _ shading: PossibleState, for symbol: T) -> some View where T: Shape  {
        switch shading {
        case .firstPossibility:
             symbol.strokedSymbol
        case .secondPossibility:
             symbol.stripedSymbol
        case .thirdPossibility:
             symbol.filledSymbol
        }
    }
}

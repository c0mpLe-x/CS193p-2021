//
//  CardContent.swift
//  Set
//
//  Created by Він on 13.12.2021.
//

import SwiftUI

struct CardView: View {
    var gameCard: SetGameViewModel.GameCard
    var isFaceUp: Bool
    
    var body: some View {
        GeometryReader { geometry in
            let itemWidth = getItemWidth(geometry.size)
            VStack(spacing: itemWidth / CardViewConstant.spacing) {
                let color = gameCard.card.content.color
                let shapeCount = gameCard.card.content.numberOfShapes
                let shape = gameCard.card.content.shape
                let shading = gameCard.card.content.shading
                Spacer()
                ForEach(0..<shapeCount, id: \.self) { _ in
                    switch shape {
                    case .diamond:
                        shadeTheShape(shape: Diamond(), by: shading)
                    case .squiggle:
                        shadeTheShape(shape: Squiggle(), by: shading)
                    case .oval:
                        shadeTheShape(shape: RoundedRectangle(cornerRadius: 25), by: shading)
                    }
                }
                .aspectRatio(CardViewConstant.aspectRatio, contentMode: .fit)
                .frame(width: geometry.size.width, height: itemWidth)
                .foregroundColor(color)
                Spacer()
            }
        }
        .cardify(isFaceUp: isFaceUp)
    }
    
    private func getItemWidth(_ size: CGSize) -> CGFloat {
        size.height / 3 * 0.6
    }

    @ViewBuilder
    private func shadeTheShape<T>(shape: T, by shading: SetGameViewModel.CardContent.Shading ) -> some View where T: Shape  {
        switch shading {
        case .solid:
            shape.solidShading
        case .striped:
            shape.stripedShading
        case .open:
            shape.openShading
        }
    }
    
    struct CardViewConstant {
        static let spacing: Double = 3
        static let aspectRatio: CGFloat = 2
    }
}

extension Shape {
    var solidShading: some View {
        self.stroke(lineWidth: 1)
    }
    var stripedShading: some View {
        ZStack {
            self.stroke(lineWidth: 1)
            self.fill()
        }
    }
    var openShading: some View {
        ZStack {
            StripedRectangle().stroke(lineWidth: 0.5).clipShape(self)
            self.stroke(lineWidth: 1)
        }
    }
}

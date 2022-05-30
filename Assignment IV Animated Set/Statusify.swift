//
//  CardStatusView.swift
//  Set
//
//  Created by Він on 15.02.2022.
//

import SwiftUI

struct Statusify: AnimatableModifier {
    var status: SetGameViewModel.GameCard.PossibleStatus
    var scale: Double
    var rotation: Double
    
    init(card: SetGameViewModel.GameCard) {
        self.status = card.gameStatus
        scale = status == .isMismatched ? 1 : 0.988
        rotation = status == .isMatched ? 360 : 0
    }
    
    var animatableData: Double {
        get { scale }
        set { scale = newValue }
    }
     
    func body(content: Content) -> some View {
        ZStack {
            content
            let shape = RoundedRectangle(cornerRadius:DrawingConstants.cornerRadius)
            switch status {
            case .isChosen:
                shape.stroke(lineWidth: DrawingConstants.lineWidthStatus).foregroundColor(DrawingConstants.chosenColor)
            case .isMatched:
                shape.stroke(lineWidth: DrawingConstants.lineWidthStatus).foregroundColor(DrawingConstants.mathedColor)
            case .isMismatched:
                ZStack {
                    shape.stroke(lineWidth: DrawingConstants.lineWidthStatus)
                    shape.fill().opacity(0.1)
                }
                .foregroundColor(DrawingConstants.mismathedColor)
                .transition(AnyTransition.asymmetric(insertion: .scale(scale: scale).animation(.easeInOut(duration: 1).repeatForever(autoreverses: true).speed(5)), removal: .identity.animation(.easeInOut(duration: 1))))
            default: shape.opacity(0)
            }
        }
        .rotationEffect(Angle(degrees: rotation)).animation(.easeInOut(duration: 1), value: rotation)
    }
    
    private struct DrawingConstants {
        static let mathedColor: Color = .green
        static let mathedRotation = Angle(degrees: 30)
        static let mismathedColor: Color = .red
        static let chosenColor: Color = .orange
        static let color: Color = .gray
        static let cornerRadius: CGFloat = 8
        static let lineWidth: CGFloat = 0.8
        static let lineWidthStatus: CGFloat = 3
    }
}

extension View {
    func statusify(_ card: SetGameViewModel.GameCard) -> some View {
        self.modifier(Statusify(card: card))
    }
}

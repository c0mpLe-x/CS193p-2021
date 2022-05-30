//
//  Cardify.swift
//  Set
//
//  Created by Він on 15.01.2022.
//

import SwiftUI

struct Cardify: AnimatableModifier {
    var rotation: Double
    
    init(isFaceUp: Bool) {
        rotation = isFaceUp ? 0 : 180
    }
    
    var animatableData: Double {
        get { rotation }
        set { rotation = newValue }
    }
    
    func body(content: Content) -> some View {
        ZStack {
            let shape = RoundedRectangle(cornerRadius:DrawingConstants.cornerRadius)
            if  rotation < 90 {
                shape.fill().foregroundColor(.white)
                shape.strokeBorder(lineWidth: DrawingConstants.lineWidthForCardFront).foregroundColor(DrawingConstants.color)
            } else {
                shape.fill()
                shape.strokeBorder(lineWidth: DrawingConstants.lineWidthForCardBack).foregroundColor(DrawingConstants.color)
            }
            content.opacity(rotation < 90 ? 1 : 0)
        }
        .rotation3DEffect(Angle.degrees(rotation), axis: (0, 1, 0))
    }
    
    private struct DrawingConstants {
        static let cornerRadius: CGFloat = 8
        static let lineWidthForCardBack: CGFloat = 0.8
        static let lineWidthForCardFront: CGFloat = 1
        static let color: Color = .gray
    }
}

extension View {
    func cardify(isFaceUp: Bool) -> some View {
        self.modifier(Cardify(isFaceUp: isFaceUp))
    }
}

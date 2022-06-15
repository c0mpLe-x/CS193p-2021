//
//  AnimatableSystemFontModifier.swift
//  EmojiArt
//
//  Created by Він on 14.06.2022.
//

import SwiftUI

struct AnimatableSystemFontModifier: Animatable, ViewModifier {
    var fontSize: CGFloat
    
    var animatableData: CGFloat {
        get { fontSize }
        set { fontSize = newValue }
    }
    
    func body(content: Content) -> some View {
        content.font(.system(size: fontSize))
    }
    
}

extension View {
    func animatableSystemFontModifier(fontSize: CGFloat) -> some View {
        self.modifier(AnimatableSystemFontModifier(fontSize: fontSize ))
    }
}

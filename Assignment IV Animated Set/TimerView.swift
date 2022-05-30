//
//  TimerView.swift
//  Set
//
//  Created by Він on 27.05.2022.
//

import SwiftUI

struct TimerView: View {
    @State private var animatedBonusRemaining: Double = 0
    
    var bonusReamaining: Double
    var bonusTimeRemaining: Double
    
    var body: some View {
        Pie(startAngle: Angle(degrees: 0-90), endAngle: Angle(degrees: (1-animatedBonusRemaining)*360-90))
            .onAppear {
                animatedBonusRemaining = bonusReamaining
                withAnimation(.linear(duration: bonusTimeRemaining)) {
                    animatedBonusRemaining = 0
                }
            }
        .frame(width: 70, height: 70)
        .padding(10)
        .foregroundColor(.red)
        .opacity(0.6)
        .blur(radius: 2)
    }
    
}

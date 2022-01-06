//
//  Extensions.swift
//  Set
//
//  Created by Він on 11.12.2021.
//

import SwiftUI

extension Shape {
    var strokedSymbol: some View {
        self.stroke(lineWidth: 1)
    }
    var filledSymbol: some View {
        ZStack {
            self.stroke(lineWidth: 1)
            self.fill()
        }
    }
    var stripedSymbol: some View {
        ZStack {
            StripedRectangle().stroke(lineWidth: 0.5).clipShape(self)
            self.stroke(lineWidth: 1)
        }
    }
}

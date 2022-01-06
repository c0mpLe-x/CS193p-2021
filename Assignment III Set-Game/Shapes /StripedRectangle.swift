//
//  SymbolStyle.swift
//  Set
//
//  Created by Він on 14.11.2021.
//

import SwiftUI

struct StripedRectangle: Shape {
    let spacing: CGFloat = 2.5
    
    func path(in rect: CGRect) -> Path {
        let startPoint = CGPoint(x: rect.minX, y: rect.minY)
        var p = Path()
    
        p.move(to: startPoint)
        while p.currentPoint!.x < rect.maxX {
            p.addLine(to: CGPoint(x: p.currentPoint!.x, y: rect.maxY))
            p.move(to: CGPoint(x: p.currentPoint!.x + spacing, y: rect.minY))
        }
        
        return p
    }
    

}

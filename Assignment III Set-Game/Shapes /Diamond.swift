//
//  Diamond.swift
//  Set
//
//  Created by Він on 02.12.2021.
//

import SwiftUI

struct Diamond: Shape {
    
    func path(in rect: CGRect) -> Path {
        let rightPoint = CGPoint(x: rect.maxX, y: rect.midY)
        let leftPoint = CGPoint(x: rect.minX, y: rect.midY)
        let buttomPoint = CGPoint(x: rect.midX, y: rect.minY)
        let topPoint = CGPoint(x: rect.midX, y: rect.maxY)
        
        
        var p = Path()
        p.move(to: topPoint)
        p.addLine(to: leftPoint)
        p.addLine(to: buttomPoint)
        p.addLine(to: rightPoint)
        p.addLine(to: topPoint)
        
        return p
    }
    
}

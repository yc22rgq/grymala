//
//  VectorView.swift
//  grymala
//
//  Created by Эдуард Кудянов on 26.03.25.
//

import SwiftUI

struct VectorView: View {
    let vector: VectorModel
    let offset: CGSize
    
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: vector.start.x + offset.width, y: vector.start.y + offset.height))
            path.addLine(to: CGPoint(x: vector.end.x + offset.width, y: vector.end.y + offset.height))
        }
        .stroke(vector.color, lineWidth: 3)
        .overlay(
            ArrowHead(at: vector.end, color: vector.color, offset: offset)
        )
    }
}

struct ArrowHead: View {
    let at: CGPoint
    let color: Color
    let offset: CGSize
    
    var body: some View {
        Triangle()
            .fill(color)
            .frame(width: 10, height: 10)
            .position(x: at.x + offset.width, y: at.y + offset.height)
    }
}

/// Треугольник для обозначения стрелки
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

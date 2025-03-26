//
//  VectorModel.swift
//  grymala
//
//  Created by Эдуард Кудянов on 26.03.25.
//

import Foundation
import SwiftUI

/// Модель вектора в 2D-пространстве
struct VectorModel: Identifiable {
    let id = UUID()
    var start: CGPoint
    var end: CGPoint
    var color: Color
}

extension Color {
    static var random: Color {
        return Color(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1)
        )
    }
}

extension VectorModel {
    var length: CGFloat {
        sqrt(pow(end.x - start.x, 2) + pow(end.y - start.y, 2))
    }
    
    /// Центр вектора
    var center: CGPoint {
        CGPoint(x: (start.x + end.x) / 2, y: (start.y + end.y) / 2)
    }
}

extension CGPoint {
    /// Смещает точку на указанный вектор
    func translated(by offset: CGSize) -> CGPoint {
        return CGPoint(x: self.x + offset.width, y: self.y + offset.height)
    }
}

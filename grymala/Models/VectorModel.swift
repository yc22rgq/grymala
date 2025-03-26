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

//
//  VectorModel.swift
//  grymala
//
//  Created by Эдуард Кудянов on 26.03.25.
//

import SwiftUI
import SwiftData

@Model
class VectorModel {
    var id: UUID
    var startX: Double
    var startY: Double
    var endX: Double
    var endY: Double
    var colorHex: String

    init(start: CGPoint, end: CGPoint, color: Color) {
        self.id = UUID()
        self.startX = start.x
        self.startY = start.y
        self.endX = end.x
        self.endY = end.y
        self.colorHex = color.toHex()
    }
    
    var start: CGPoint {
        get { CGPoint(x: startX, y: startY) }
        set { startX = newValue.x; startY = newValue.y }
    }
    
    var end: CGPoint {
        get { CGPoint(x: endX, y: endY) }
        set { endX = newValue.x; endY = newValue.y }
    }
    
    var color: Color {
        get { Color(hex: colorHex) }
        set { colorHex = newValue.toHex() }
    }
}

extension Color {
    static var random: Color {
        Color(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1)
        )
    }
    
    func toHex() -> String {
        let components = UIColor(self).cgColor.components ?? [0, 0, 0]
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
    
    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.currentIndex = hex.index(after: hex.startIndex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
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

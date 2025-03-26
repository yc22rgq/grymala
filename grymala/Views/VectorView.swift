//
//  VectorView.swift
//  grymala
//
//  Created by Эдуард Кудянов on 26.03.25.
//

import SwiftUI

struct VectorView: View {
    @Binding var vector: VectorModel
    let offset: CGSize
    @State private var isDragging = false
    @State private var dragStart: CGPoint = .zero
    @State private var dragEnd: CGPoint = .zero
    @State private var isDraggingWholeVector = false
    var isHighlighted: Bool = false
    private let threshold: CGFloat = 20  // Порог прилипания (можно настроить)
    private let angleThreshold: CGFloat = 5  // Погрешность для 90°
    let allVectors: [VectorModel]
    
    var body: some View {
        ZStack {
            // Линия вектора
            Path { path in
                path.move(to: vector.start.translated(by: offset))
                path.addLine(to: vector.end.translated(by: offset))
            }
            .stroke(vector.color, lineWidth: isHighlighted ? 5 : 2)

            // Стрелка
            ArrowHead(at: vector.end, color: vector.color, offset: offset)
            
            // Точки (Начало и Конец)
            Circle()
                .frame(width: 15, height: 15)
                .foregroundColor(.blue)
                .position(vector.start.translated(by: offset))
                .gesture(dragPointGesture(isStart: true))
            
            Circle()
                .frame(width: 15, height: 15)
                .foregroundColor(.red)
                .position(vector.end.translated(by: offset))
                .gesture(dragPointGesture(isStart: false))
            
            // Перетаскивание всего вектора
            Rectangle()
                .frame(width: vector.length, height: 20)
                .position(vector.center.translated(by: offset))
                .opacity(0.001) // Невидимый слой для DragGesture
                .gesture(dragWholeVectorGesture())
        }
    }
    
    /// Жест для перетаскивания начальной или конечной точки с "прилипанием"
    private func dragPointGesture(isStart: Bool) -> some Gesture {
        DragGesture()
            .onChanged { value in
                isDragging = true
                let newPoint = CGPoint(x: value.location.x - offset.width, y: value.location.y - offset.height)
                
                if isStart {
                    vector.start = applySnapping(to: newPoint, relativeTo: vector.end)
                } else {
                    vector.end = applySnapping(to: newPoint, relativeTo: vector.start)
                }
                
                // Проверяем "прилипание" к другим векторам
                vector.start = snapToOtherVectors(vector.start)
                vector.end = snapToOtherVectors(vector.end)
            }
            .onEnded { _ in
                isDragging = false
            }
    }
    
    /// Жест для перетаскивания всего вектора
    private func dragWholeVectorGesture() -> some Gesture {
        LongPressGesture(minimumDuration: 0.3)
            .onEnded { _ in
                isDraggingWholeVector = true
            }
            .simultaneously(with: DragGesture()
                .onChanged { value in
                    if isDraggingWholeVector {
                        let dx = value.translation.width / 40
                        let dy = value.translation.height / 40
                        vector.start.x += dx
                        vector.start.y += dy
                        vector.end.x += dx
                        vector.end.y += dy
                    }
                }
                .onEnded { _ in
                    isDraggingWholeVector = false
                }
            )
    }
    
    /// Проверяет и "прилипает" к вертикали или горизонтали
    private func applySnapping(to point: CGPoint, relativeTo referencePoint: CGPoint) -> CGPoint {
        let dx = abs(point.x - referencePoint.x)
        let dy = abs(point.y - referencePoint.y)

        if dx < threshold {
            return CGPoint(x: referencePoint.x, y: point.y) // Прилипает к вертикали
        } else if dy < threshold {
            return CGPoint(x: point.x, y: referencePoint.y) // Прилипает к горизонтали
        } else {
            return point // Оставляем как есть
        }
    }
    
    /// Проверяет "прилипание" к началу/концу других векторов
    private func snapToOtherVectors(_ point: CGPoint) -> CGPoint {
        for otherVector in allVectors where otherVector.id != vector.id {
            if distance(point, otherVector.start) < threshold {
                return otherVector.start
            }
            if distance(point, otherVector.end) < threshold {
                return otherVector.end
            }
        }
        return point
    }
    
    /// Вычисляет расстояние между двумя точками
    private func distance(_ p1: CGPoint, _ p2: CGPoint) -> CGFloat {
        return sqrt(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2))
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

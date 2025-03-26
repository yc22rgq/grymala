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
            
            // Рисуем квадратик, если угол = 90°
            if let rightAnglePoint = findRightAnglePoint() {
                RightAngleMarker(position: rightAnglePoint.translated(by: offset), size: 30)
            }
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
            }
            .onEnded { _ in
                isDragging = false
            }
    }

    /// Проверяет и "прилипает" к другим векторов и осям
    private func applySnapping(to point: CGPoint, relativeTo referencePoint: CGPoint) -> CGPoint {
        let dx = abs(point.x - referencePoint.x)
        let dy = abs(point.y - referencePoint.y)

        // 1️⃣ Проверяем прилипание к осям
        var snappedPoint = point
        if dx < threshold {
            snappedPoint = CGPoint(x: referencePoint.x, y: point.y) // Прилипает к вертикали
        } else if dy < threshold {
            snappedPoint = CGPoint(x: point.x, y: referencePoint.y) // Прилипает к горизонтали
        }

        // 2️⃣ Проверяем прилипание к другим векторным точкам
        snappedPoint = snapToNearestVectorPoint(snappedPoint)

        return snappedPoint
    }

    /// Проверяет прилипание к ближайшим точкам других векторов
    private func snapToNearestVectorPoint(_ point: CGPoint) -> CGPoint {
        for vector in allVectors {
            let startDistance = distance(point, vector.start)
            let endDistance = distance(point, vector.end)
            
            if startDistance < threshold {
                return vector.start  // Прилипаем к началу другого вектора
            } else if endDistance < threshold {
                return vector.end  // Прилипаем к концу другого вектора
            }
        }
        return point
    }

    /// Вычисляет расстояние между двумя точками
    private func distance(_ p1: CGPoint, _ p2: CGPoint) -> CGFloat {
        return sqrt(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2))
    }
    
    /// Проверяет, есть ли в этом векторе прямой угол с другим вектором
    private func findRightAnglePoint() -> CGPoint? {
        for vector in allVectors {
            if vector.id != self.vector.id {
                if vector.start == self.vector.end {
                    if isRightAngle(vector1: (vector.start, vector.end), vector2: (vector.start, self.vector.start)) {
                        return vector.start
                    }
                }
                if vector.end == self.vector.end {
                    if isRightAngle(vector1: (vector.end, vector.start), vector2: (vector.end, self.vector.start)) {
                        return vector.end
                    }
                }
                if vector.start == self.vector.start {
                    if isRightAngle(vector1: (vector.start, vector.end), vector2: (vector.start, self.vector.end)) {
                        return vector.start
                    }
                }
                if vector.end == self.vector.start {
                    if isRightAngle(vector1: (vector.end, vector.start), vector2: (vector.end, self.vector.end)) {
                        return vector.end
                    }
                }
            }
        }
        return nil
    }
    
    /// Проверяет, образуют ли два вектора угол в 90 градусов
    private func isRightAngle(vector1: (CGPoint, CGPoint), vector2: (CGPoint, CGPoint)) -> Bool {
        let angle = angleBetweenVectors(vector1: vector1, vector2: vector2)
        return abs(angle - 90) < angleThreshold
    }

    /// Вычисляет угол между двумя векторами
    private func angleBetweenVectors(vector1: (CGPoint, CGPoint), vector2: (CGPoint, CGPoint)) -> CGFloat {
        let v1 = CGVector(dx: vector1.1.x - vector1.0.x, dy: vector1.1.y - vector1.0.y)
        let v2 = CGVector(dx: vector2.1.x - vector2.0.x, dy: vector2.1.y - vector2.0.y)

        let dotProduct = v1.dx * v2.dx + v1.dy * v2.dy
        let magnitude1 = sqrt(v1.dx * v1.dx + v1.dy * v1.dy)
        let magnitude2 = sqrt(v2.dx * v2.dx + v2.dy * v2.dy)

        let cosTheta = dotProduct / (magnitude1 * magnitude2)
        return acos(cosTheta) * (180 / .pi)  // Конвертация в градусы
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

struct RightAngleMarker: View {
    let position: CGPoint
    let size: CGFloat

    var body: some View {
        Path { path in
            path.move(to: position)
            path.addLine(to: CGPoint(x: position.x + size, y: position.y))
            path.addLine(to: CGPoint(x: position.x + size, y: position.y + size))
            path.addLine(to: CGPoint(x: position.x, y: position.y + size))
            path.closeSubpath()
        }
        .stroke(Color.black, lineWidth: 2)
        .fill(Color.white)
    }
}

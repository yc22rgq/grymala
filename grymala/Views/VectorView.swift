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
    
    var body: some View {
        ZStack {
            // Линия вектора
            Path { path in
                path.move(to: vector.start.translated(by: offset))
                path.addLine(to: vector.end.translated(by: offset))
            }
            .stroke(vector.color, lineWidth: 2)

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
    
    /// Жест для перетаскивания начальной или конечной точки
    private func dragPointGesture(isStart: Bool) -> some Gesture {
        DragGesture()
            .onChanged { value in
                isDragging = true
                if isStart {
                    vector.start.x = value.location.x - offset.width
                    vector.start.y = value.location.y - offset.height
                } else {
                    vector.end.x = value.location.x - offset.width
                    vector.end.y = value.location.y - offset.height
                }
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
                        let dx = value.translation.width
                        let dy = value.translation.height
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

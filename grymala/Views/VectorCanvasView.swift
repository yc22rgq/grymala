//
//  VectorCanvasView.swift
//  grymala
//
//  Created by Эдуард Кудянов on 26.03.25.
//

import SwiftUI

struct VectorCanvasView: View {
    @State private var vectors: [VectorModel] = []
    @State private var offset: CGSize = .zero
    @State private var showVectorInput = false
    private let gridSize: CGFloat = 40  // Размер клетки

    var body: some View {
        ZStack {
            // Клетчатый фон
            GridBackground(gridSize: gridSize, offset: offset)
            
            // Векторы на экране
            ForEach(vectors) { vector in
                VectorView(vector: vector, offset: offset)
            }

            // Перетаскивание полотна
            .gesture(
                DragGesture()
                    .onChanged { value in
                        offset = CGSize(width: value.translation.width, height: value.translation.height)
                    }
            )
        }
        .overlay(
            Button(action: {
                showVectorInput = true
            }) {
                Image(systemName: "plus")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .shadow(radius: 5)
            }
            .padding(),
            alignment: .bottomTrailing
        )
        .sheet(isPresented: $showVectorInput) {
            VectorInputView { newVector in
                vectors.append(newVector)
            }
        }
    }
}

struct GridBackground: View {
    let gridSize: CGFloat
    let offset: CGSize

    var body: some View {
        Canvas { context, size in
            let columns = Int(size.width / gridSize) + 2
            let rows = Int(size.height / gridSize) + 2
            
            let xOffset = offset.width.truncatingRemainder(dividingBy: gridSize)
            let yOffset = offset.height.truncatingRemainder(dividingBy: gridSize)
            
            // Рисуем вертикальные линии
            for i in 0..<columns {
                let x = CGFloat(i) * gridSize + xOffset
                context.stroke(
                    Path { path in
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: size.height))
                    },
                    with: .color(Color.gray.opacity(0.3)),
                    lineWidth: 1
                )
            }
            
            // Рисуем горизонтальные линии
            for j in 0..<rows {
                let y = CGFloat(j) * gridSize + yOffset
                context.stroke(
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y))
                    },
                    with: .color(Color.gray.opacity(0.3)),
                    lineWidth: 1
                )
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    VectorCanvasView()
}

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
    @State private var showSideMenu = false
    @State private var highlightedVectorID: UUID?
    private let gridSize: CGFloat = 40

    var body: some View {
        ZStack {
            // Клетчатый фон
            GridBackground(gridSize: gridSize, offset: offset)
            
            // Векторы на экране
            ForEach(vectors) { vector in
                VectorView(vector: vector, offset: offset, isHighlighted: highlightedVectorID == vector.id)
            }

            // Перетаскивание полотна
            .gesture(
                DragGesture()
                    .onChanged { value in
                        offset = CGSize(width: value.translation.width, height: value.translation.height)
                    }
            )
            
            // Side-меню (выезжает слева)
            if showSideMenu {
                SideMenuView(vectors: $vectors) { selectedID in
                    highlightVector(selectedID)
                }
            }
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
        .overlay(
            Button(action: {
                withAnimation { showSideMenu.toggle() }
            }) {
                Image(systemName: "list.bullet")
                    .padding()
                    .background(Color.gray.opacity(0.8))
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .shadow(radius: 5)
            }
            .padding(),
            alignment: .topLeading
        )
        .sheet(isPresented: $showVectorInput) {
            VectorInputView { newVector in
                vectors.append(newVector)
            }
        }
    }
    
    /// Подсвечивает вектор на 1 секунду
    private func highlightVector(_ id: UUID) {
        highlightedVectorID = id
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            highlightedVectorID = nil
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

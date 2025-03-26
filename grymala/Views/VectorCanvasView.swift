//
//  VectorCanvasView.swift
//  grymala
//
//  Created by Эдуард Кудянов on 26.03.25.
//

import SwiftUI
import SwiftData

struct VectorCanvasView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var storedVectors: [VectorModel]  // @Query загружает данные
    @State private var vectors: [VectorModel] = []  // Локальное хранилище
    
    @State private var offset: CGSize = .zero
    @State private var showVectorInput = false
    @State private var showSideMenu = false
    @State private var highlightedVectorID: UUID?
    private let gridSize: CGFloat = 40

    var body: some View {
        ZStack {
            GridBackground(gridSize: gridSize, offset: offset)
            
            ForEach(vectors.indices, id: \.self) { index in
                VectorView(vector: binding(for: vectors[index].id), offset: offset, isHighlighted: highlightedVectorID == vectors[index].id)
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        offset = CGSize(width: value.translation.width, height: value.translation.height)
                    }
            )
            
            SideMenuView(isOpen: $showSideMenu, vectors: vectors, onDelete: deleteVector, onSelect: highlightVector)
        }
        .onAppear {
            vectors = storedVectors  // Загружаем векторы при старте
        }
        .overlay(
            Button(action: { showVectorInput = true }) {
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
                modelContext.insert(newVector)  // Сохраняем в SwiftData
                vectors.append(newVector)  // Обновляем локальный список
            }
        }
    }
    
    /// Возвращает `Binding<VectorModel>` для редактирования
    private func binding(for id: UUID) -> Binding<VectorModel> {
        guard let index = vectors.firstIndex(where: { $0.id == id }) else {
            fatalError("Vector not found")  // Ошибка если вектор не найден (не должно происходить)
        }
        return Binding(
            get: { self.vectors[index] },
            set: { self.vectors[index] = $0 }
        )
    }

    private func deleteVector(_ vector: VectorModel) {
        modelContext.delete(vector)
        vectors.removeAll { $0.id == vector.id }
    }

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

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
    
    var body: some View {
        ZStack {
            // Полотно для векторов
            Color.white.ignoresSafeArea()
            
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

#Preview {
    VectorCanvasView()
}

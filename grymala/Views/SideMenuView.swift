//
//  SideMenuView.swift
//  grymala
//
//  Created by Эдуард Кудянов on 26.03.25.
//

import SwiftUI

struct SideMenuView: View {
    @Binding var isOpen: Bool
    var vectors: [VectorModel]
    var onDelete: (VectorModel) -> Void
    var onSelect: (UUID) -> Void

    private let menuWidth = UIScreen.main.bounds.width / 3

    var body: some View {
        GeometryReader { _ in
            ZStack {
                if isOpen {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation { isOpen.toggle() }
                        }
                }
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Векторы")
                            .font(.headline)
                            .padding()

                        List {
                            ForEach(vectors) { vector in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("(\(Int(vector.start.x)), \(Int(vector.start.y))) → (\(Int(vector.end.x)), \(Int(vector.end.y)))")
                                        Text("Длина: \(vector.length, specifier: "%.2f")")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Button(action: { onDelete(vector) }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                }
                                .onTapGesture {
                                    onSelect(vector.id)
                                }
                            }
                        }
                    }
                    .frame(width: menuWidth)
                    .background(Color.white)
                    .transition(.move(edge: .leading))
                    
                    Spacer()
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

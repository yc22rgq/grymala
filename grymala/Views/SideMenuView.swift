//
//  SideMenuView.swift
//  grymala
//
//  Created by Эдуард Кудянов on 26.03.25.
//

import SwiftUI

struct SideMenuView: View {
    @Binding var vectors: [VectorModel]
    var onSelectVector: (UUID) -> Void
    
    private let menuWidth = UIScreen.main.bounds.width / 3

    var body: some View {
        GeometryReader { geometry in
            ZStack {
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
                                    Button(action: {
                                        withAnimation {
                                            vectors.removeAll { $0.id == vector.id }
                                        }
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                }
                                .onTapGesture {
                                    onSelectVector(vector.id)
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

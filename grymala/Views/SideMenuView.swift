//
//  SideMenuView.swift
//  grymala
//
//  Created by Эдуард Кудянов on 26.03.25.
//

import Foundation
import SwiftUI
import SwiftData

struct SideMenuView: View {
    var vectors: [VectorModel]
    var onDelete: (VectorModel) -> Void
    var onSelect: (UUID) -> Void

    private let menuWidth = UIScreen.main.bounds.width / 3

    var body: some View {
        GeometryReader { _ in
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
                                        Text("(\(Double(vector.start.x / 40 + 0.5), specifier: "%.2f"), \(Double(vector.start.y / 40), specifier: "%.2f")) → (\(Double(vector.end.x / 40 + 0.5), specifier: "%.2f"), \(Double(vector.end.y / 40), specifier: "%.2f"))")
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

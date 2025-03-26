//
//  VectorInputView.swift
//  grymala
//
//  Created by Эдуард Кудянов on 26.03.25.
//

import SwiftUI

struct VectorInputView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var startX: String = ""
    @State private var startY: String = ""
    @State private var endX: String = ""
    @State private var endY: String = ""
    var onAdd: (VectorModel) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Начальная точка")) {
                    TextField("X", text: $startX).keyboardType(.decimalPad)
                    TextField("Y", text: $startY).keyboardType(.decimalPad)
                }
                Section(header: Text("Конечная точка")) {
                    TextField("X", text: $endX).keyboardType(.decimalPad)
                    TextField("Y", text: $endY).keyboardType(.decimalPad)
                }
                
                Button("Добавить вектор") {
                    if let sx = Double(startX), let sy = Double(startY),
                       let ex = Double(endX), let ey = Double(endY) {
                        let newVector = VectorModel(
                            start: CGPoint(x: sx, y: sy),
                            end: CGPoint(x: ex, y: ey),
                            color: Color.random
                        )
                        onAdd(newVector)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .navigationTitle("Добавить вектор")
        }
    }
}

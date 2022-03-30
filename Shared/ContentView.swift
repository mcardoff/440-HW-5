//
//  ContentView.swift
//  Shared
//
//  Created by Michael Cardiff on 3/28/22.
//

import SwiftUI

struct ContentView: View {
    @State var stringText = ""
    
    var body: some View {
        TextEditor(text: $stringText)
        
        Button("Calculate", action: calculate)
    }
    
    func calculate() {
        var matrix : [[Double]] = []
        let n = 5
        for i in 0..<n{
            matrix.append((0..<n).map { _ in .random(in: 1...20) })
            stringText += "\(matrix[i])\n"
        }
        
        let evals = diagonalizeExample(arr: matrix)
        stringText += "\n\nEigenvals:\n \(evals)"
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

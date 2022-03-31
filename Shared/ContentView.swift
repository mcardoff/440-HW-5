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
        
        HStack {
            Button("Calculate", action: calculate)
                .padding()
            Button("Clear", action: clearText)
                .padding()
        }
    }
    
    func calculate() {
        let V : PotentialList = getPotential(xMin: 0, xMax: 1.0, steps: 500, choice: .linear, amplitude: 5.0)
        let matrix : [[Double]] = computeHamiltonian(V: V)
        
        for vec in matrix {
            for elem in vec {
                stringText += String(format: "%3.3e ", elem)
            }
            stringText += "\n"
        }
        
        let eigenTuple = diagonalizeExample(arr: matrix)
        stringText += "\n\nEigenvals:\n \(eigenTuple.evals.sorted())\n\n"
        for vec in eigenTuple.evecs {
            stringText += "\(vec)"
            stringText += "\n"
        }
    }
    
    func clearText() {
        stringText = ""
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

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
        let solver = MatrixSolver()
        solver.solveSchrodinger(a: 1.0, steps: 10000, Vt: .linear, potentialAmp: 0.0, energyStates: 5)
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

//
//  InfiniteSquareWellBasis.swift
//  Matrix-Solver
//
//  Created by Michael Cardiff on 3/30/22.
//

import Foundation

let PI = Double.pi

class InfiniteSquareWell: ObservableObject {
    var wellWidth : Double
    var steps : Int
    var numberOfEnergyEVals : Int
    var stepSize : Double
    
    @Published var basisFuncs : [[Double]] = []
    @Published var eigenVals : [Double] = []
    
    let hbar = 1.0, mass = 1.0
    
    init() {
        self.wellWidth = 1.0
        self.numberOfEnergyEVals = 2
        self.steps = 200
        self.stepSize = wellWidth / Double(steps)
    }
    
    init(wellWidth: Double, numberOfEnergyEVals: Int, steps: Int) {
        self.wellWidth = wellWidth
        self.numberOfEnergyEVals = numberOfEnergyEVals
        self.steps = steps
        self.stepSize = wellWidth / Double(steps)
    }
    
    func generateBasisFuncs() {
        for n in 0...numberOfEnergyEVals {
            var psiList : [Double] = []
            for x in stride(from: 0.0, to: self.wellWidth, by: self.stepSize) {
                let norm = sqrt(2.0/wellWidth)
                let arg = (Double(n) * Double.pi) / wellWidth
                psiList.append(norm * sin(arg * x))
            }
            basisFuncs.append(psiList)
            let energy = (hbar*hbar * PI*PI * Double(n*n) / (2.0*mass*wellWidth*wellWidth))
            eigenVals.append(energy)
        }
    }
}

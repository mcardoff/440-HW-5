//
//  InfiniteSquareWellBasis.swift
//  Matrix-Solver
//
//  Created by Michael Cardiff on 3/30/22.
//

import Foundation

let PI = Double.pi

class InfiniteSquareWell: NSObject, ObservableObject {
    var wellWidth : Double
    var steps : Int
    var numberOfEnergyEVals : Int
    var stepSize : Double
    
    @Published var basisFuncs : [[Double]] = []
    @Published var eigenVals : [Double] = []
    @Published var plotBasisFuncs : [[plotDataType]] = []
    
    let hbar = 1.0, mass = 1.0
    
    override init() {
        self.wellWidth = 1.0
        self.numberOfEnergyEVals = 2
        self.steps = 200
        self.stepSize = wellWidth / Double(steps)
        super.init()
    }
    
    init(wellWidth: Double, numberOfEnergyEVals: Int, steps: Int) {
        self.wellWidth = wellWidth
        self.numberOfEnergyEVals = numberOfEnergyEVals
        self.steps = steps
        self.stepSize = wellWidth / Double(steps)
        super.init()
        
        self.generateBasisFuncs()
    }
    
    func generateBasisFuncs() {
        for n in 1...(numberOfEnergyEVals+1) {
            var psiList : [Double] = []
            var psiPlot : [plotDataType] = []
            for x in stride(from: 0.0, to: self.wellWidth, by: self.stepSize) {
                let norm = sqrt(2.0/wellWidth),
                    arg = (Double(n) * Double.pi) / wellWidth,
                    val = norm * sin(arg * x)
                psiList.append(val)
                psiPlot.append([.X: x, .Y: val])
            }
            basisFuncs.append(psiList)
            plotBasisFuncs.append(psiPlot)
            let energy = (hbar*hbar * PI*PI * Double(n*n) / (2.0*mass*wellWidth*wellWidth))
            eigenVals.append(energy)
        }
    }
}

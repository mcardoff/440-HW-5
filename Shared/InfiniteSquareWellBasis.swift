//
//  InfiniteSquareWellBasis.swift
//  Matrix-Solver
//
//  Created by Michael Cardiff on 3/30/22.
//

import Foundation

class InfiniteSquareWell: ObservableObject {
    var wellWidth : Double
    var numberOfEnergyEVals : Int
    
    init() {
        self.wellWidth = 1.0
        self.numberOfEnergyEVals = 2
    }
    
    init(wellWidth: Double, numberOfEnergyEVals: Int) {
        self.wellWidth = wellWidth
        self.numberOfEnergyEVals = numberOfEnergyEVals
    }
}

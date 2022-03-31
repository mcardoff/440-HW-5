//
//  Matrix_SolverApp.swift
//  Shared
//
//  Created by Michael Cardiff on 3/28/22.
//

import SwiftUI

@main
struct Matrix_SolverApp: App {
    
    @StateObject var plotData = PlotClass()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(plotData)
        }
    }
}

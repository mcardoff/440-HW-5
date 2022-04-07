//
//  ContentView.swift
//  Shared
//
//  Created by Michael Cardiff on 3/28/22.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var plotData : PlotClass
    @ObservedObject var solver = MatrixSolver()
    
    @State var selector : Int = 0
    @State var numSteps: Int? = 250
    @State var numStates: Int? = 5
    @State var wellWidth: Double? = 1.0
    @State var amplitude: Double? = 0.0
    @State var eigenvalueText : String = ""
    @State var potentialVal: PotentialType = .square
    @State var emptyPlot : [plotDataType] = []
    
    private var intFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        return f
    }()
    
    private var doubleFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.minimumSignificantDigits = 3
        f.maximumSignificantDigits = 9
        return f
    }()
    
    var body: some View {
        HStack {
            // variables to change: steps, a, potential, energy eigenval, energy search range
            VStack {
                VStack {
                    Text("Number of Steps")
                    TextField("Number of Steps For Potential", value: $numSteps, formatter: intFormatter)
                        .frame(width: 100.0)
                }.padding()
                
                VStack {
                    Text("Number of Eigenstates to use")
                    TextField("This many ISW states", value: $numStates, formatter: intFormatter)
                        .frame(width: 100.0)
                }.padding()
                
                VStack {
                    Text("Well Width")
                    TextField("Goes from [0,a]", value: $wellWidth, formatter: doubleFormatter)
                        .frame(width: 100.0)
                }.padding()
                
                VStack {
                    Text("Potential")
                    Picker("", selection: $potentialVal) {
                        ForEach(PotentialType.allCases) {
                            potential in Text(potential.toString())
                        }
                    }.frame(width: 150.0)
                }.padding()
                
                VStack {
                    Text("Amplitude Parameter")
                    TextField("Amplitude Factor for Potential", value: $amplitude, formatter: doubleFormatter)
                        .frame(width: 100.0)
                }.padding()
                
                Button("Solve", action: self.calculate)
                    .frame(width: 100)
                    .padding()
                
                HStack {
                    Button("+E", action: self.increasesel)
                        .padding()
                    
                    Button("-E", action: self.decreasesel)
                        .padding()
                }
                
                Button("Clear", action: self.clear)
                    .frame(width: 100)
                    .padding()
            }
            TabView {
                CorePlot(
                    dataForPlot: $solver.solvedFuncsRe.count > 0 ? $solver.solvedFuncsRe[selector] : $emptyPlot,
                    changingPlotParameters: $plotData.plotArray[0].changingPlotParameters)
                    .setPlotPadding(left: 10)
                    .setPlotPadding(right: 10)
                    .setPlotPadding(top: 10)
                    .setPlotPadding(bottom: 10)
                    .padding()
                    .tabItem {
                        Text("Wavefunction Plot")
                    }
                
                CorePlot(
                    dataForPlot: $solver.potentialPlot,
                    changingPlotParameters: $plotData.plotArray[0].changingPlotParameters)
                    .setPlotPadding(left: 10)
                    .setPlotPadding(right: 10)
                    .setPlotPadding(top: 10)
                    .setPlotPadding(bottom: 10)
                    .padding()
                    .tabItem {
                        Text("Potential Plot")
                    }
                
                TextEditor(text: $eigenvalueText)
                    .tabItem {
                        Text("Energy Eigenvalues")
                    }
            }
        }
    }
    
    // do all the operations with the eigenvalue text and the plots
    func calculate() {
        self.clear()
        solver.solveSchrodinger(
            a: wellWidth!, steps: numSteps!, Vt: potentialVal, potentialAmp: amplitude!, energyStates: numStates!)
        for i in 0..<solver.energyEigenValues.count {
            self.eigenvalueText += "E_\(i) = \(solver.energyEigenValues[i])\n"
        }
    }
    
    // manipulate which eigenvalue we are viewing
    func increasesel() {
        if selector < $solver.solvedFuncsRe.count - 1 {
            selector += 1
        } else {
            selector = 0
        }
    }
    
    func decreasesel() {
        if selector > 0 {
            selector -= 1
        } else {
            selector = 0
        }
    }
    
    //clear everything
    func clear() {
        selector = 0
        solver.clear()
        eigenvalueText = ""
    }
    
    // if the well width was changed, also change the plot limits
    func setParams() {
        plotData.plotArray[0].changingPlotParameters.xMax = wellWidth! + 0.1
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

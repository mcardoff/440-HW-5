//
//  Tests_macOS.swift
//  Tests macOS
//
//  Created by Michael Cardiff on 3/28/22.
//

import XCTest
import Matrix_Solver

class Tests_macOS: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testHamiltonian() throws {
        let ISW = InfiniteSquareWell(wellWidth: 1.0, numberOfEnergyEVals: 5, steps: 250),
            hamiltonian = computeHamiltonian(squareWellObj: ISW, V: getPotential(squareWellObj: ISW, choice: .square, amplitude: 0.0))
        for i in 0..<hamiltonian.count {
            for j in 0..<hamiltonian.count {
                if i != j { XCTAssertEqual(hamiltonian[i][j], hamiltonian[j][i], accuracy: 1e-10) }
            }
        }
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}

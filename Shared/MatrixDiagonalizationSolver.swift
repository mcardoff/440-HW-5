//
//  MatrixDiagonalizationSolver.swift
//  Matrix-Solver
//
//  Created by Michael Cardiff on 3/30/22.
//

import Foundation
import Accelerate

typealias ComplexTuple = (re: Double, im: Double)

class MatrixSolver: NSObject, ObservableObject {
    
    @Published var solvedFuncsRe : [[plotDataType]] = []
    @Published var solvedFuncsIm : [[plotDataType]] = []
    @Published var potentialPlot : [plotDataType] = []
    @Published var energyEigenValues : [Double] = []
    
    /// solveSchrodinger
    /// Solve the Schrodinger equation in a box of width a, with steps steps, by diagonalizing the hamiltonian H = T + Vt using energyStates eigenstates
    ///
    /// - Parameters:
    ///   - a: The Well width
    ///   - steps: Number of steps to use in generation of ISW states
    ///   - Vt: Potential to use when generating Hamiltonian
    ///   - potentialAmp: Amplitude of potential
    ///   - energyStates: Number of infinite square well states to use
    func solveSchrodinger(a: Double, steps: Int, Vt: PotentialType, potentialAmp: Double, energyStates: Int) {
        let V = getPotential(xMin: 0.0, xMax: a, steps: steps, choice: Vt, amplitude: potentialAmp),
            squareWellObj = InfiniteSquareWell(wellWidth: a, numberOfEnergyEVals: energyStates, steps: steps),
            hamiltonian = computeHamiltonian(squareWellObj: squareWellObj, V: V)
        // diagonalize the hamiltonian
        
        fillPotentialPlot(potential: V)
        
        let eigenTuple = diagonalize(arr: hamiltonian)
        let sortedEigenTuple = eigenSort(evals: eigenTuple.evals, funcs: generateLinearCombinations(squareWellObj: squareWellObj, V: V, evecs: eigenTuple.evecs))
        energyEigenValues.append(contentsOf: sortedEigenTuple.sortedEvals)
        fillSolvedFuncs(xs: V.xs, funcs: sortedEigenTuple.sortedFuncs)
        
        
    }
    
    /// diagonalize
    /// Diagonalizes the array arr returning its eigenvalues and eigenvectors
    ///
    /// - Parameters:
    ///   - arr: 2D array
    /// - Returns: Tuple with the eigenvalues and eigenvectors
    func diagonalize(arr: [[Double]]) -> (evals: [Double], evecs: [[Double]]) {
        // Diagonalize input array
        // Note that arr is a 2D row major array in Swift, convert to column major:
        let flatArr : [Double] = pack2dArray(arr: arr, rows: arr.count, cols: arr.count)
        //    var returnString = ""
        var eigenvals : [Double] = []
        var eigenvecs : [[Double]] = []
        
        var N = Int32(sqrt(Double(flatArr.count)))
        var N2 = Int32(sqrt(Double(flatArr.count)))
        var N3 = Int32(sqrt(Double(flatArr.count)))
        var N4 = Int32(sqrt(Double(flatArr.count)))
        
        var flatArray = flatArr
        
        var error : Int32 = 0
        var lwork = Int32(-1)
        // Real parts of eigenvalues
        var wr = [Double](repeating: 0.0, count: Int(N))
        // Imaginary parts of eigenvalues
        var wi = [Double](repeating: 0.0, count: Int(N))
        // Left eigenvectors
        var vl = [Double](repeating: 0.0, count: Int(N*N))
        // Right eigenvectors
        var vr = [Double](repeating: 0.0, count: Int(N*N))
        
        
        /* Eigenvalue Calculation Uses dgeev */
        /*   int dgeev_(char *jobvl, char *jobvr, Int32 *n, Double * a, Int32 *lda, Double *wr, Double *wi, Double *vl,
         Int32 *ldvl, Double *vr, Int32 *ldvr, Double *work, Int32 *lwork, Int32 *info);*/
        
        /* dgeev_(&calculateLeftEigenvectors, &calculateRightEigenvectors, &c1, AT, &c1, WR, WI, VL, &dummySize, VR, &c2, LWork, &lworkSize, &ok)    */
        /* parameters in the order as they appear in the function call: */
        /* order of matrix A, number of right hand sides (b), matrix A, */
        /* leading dimension of A, array records pivoting, */
        /* result vector b on entry, x on exit, leading dimension of b */
        /* return value =0 for success*/
        
        
        
        /* Calculate size of workspace needed for the calculation */
        
        var workspaceQuery: Double = 0.0
        dgeev_(UnsafeMutablePointer(mutating: ("N" as NSString).utf8String), UnsafeMutablePointer(mutating: ("V" as NSString).utf8String), &N, &flatArray, &N2, &wr, &wi, &vl, &N3, &vr, &N4, &workspaceQuery, &lwork, &error)
        
        //    print("Workspace Query \(workspaceQuery)")
        
        /* size workspace per the results of the query */
        
        var workspace = [Double](repeating: 0.0, count: Int(workspaceQuery))
        lwork = Int32(workspaceQuery)
        
        /* Calculate the size of the workspace */
        
        dgeev_(UnsafeMutablePointer(mutating: ("N" as NSString).utf8String), UnsafeMutablePointer(mutating: ("V" as NSString).utf8String), &N, &flatArray, &N2, &wr, &wi, &vl, &N3, &vr, &N4, &workspace, &lwork, &error)
        
        
        if (error == 0) {
            // transform the returned matrices to eigenvalues and eigenvectors
            for index in 0..<wi.count {
                if (wi[index]>=0.0) {
                    //                returnString += "Eigenvalue\n\(wr[index]) + \(wi[index])i\n\n"
                    eigenvals.append(wr[index])
                } else {
                    //                returnString += "Eigenvalue\n\(wr[index]) - \(fabs(wi[index]))i\n\n"
                    eigenvals.append(wr[index])
                }
                
                //            returnString += "Eigenvector\n"
                //            returnString += "["
                
                
                /* To Save Memory dgeev returns a packed array if complex
                 Must Unpack Properly to Get Correct Result
                 
                 VR is DOUBLE PRECISION array, dimension (LDVR,N)
                 If JOBVR = 'V', the right eigenvectors v(j) are stored one
                 after another in the columns of VR, in the same order
                 as their eigenvalues.
                 If JOBVR = 'N', VR is not referenced.
                 If the j-th eigenvalue is real, then v(j) = VR(:,j),
                 the j-th column of VR.
                 If the j-th and (j+1)-st eigenvalues form a complex
                 conjugate pair, then v(j) = VR(:,j) + i*VR(:,j+1) and
                 v(j+1) = VR(:,j) - i*VR(:,j+1). */
                var tempevecList : [Double] = []
                for j in 0..<N {
                    
                    if(wi[index]==0) {
                        
                        //                    returnString += "\(vr[Int(index)*(Int(N))+Int(j)]) + 0.0i, \n" /* print x */
                        tempevecList.append(vr[Int(index)*(Int(N))+Int(j)])
                        
                    }
                }
                eigenvecs.append(tempevecList)
                
                /* Remove the last , in the returned Eigenvector */
                //            returnString.remove(at: returnString.index(before: returnString.endIndex))
                //            returnString.remove(at: returnString.index(before: returnString.endIndex))
                //            returnString.remove(at: returnString.index(before: returnString.endIndex))
                //            returnString += "]\n\n"
            }
        }
        else {print("An error occurred\n")}
        return (evals: eigenvals, evecs: eigenvecs)
    }
    
    /// computeHamiltonian
    /// Computes the Hamiltonian matrix for the potential V
    ///
    /// - Parameters:
    ///   - squareWellObj: Object containing info like the well width as well as the basis states
    ///   - V: Potential x and function values
    /// - Returns: Hamiltonian matrix in infinite square well basis
    func computeHamiltonian(squareWellObj: InfiniteSquareWell, V: PotentialList) -> [[Double]] {
        // construct the hamiltonian from a potential function V using H_{ij} = <i|H|j>
        
        let basisStates  = squareWellObj.basisFuncs,
            energyStates = squareWellObj.numberOfEnergyEVals,
            a = squareWellObj.wellWidth
        
        var hamiltonian : [[Double]] = []
        
        for i in 0...energyStates {
            var singleHamiltonianRow : [Double] = []
            for j in 0...energyStates {
                let psil = basisStates[j], psir = basisStates[i]
                var mel = matrixElement(psil: psil, V: V, psir: psir, wellwidth: a)
                if i == j {
                    mel -= squareWellObj.eigenVals[i] // diagonal elements will have the kinetic energy
                }
                //            print("H_\(i),\(j)=\(mel)")
                singleHamiltonianRow.append(mel)
            }
            hamiltonian.append(singleHamiltonianRow)
        }
        
        return hamiltonian
        
    }
    
    /// matrixElement
    /// Computes an individual matrix element <psil|T+V|psir> using infinite square well states
    ///
    /// - Parameters:
    ///   - psil: Left eigenfunction
    ///   - V: Potential
    ///   - psir: Right eigenfunction
    ///   - wellWidth: width of the well
    /// - Returns: The matrix element <psil|T+V|psir>
    func matrixElement(psil: [Double], V: PotentialList, psir: [Double], wellwidth: Double) -> Double {
        // convert integral into average value
        // < g | H | f > = \int_0^a dx (g * H * f), = a * <g H f>
        var sum = 0.0
        let vList = V.Vs
        for i in 0..<vList.count {
            let v = vList[i], l = psil[i], r = psir[i]
            sum += l * v * r
        }
        
        // can recover wellwidth from V
        let wellWidth = V.xs.max()! - V.xs.min()!
        // average value thm
        let mel = wellWidth * sum / Double(vList.count)
        
        return mel
    }
    
    /// generateLinearCombinations
    /// creates the linear combinations of eigenfunctions which the function <diagonalize> creates
    ///
    /// - Parameters:
    ///   - squareWellObj: Object containing info like the well width as well as the basis states
    ///   - V: Potential
    ///   - evecs: eigenvectors of the diagonalized hamiltonian
    func generateLinearCombinations(squareWellObj: InfiniteSquareWell, V: PotentialList, evecs: [[Double]]) -> [[Double]] {
        var newFuncs : [[Double]] = []
        for evec in evecs {
            var newEigenFunc = [Double](repeating: 0.0, count: Int(squareWellObj.steps))
            for (coeff,efunc) in zip(evec,squareWellObj.basisFuncs) {
                newEigenFunc = weightedSum(arr: efunc, num: coeff, oldResult: newEigenFunc)
            }
            newFuncs.append(newEigenFunc.reversed())
        }
        newFuncs = normalizeFuncs(squareWellObj: squareWellObj, funcs: newFuncs)
        return newFuncs
    }
    
    /// weightedSum
    /// does the weighted sum for the linear combinations above
    ///
    /// - Parameters:
    ///   - arr: next eigenfunction to add on
    ///   - num: coefficient to multiply everything by in the eigenfunc
    ///   - oldResult: the function so far, without all the eigenfunctions
    /// - Returns: input <oldResult> updated with the new eigenfunc
    func weightedSum(arr: [Double], num: Double, oldResult: [Double]) -> [Double] {
        var newResult : [Double] = []
        for i in 0..<arr.count {
            newResult.append(arr[i] * num + oldResult[i])
        }
        return newResult
    }
    
    /// normalizeFuncs
    /// adjusts amplitude so it is positive when necessary, not really a necessary function...
    ///
    /// - Parameters:
    ///   - squareWellObj: Object containing info like the well width as well as the basis states
    ///   - funcs: functions to normalize
    /// - Returns: normalized functions
    func normalizeFuncs(squareWellObj: InfiniteSquareWell, funcs: [[Double]]) -> [[Double]] {
        var newFuncs : [[Double]] = []
        let a = squareWellObj.wellWidth
        // use average value theorem
        for fun in funcs {
            var normalized : [Double] = [], sumSq = 0.0, sum = 0.0
            for val in fun { sumSq += val*val; sum += val }
            let normVal = a * sumSq / Double(fun.count)
            print(normVal)
            for val in fun {
                var appendVal = val / normVal
                if(sum < 0.0) { appendVal *= -1 }
                normalized.append(appendVal)
            }
            newFuncs.append(normalized)
        }
        return newFuncs
    }
    
    func eigenSort(evals: [Double], funcs: [[Double]]) -> (sortedEvals: [Double], sortedFuncs: [[Double]]) {
        // generate the zipped list:
        var newList : [(Double,[Double])] = []
        for i in 0..<evals.count {
            newList.append((evals[i], funcs[i]))
        }
        
        newList = newList.sorted(by: {t1, t2 in t1.0 > t2.0})
        var retVals : [Double] = [], retFuncs : [[Double]] = []
        for item in newList {
            retVals.append(item.0)
            retFuncs.append(item.1)
        }
        
        return (sortedEvals: retVals, sortedFuncs: retFuncs)
    }
    
    /// pack2DArray
    /// Converts a 2D array into a linear array in FORTRAN Column Major Format
    ///
    /// - Parameters:
    ///   - arr: 2D array
    ///   - rows: Number of Rows
    ///   - cols: Number of Columns
    /// - Returns: Column Major Linear Array
    func pack2dArray(arr: [[Double]], rows: Int, cols: Int) -> [Double] {
        var resultArray = Array(repeating: 0.0, count: rows*cols)
        for Iy in 0...cols-1 {
            for Ix in 0...rows-1 {
                let index = Iy * rows + Ix
                resultArray[index] = arr[Ix][Iy]
            }
        }
        return resultArray
    }
    
    /// unpack2DArray
    /// Converts a linear array in FORTRAN Column Major Format to a 2D array in Row Major Format
    ///
    /// - Parameters:
    ///   - arr: Column Major Linear Array
    ///   - rows: Number of Rows
    ///   - cols: Number of Columns
    /// - Returns: 2D array
    func unpack2dArray(arr: [Double], rows: Int, cols: Int) -> [[Double]] {
        var resultArray = [[Double]](repeating:[Double](repeating:0.0 ,count:rows), count:cols)
        for Iy in 0...cols-1 {
            for Ix in 0...rows-1 {
                let index = Iy * rows + Ix
                resultArray[Ix][Iy] = arr[index]
            }
        }
        return resultArray
    }
    
    /// Create the plotDataType with the Potential Values
    func fillPotentialPlot(potential: PotentialList) {
        for (x, V) in zip(potential.xs, potential.Vs) {
            potentialPlot.append([.X: x, .Y: V])
        }
    }
    
    /// Create the plotDataType with the Potential Values
    func fillSolvedFuncs(xs: [Double], funcs: [[Double]]) {
        for arr in funcs {
            var tempList : [plotDataType] = []
            for (x, v) in zip(xs, arr) {
                tempList.append([.X: x, .Y: v])
            }
            solvedFuncsRe.append(tempList)
        }
    }
    
    /// remove all data, used in ContentView
    func clear() {
        solvedFuncsRe.removeAll()
        solvedFuncsIm.removeAll()
        potentialPlot.removeAll()
        energyEigenValues.removeAll()
    }
    
}

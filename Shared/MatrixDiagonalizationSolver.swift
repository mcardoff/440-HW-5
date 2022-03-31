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
    
    func diagonalize(arr: [[Double]]) -> (evals: [Double], evecs: [[ComplexTuple]]) {
        // Diagonalize input array
        // Note that arr is a 2D row major array in Swift, convert to column major:
        let flatArr : [Double] = pack2dArray(arr: arr, rows: arr.count, cols: arr.count)
        //    var returnString = ""
        var eigenvals : [Double] = []
        var eigenvecs : [[ComplexTuple]] = []
        
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
                var tempevecList : [ComplexTuple] = []
                for j in 0..<N {
                    
                    if(wi[index]==0) {
                        
                        //                    returnString += "\(vr[Int(index)*(Int(N))+Int(j)]) + 0.0i, \n" /* print x */
                        tempevecList.append((re: vr[Int(index)*(Int(N))+Int(j)], im: 0.0))
                        
                    } else if(wi[index]>0) {
                        if(vr[Int(index)*(Int(N))+Int(j)+Int(N)]>=0) {
                            //                        returnString += "\(vr[Int(index)*(Int(N))+Int(j)]) + \(vr[Int(index)*(Int(N))+Int(j)+Int(N)])i, \n"
                            tempevecList.append((re: vr[Int(index)*(Int(N))+Int(j)], im: vr[Int(index)*(Int(N))+Int(j)+Int(N)]))
                        } else {
                            //                        returnString += "\(vr[Int(index)*(Int(N))+Int(j)]) - \(fabs(vr[Int(index)*(Int(N))+Int(j)+Int(N)]))i, \n"
                            tempevecList.append((re: vr[Int(index)*(Int(N))+Int(j)], im: fabs(vr[Int(index)*(Int(N))+Int(j)+Int(N)])))
                        }
                    } else {
                        if(vr[Int(index)*(Int(N))+Int(j)]>0) {
                            //                        returnString += "\(vr[Int(index)*(Int(N))+Int(j)-Int(N)]) - \(vr[Int(index)*(Int(N))+Int(j)])i, \n"
                            tempevecList.append((re: vr[Int(index)*(Int(N))+Int(j)-Int(N)], im: -vr[Int(index)*(Int(N))+Int(j)]))
                        } else {
                            //                        returnString += "\(vr[Int(index)*(Int(N))+Int(j)-Int(N)]) + \(fabs(vr[Int(index)*(Int(N))+Int(j)]))i, \n"
                            tempevecList.append((re: vr[Int(index)*(Int(N))+Int(j)-Int(N)], im: fabs(vr[Int(index)*(Int(N))+Int(j)])))
                        }
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
    
    func solveSchrodinger(a: Double, steps: Int, Vt: PotentialType, potentialAmp: Double, energyStates: Int) {
        let V = getPotential(xMin: 0.0, xMax: a, steps: steps, choice: Vt, amplitude: potentialAmp),
            squareWellObj = InfiniteSquareWell(wellWidth: a, numberOfEnergyEVals: energyStates, steps: steps),
            hamiltonian = computeHamiltonian(squareWellObj: squareWellObj, V: V)
        // diagonalize the hamiltonian
        
        fillPotentialPlot(potential: V)
        
        let eigenTuple = diagonalize(arr: hamiltonian)
        energyEigenValues.append(contentsOf: eigenTuple.evals)
        generateLinearCombinations(squareWellObj: squareWellObj, V: V, evecs: eigenTuple.evecs)
    }
    
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
    
    func generateLinearCombinations(squareWellObj: InfiniteSquareWell, V: PotentialList, evecs: [[ComplexTuple]]) {
        var newFuncs : [[Double]] = []
        for evec in evecs {
            var reeig : [Double] = []
            for item in evec { reeig.append(item.re) }
            var newEigenFunc = [Double](repeating: 0.0, count: Int(squareWellObj.steps))
            for (coeff,efunc) in zip(reeig,squareWellObj.basisFuncs) {
                newEigenFunc = weightedSum(arr: efunc, num: coeff, oldResult: newEigenFunc)
            }
            newFuncs.append(newEigenFunc)
        }
        fillSolvedFuncs(xs: V.xs, funcs: newFuncs)
    }
    
    func weightedSum(arr: [Double], num: Double, oldResult: [Double]) -> [Double] {
        var newResult : [Double] = []
        for i in 0..<arr.count {
            newResult.append(arr[i] * num + oldResult[i])
        }
        return newResult
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
    
    func clear() {
        solvedFuncsRe.removeAll()
        solvedFuncsIm.removeAll()
        potentialPlot.removeAll()
        energyEigenValues.removeAll()
    }
    
}

import Foundation
import MixedTargetWithPublicCXXAPI

public struct CxxInterop {

    public func callOtherCxxFunction(x: Int32, y: Int32) -> Int {
        var sumFinder = CXXSumFinder()
        return sumFinder.sum(x, y)
    }

    public func callCxxFunction(n: Int32) -> Int32 {
        return cxxFunction(n)
    }
}

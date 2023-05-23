import Foundation

public class SwiftMultiplier {
    public var cxxMultiplier: CxxMultiplier

    // TODO(ncooke3): Test a private type.

    public init(cxxMultiplier: CxxMultiplier) {
        self.cxxMultiplier = cxxMultiplier
    }

    public func multiply(x: Int32, y: Int32) -> Int {
        return cxxMultiplier.multiply(x, y)
    }

}

public func addOne(x: Int32) -> Int32 {
    return cxxAddOne(x)
}

@_cdecl("swiftSayHello")
public func swiftSayHello() -> Int32 {
    return 1
}


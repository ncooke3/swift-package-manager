import Foundation

public class NewCar {
    // `Engine` is defined in Swift.
    var engine: Engine? = nil
    // The following types are defined in Objective-C.
    var driver: Driver? = nil
    var transmission: Transmission? = nil
    var hasStickShift: Bool {
        return transmission != nil && transmission!.transmissionKind == .manual 
    }

    public init() {}
}

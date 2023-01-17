import XCTest
import MixedTargetWithNoPublicObjectiveCHeaders

final class MixedTargetWithNoPublicObjectiveCHeadersTests: XCTestCase {

    func testPublicSwiftAPI() throws {
        // Check that Swift API surface is exposed...
        let _ = NewCar()
        let _ = Engine()
        let _ = MixedTargetWithNoPublicObjectiveCHeaders.NewCar()
        let _ = MixedTargetWithNoPublicObjectiveCHeaders.Engine()
    }

    #if EXPECT_FAILURE
    func testObjcAPI() throws {
        // No Objective-C API should be exposed...
        let _ = OldCar()
        let _ = Driver()
    }
    #endif

}

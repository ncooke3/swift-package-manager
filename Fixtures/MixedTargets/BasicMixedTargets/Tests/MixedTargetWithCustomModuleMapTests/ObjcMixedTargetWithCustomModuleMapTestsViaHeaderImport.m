#import <XCTest/XCTest.h>

#import "Machine.h"
#import "MixedTarget.h"
#import "Driver.h"
#import "OldCar.h"
#import "MixedTargetWithCustomModuleMap-Swift.h"

@interface ObjcMixedTargetWithCustomModuleMapTestsViaHeaderImport : XCTestCase
@end

@implementation ObjcMixedTargetWithCustomModuleMapTestsViaHeaderImport

- (void)testPublicSwiftAPI {
    // Check that Objective-C compatible Swift API surface is exposed...
    Engine *engine = [[Engine alloc] init];
}

- (void)testPublicObjcAPI {
    // Check that Objective-C API surface is exposed...
    MyMachine *machine = [[MyMachine alloc] init];
    MyOldCar *oldCar = [[MyOldCar alloc] init];
    MyDriver *driver = [[MyDriver alloc] init];
}

@end
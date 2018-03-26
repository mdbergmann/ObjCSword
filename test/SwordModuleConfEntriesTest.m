//
//  SwordInstallSourceManagerTest.m
//  ObjCSword
//
//  Created by Manfred Bergmann on 12.04.15.
//
//

#import <XCTest/XCTest.h>
#import "SwordManager.h"
#import "Configuration.h"
#import "OSXConfiguration.h"

@interface SwordModuleConfEntriesTest : XCTestCase {
    SwordManager *mgr;
    SwordModule *mod;
}

@end

@implementation SwordModuleConfEntriesTest


- (void)setUp {
    [Configuration configWithImpl:[[[OSXConfiguration alloc] init] autorelease]];

    mgr = [SwordManager managerWithPath:[[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"TestModules"]];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testConfEntries {
    mod = [mgr moduleWithName:@"KJV"];

    XCTAssertTrue([mod version] != nil);
    XCTAssertTrue([[mod version] length] > 0);

    XCTAssertTrue([mod minVersion] != nil);
    XCTAssertTrue([[mod minVersion] length] > 0);

    XCTAssertTrue([mod categoryString] != nil);
    NSLog(@"%@", [mod categoryString]);
    XCTAssertTrue([[mod categoryString] length] == 0);

    XCTAssertTrue([mod cipherKey] == nil);

    XCTAssertTrue([mod shortPromo] != nil);
    XCTAssertTrue([[mod shortPromo] length] == 0);

    XCTAssertTrue([mod distributionLicense] != nil);
    XCTAssertTrue([[mod distributionLicense] length] > 0);

    XCTAssertTrue([mod aboutText] != nil);
    XCTAssertTrue([[mod aboutText] length] > 0);

    XCTAssertTrue(![mod isEditable]);
    XCTAssertTrue(![mod isEncrypted]);
    XCTAssertTrue(![mod isLocked]);
}

@end

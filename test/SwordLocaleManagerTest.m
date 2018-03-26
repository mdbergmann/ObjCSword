//
//  SwordLocaleManagerTest.m
//  Tests
//
//  Created by Manfred Bergmann on 23.03.18.
//

#import <XCTest/XCTest.h>
#import "SwordLocaleManager.h"

@interface SwordLocaleManagerTest : XCTestCase

@end

@implementation SwordLocaleManagerTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testDefaultLocalSetup {
    SwordLocaleManager *locMgr = [SwordLocaleManager defaultManager];
    
    [locMgr initLocale];

    NSString *defaultLocName = [locMgr getDefaultLocaleName];
    NSLog(@"%@", defaultLocName);
    
    XCTAssert(defaultLocName != nil);
    XCTAssert([defaultLocName isEqual:@"de"]);
}

@end

//
// Created by Manfred Bergmann on 23.03.18.
//

#import "SwordBibleTest.h"
#import "SwordModule.h"
#import "SwordBible.h"
#import "Configuration.h"
#import "OSXConfiguration.h"
#import "SwordManager.h"

@implementation SwordBibleTest {
    SwordManager *mgr;
}

- (void)setUp {
    [super setUp];

    [Configuration configWithImpl:[[[OSXConfiguration alloc] init] autorelease]];
    mgr = [SwordManager managerWithPath:[[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"TestModules"]];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testGetBible {
    SwordBible *bible = (SwordBible *) [mgr moduleWithName:@"GerNeUe"];
    XCTAssertNotNil(bible);
}

@end

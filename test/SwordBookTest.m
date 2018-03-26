//
// Created by Manfred Bergmann on 23.03.18.
//

#import "SwordBibleTest.h"
#import "SwordModule.h"
#import "SwordBook.h"
#import "Configuration.h"
#import "OSXConfiguration.h"
#import "SwordManager.h"
#import "SwordModuleTreeEntry.h"

@interface SwordBookTest : XCTestCase
@end

@implementation SwordBookTest {
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

- (void)testGetBook {
    SwordBook *book = (SwordBook *) [mgr moduleWithName:@"GerAugustinus"];
    XCTAssertNotNil(book);
}

- (void)testGetContent {
    SwordBook *book = (SwordBook *) [mgr moduleWithName:@"GerAugustinus"];

    SwordModuleTreeEntry *entry = [book treeEntryForKey:nil];
    NSLog(@"entry key: %@", [entry key]);
    XCTAssertTrue([entry key] > 0);
    XCTAssertTrue([[entry content] count] == 13);
    NSLog(@"entry content count: %i", (int) [[entry content] count]);

    [book testLoop];
}

@end

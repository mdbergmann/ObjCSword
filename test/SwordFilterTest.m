//
// Created by Manfred Bergmann on 24.03.18.
//

#import "SwordFilterTest.h"
#import "Configuration.h"
#import "OSXConfiguration.h"
#import "SwordManager.h"
#import "SwordBible.h"
#import "SwordModuleTextEntry.h"
#import "FilterProviderFactory.h"
#import "DefaultFilterProvider.h"


@implementation SwordFilterTest {
    SwordManager *mgr;
}

- (void)setUp {
    [super setUp];

    [[FilterProviderFactory factory] initWith:[[[DefaultFilterProvider alloc] init] autorelease]];

    [Configuration configWithImpl:[[[OSXConfiguration alloc] init] autorelease]];
    mgr = [SwordManager managerWithPath:[[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"TestModules"]];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testRenderedOsisFootnote {
    [mgr setGlobalOption:SW_OPTION_FOOTNOTES value:SW_ON];

    SwordBible *mod = (SwordBible *)[mgr moduleWithName:@"KJV"];
    SwordModuleTextEntry *renderedText = [mod renderedTextEntryForReference:@"gen 1:6"];
    NSLog(@"%@:%@", [renderedText key], [renderedText text]);
    XCTAssertTrue([[renderedText text] containsString:@"<a href=\"passagestudy.jsp?"]);

    mod = (SwordBible *)[mgr moduleWithName:@"KJV"];
    renderedText = [mod renderedTextEntryForReference:@"gen 1:6"];
    NSLog(@"%@:%@", [renderedText key], [renderedText text]);
    XCTAssertTrue([[renderedText text] containsString:@"<a href=\"passagestudy.jsp?"]);

    mod = (SwordBible *)[mgr moduleWithName:@"KJV"];
    renderedText = [mod renderedTextEntryForReference:@"gen 1:6"];
    NSLog(@"%@:%@", [renderedText key], [renderedText text]);
    XCTAssertTrue([[renderedText text] containsString:@"<a href=\"passagestudy.jsp?"]);

    [mgr setGlobalOption:SW_OPTION_FOOTNOTES value:SW_OFF];
}

@end

//
//  SwordInstallSourceManagerTest.m
//  ObjCSword
//
//  Created by Manfred Bergmann on 12.04.15.
//
//

#import <XCTest/XCTest.h>
#import "SwordInstallSourceManager.h"
#import "SwordInstallSource.h"
#import "SwordManager.h"

@interface SwordInstallSourceManagerTest : XCTestCase

@end

@implementation SwordInstallSourceManagerTest

NSString *testConfigPath = @"/tmp/testmodinst";
NSString *testModuleManagerPath = @"/tmp/testmodmgr";
NSString *localInstallSourcePath = @"/Users/mbergmann/Development/MySources/crosswire/ObjCSword/LocalTestInstallSource";

- (void)setUp {
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:testConfigPath error:NULL];
    [fm removeItemAtPath:testModuleManagerPath error:NULL];

    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testObjectCreate {
    SwordInstallSourceManager *mgr = [[[SwordInstallSourceManager alloc] initWithPath:@"" createPath:YES] autorelease];
    XCTAssertTrue(mgr != nil, @"");
}

- (void)testLocalInstallSource {
    SwordInstallSource *is = [[[SwordInstallSource alloc] init] autorelease];
    [is setSource:@"localhost"];
    [is setDirectory:localInstallSourcePath];
    [is setCaption:@"LocalTest"];

    SwordInstallSourceManager *mgr = [[[SwordInstallSourceManager alloc] initWithPath:testConfigPath createPath:YES] autorelease];
    [mgr initManager];
    [mgr addInstallSource:is reload:YES];

    NSDictionary *mods = [mgr listModulesForSource:is];
    XCTAssertTrue([mods count] == 1);
    XCTAssertTrue([[((SwordModule *) [mods allValues][0]) name] isEqualToString:@"KJV"]);
}

- (void)testLocalallInstallSourcestatusNew {
    SwordInstallSource *is = [[[SwordInstallSource alloc] init] autorelease];
    [is setSource:@"localhost"];
    [is setDirectory:localInstallSourcePath];
    [is setCaption:@"LocalTest"];

    SwordInstallSourceManager *mgr = [[[SwordInstallSourceManager alloc] initWithPath:testConfigPath createPath:YES] autorelease];
    [mgr initManager];
    [mgr addInstallSource:is reload:YES];

    SwordManager *swMgr = [SwordManager managerWithPath:testModuleManagerPath];
    NSArray *stats = [mgr moduleStatusInInstallSource:is baseManager:swMgr];
    for(SwordModule *mod in stats) {
        NSLog(@"mod.name=%@", [mod name]);
        NSLog(@"mod.stat=%i", [mod status]);
    }

    XCTAssertTrue([((SwordModule *) stats[0]).name isEqualToString:@"KJV"]);
    XCTAssertTrue(((SwordModule *) stats[0]).status == ModStatNew);
}

- (void)testLocalallInstallSourcestatusSame {
    SwordInstallSource *is = [[[SwordInstallSource alloc] init] autorelease];
    [is setSource:@"localhost"];
    [is setDirectory:localInstallSourcePath];
    [is setCaption:@"LocalTest"];

    SwordManager *swMgr = [SwordManager managerWithPath:testModuleManagerPath];
    SwordInstallSourceManager *mgr = [[[SwordInstallSourceManager alloc] initWithPath:testConfigPath createPath:YES] autorelease];
    [mgr initManager];
    [mgr addInstallSource:is reload:YES];

    [mgr installModule:[[mgr listModulesForSource:is] allValues][0] fromSource:is withManager:swMgr];

    [swMgr reloadManager];
    NSArray *stats = [mgr moduleStatusInInstallSource:is baseManager:swMgr];
    for(SwordModule *mod in stats) {
        NSLog(@"mod.name=%@", [mod name]);
        NSLog(@"mod.stat=%i", [mod status]);
    }

    XCTAssertTrue([((SwordModule *) stats[0]).name isEqualToString:@"KJV"]);
    XCTAssertTrue(((SwordModule *) stats[0]).status == ModStatSameVersion);
}

- (void)testInstallModuleFromLocalSource {
    SwordInstallSource *is = [[[SwordInstallSource alloc] init] autorelease];
    [is setSource:@"localhost"];
    [is setDirectory:localInstallSourcePath];
    [is setCaption:@"LocalTest"];

    SwordManager *swMgr = [SwordManager managerWithPath:testModuleManagerPath];
    SwordInstallSourceManager *mgr = [[[SwordInstallSourceManager alloc] initWithPath:testConfigPath createPath:YES] autorelease];
    [mgr initManager];
    [mgr addInstallSource:is reload:YES];

    int stat = [mgr installModule:[[mgr listModulesForSource:is] allValues][0] fromSource:is withManager:swMgr];
    XCTAssertTrue(stat == 0);
}

- (void)testInitManagerCheckConfigPath {
    // make sure this folder doesn't exist at start
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir;
    BOOL existsFolder = [fm fileExistsAtPath:testConfigPath isDirectory:&isDir];
    XCTAssertFalse(existsFolder, @"");

    SwordInstallSourceManager *mgr = [[[SwordInstallSourceManager alloc] initWithPath:testConfigPath createPath:YES] autorelease];
    [mgr initManager];

    // make sure the folder was created
    existsFolder = [fm fileExistsAtPath:testConfigPath isDirectory:&isDir];
    BOOL existsInstallMgrConf = [fm fileExistsAtPath:[testConfigPath stringByAppendingPathComponent:@"InstallMgr.conf"]];
    
    XCTAssertTrue(isDir, @"");
    XCTAssertTrue(existsFolder, @"");
    XCTAssertTrue(existsInstallMgrConf, @"");
}

- (void)testHasOneInitialInstallSource {
    SwordInstallSourceManager *mgr = [[[SwordInstallSourceManager alloc] initWithPath:testConfigPath createPath:YES] autorelease];
    [mgr initManager];

    XCTAssertTrue([[mgr allInstallSources] count] == 1, @"");
    XCTAssertTrue([[[[[mgr allInstallSources] allValues] firstObject] caption] isEqualToString:@"CrossWire"], @"");
    XCTAssertTrue([[[[[mgr allInstallSources] allValues] firstObject] source] isEqualToString:@"ftp.crosswire.org"], @"");
    XCTAssertTrue([[[[[mgr allInstallSources] allValues] firstObject] directory] isEqualToString:@"/pub/sword/raw"], @"");
}

- (void)testDisclaimerNotApproved {
    SwordInstallSourceManager *mgr = [[[SwordInstallSourceManager alloc] initWithPath:testConfigPath createPath:YES] autorelease];
    [mgr initManager];

    XCTAssertTrue([[mgr allInstallSources] count] == 1, @"");

    NSInteger stat = [mgr refreshInstallSource:[[mgr allInstallSources] allValues][0]];
    NSLog(@"stat: %li", stat);
    XCTAssertTrue(stat == -1);
}

- (void)testRefreshInstallSource {
    SwordInstallSourceManager *mgr = [[[SwordInstallSourceManager alloc] initWithPath:testConfigPath createPath:YES] autorelease];
    [mgr initManager];

    XCTAssertTrue([[mgr allInstallSources] count] == 1, @"");

    [mgr setUserDisclaimerConfirmed:YES];
    NSInteger stat = [mgr refreshInstallSource:[[mgr allInstallSources] allValues][0]];
    NSLog(@"stat: %li", stat);
    XCTAssertTrue(stat == 0);
}

- (void)testAddInstallSource {
    SwordInstallSourceManager *mgr = [[[SwordInstallSourceManager alloc] initWithPath:testConfigPath createPath:YES] autorelease];
    [mgr initManager];

    SwordInstallSource *is = [[[SwordInstallSource alloc] initWithType:INSTALLSOURCE_TYPE_FTP] autorelease];
    [is setCaption:@"test"];
    [is setSource:@"foo.bar.local"];
    [is setDirectory:@"/foobar"];

    [mgr addInstallSource:is reload:YES];
    [mgr saveConfig];

    XCTAssertTrue([[mgr allInstallSources] count] == 2, @"");

    XCTAssertTrue([[[mgr allInstallSources][@"test"] caption] isEqualToString:@"test"], @"");
    XCTAssertTrue([[[mgr allInstallSources][@"test"] source] isEqualToString:@"foo.bar.local"], @"");
    XCTAssertTrue([[[mgr allInstallSources][@"test"] directory] isEqualToString:@"/foobar"], @"");
}

- (void)testRemoveInstallSource {
    SwordInstallSourceManager *mgr = [[[SwordInstallSourceManager alloc] initWithPath:testConfigPath createPath:YES] autorelease];
    [mgr initManager];

    // first add
    SwordInstallSource *is = [[[SwordInstallSource alloc] initWithType:INSTALLSOURCE_TYPE_FTP] autorelease];
    [is setCaption:@"test"];
    [is setSource:@"foo.bar.local"];
    [is setDirectory:@"/foobar"];

    [mgr addInstallSource:is reload:YES];

    XCTAssertTrue([[mgr allInstallSources] count] == 2, @"");

    XCTAssertTrue([[[mgr allInstallSources][@"test"] caption] isEqualToString:@"test"], @"");
    XCTAssertTrue([[[mgr allInstallSources][@"test"] source] isEqualToString:@"foo.bar.local"], @"");
    XCTAssertTrue([[[mgr allInstallSources][@"test"] directory] isEqualToString:@"/foobar"], @"");

    // then remove
    [mgr removeInstallSource:is reload:YES];

    XCTAssertTrue([[mgr allInstallSources] count] == 1, @"");
    is = [[[mgr allInstallSources] allValues] firstObject];
    NSLog(@"IS caption: %@", [is caption]);
    XCTAssertTrue([[is caption] isEqualToString:@"CrossWire"], @"");
}

- (void)testUpdateInstallSource {
    SwordInstallSourceManager *mgr = [[[SwordInstallSourceManager alloc] initWithPath:testConfigPath createPath:YES] autorelease];
    [mgr initManager];

    // first add
    SwordInstallSource *is = [[[SwordInstallSource alloc] initWithType:INSTALLSOURCE_TYPE_FTP] autorelease];
    [is setCaption:@"test"];
    [is setSource:@"foo.bar.local"];
    [is setDirectory:@"/foobar"];
    [mgr addInstallSource:is reload:YES];

    XCTAssertTrue([[mgr allInstallSources] count] == 2, @"");
    XCTAssertTrue([[[mgr allInstallSources][@"test"] caption] isEqualToString:@"test"], @"");
    XCTAssertTrue([[[mgr allInstallSources][@"test"] source] isEqualToString:@"foo.bar.local"], @"");
    XCTAssertTrue([[[mgr allInstallSources][@"test"] directory] isEqualToString:@"/foobar"], @"");

    SwordInstallSource *update = [mgr allInstallSources][@"test"];
    [update setSource:@"local.bar.foo"];

    [mgr updateInstallSource:update];

    XCTAssertTrue([[mgr allInstallSources] count] == 2, @"");
    XCTAssertTrue([[[mgr allInstallSources][@"test"] caption] isEqualToString:@"test"], @"");
    XCTAssertTrue([[[mgr allInstallSources][@"test"] source] isEqualToString:@"local.bar.foo"], @"");
    XCTAssertTrue([[[mgr allInstallSources][@"test"] directory] isEqualToString:@"/foobar"], @"");
}

- (void)testUseAsDefaultManager {
    SwordInstallSourceManager *mgr = [[[SwordInstallSourceManager alloc] initWithPath:testConfigPath createPath:YES] autorelease];
    [mgr useAsDefaultManager];

    SwordInstallSourceManager *mgr2 = [SwordInstallSourceManager defaultManager];
    XCTAssertEqual(mgr, mgr2);
}

- (void)testExample {
    XCTAssert(YES, @"Pass");
}

@end

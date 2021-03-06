//
//  SwordModuleTest.m
//  ObjCSword
//
//  Created by Manfred Bergmann on 14.06.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import "SwordModuleTest.h"
#import <ObjCSword/ObjCSword.h>

@class SwordModule, SwordManager;

@interface SwordModuleTest : XCTestCase {
    SwordManager *mgr;
    SwordModule *mod;
}

@end

@implementation SwordModuleTest

- (void)setUp {
    [Configuration configWithImpl:[[[OSXConfiguration alloc] init] autorelease]];

    [[FilterProviderFactory factory] initWith:[[[DefaultFilterProvider alloc] init] autorelease]];
    
    mgr = [SwordManager managerWithPath:[[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"TestModules"]];
    mod = [mgr moduleWithName:@"KJV"];
}

/*
- (void)testModuleIntroductionGer {
    SwordBible *bible = (SwordBible *)[mgr moduleWithName:@"GerNeUe"];

    NSString *modIntro = [bible moduleIntroduction];
    NSLog(@"mod intro: %@", modIntro);
    XCTAssertNotNil(modIntro);
    //XCTAssertTrue([@"Im Anfang schuf Gott Himmel und Erde." isEqualToString:modIntro]);
}
*/

- (void)testFirstBookATIntroGer {
    SwordBible *bible = (SwordBible *)[mgr moduleWithName:@"GerNeUe"];

    SwordBibleBook *book = [bible bookList][0];
    NSString *intro = [bible bookIntroductionFor:book];
    NSLog(@"testament: '%i', book '%@' intro: %@", [book testament], [book name], intro);
    XCTAssertTrue([intro containsString:@"Das erste Buch der Bibel wird auch Genesis"]);
}

- (void)testFirstBookNTIntro {
    SwordBible *bible = (SwordBible *)[mgr moduleWithName:@"GerNeUe"];

    SwordBibleBook *book = [bible bookWithNamePrefix:@"Mat"];
    NSString *intro = [bible bookIntroductionFor:book];
    NSLog(@"testament: '%i', book '%@' intro: %@", [book testament], [book name], intro);
    XCTAssertNotNil(intro);
    XCTAssertTrue([intro hasPrefix:@" <!P><br />Um die Zeit der Apostelversammlung herum"]);
}

- (void)testJesusWordsInRed {
    SwordBible *bible = (SwordBible *)[mgr moduleWithName:@"KJV"];
    XCTAssertNotNil(bible, @"Module is nil");

    [mgr setGlobalOption:SW_OPTION_REDLETTERWORDS value:SW_ON];
    
    SwordBibleTextEntry *text = (SwordBibleTextEntry *) [bible renderedTextEntryForReference:@"Mat 4:4"];
    XCTAssertTrue(text != nil);
    NSLog(@"%@: %@", [text key], [text text]);
    XCTAssertTrue([[text text] containsString:@"But he answered and said, <font color=\"red\"> It is written, Man shall not live by bread alone, but by every word that proceedeth out of the mouth of God.</font>"]);

    [mgr setGlobalOption:SW_OPTION_REDLETTERWORDS value:SW_OFF];
}

- (void)testStrongsNumberHebrewRetrieval {
    SwordBible *bible = (SwordBible *)[mgr moduleWithName:@"KJV"];
    XCTAssertNotNil(bible, @"Module is nil");

    [bible setKeyString:@"Gen 1:1"];
    NSArray *strongsNumbers = [bible entryAttributeValuesLemma];
    XCTAssertTrue(strongsNumbers != nil);
    XCTAssertTrue([strongsNumbers count] > 0);
    NSString *combinedString = [strongsNumbers componentsJoinedByString:@","];
    NSLog(@"%@", combinedString);
    XCTAssertTrue([@"H07225,H0430,H0853 H01254,H08064,H0853,H0776" isEqualToString:combinedString]);
}

- (void)testStrongsNumberHebrewNormalizedRetrieval {
    SwordBible *bible = (SwordBible *)[mgr moduleWithName:@"KJV"];
    XCTAssertNotNil(bible, @"Module is nil");
    
    [bible setKeyString:@"Gen 1:1"];
    NSArray *strongsNumbers = [bible entryAttributeValuesLemmaNormalized];
    XCTAssertTrue(strongsNumbers != nil);
    XCTAssertTrue([strongsNumbers count] > 0);
    NSString *combinedString = [strongsNumbers componentsJoinedByString:@","];
    NSLog(@"%@", combinedString);
    XCTAssertTrue([@"H07225,H00430,H00853,H01254,H08064,H00853,H00776" isEqualToString:combinedString]);
}

- (void)testStrongsNumberGreekRetrieval {
    SwordBible *bible = (SwordBible *)[mgr moduleWithName:@"KJV"];
    XCTAssertNotNil(bible, @"Module is nil");
    
    [bible setKeyString:@"Mat 1:1"];
    NSArray *strongsNumbers = [bible entryAttributeValuesLemma];
    XCTAssertTrue(strongsNumbers != nil);
    XCTAssertTrue([strongsNumbers count] > 0);
    NSString *combinedString = [strongsNumbers componentsJoinedByString:@","];
    NSLog(@"%@", combinedString);
    XCTAssertTrue([@"G976,G1078,G2424,G5547,G5207,G1138,G5207,G11" isEqualToString:combinedString]);
}

- (void)testStrongsNumberGreekNormalizedRetrieval {
    SwordBible *bible = (SwordBible *)[mgr moduleWithName:@"KJV"];
    XCTAssertNotNil(bible, @"Module is nil");
    
    [bible setKeyString:@"Mat 1:1"];
    NSArray *strongsNumbers = [bible entryAttributeValuesLemmaNormalized];
    XCTAssertTrue(strongsNumbers != nil);
    XCTAssertTrue([strongsNumbers count] > 0);
    NSString *combinedString = [strongsNumbers componentsJoinedByString:@","];
    NSLog(@"%@", combinedString);
    XCTAssertTrue([@"G00976,G01078,G02424,G05547,G05207,G01138,G05207,G00011" isEqualToString:combinedString]);
}

- (void)testFirstBookNTIntroGer {
    SwordBible *bible = (SwordBible *)[mgr moduleWithName:@"GerNeUe"];

    SwordBibleBook *book = [bible bookWithNamePrefix:@"Mat"];
    NSString *intro = [bible bookIntroductionFor:book];
    NSLog(@"testament: '%i', book '%@' intro: %@", [book testament], [book name], intro);
    XCTAssertNotNil(intro);
    XCTAssertTrue([intro hasPrefix:@" <!P><br />Um die Zeit der Apostelversammlung herum"]);
}

- (void)testPreverseHeading {
    SwordBible *bible = (SwordBible *)[mgr moduleWithName:@"GerNeUe"];

    [mgr setGlobalOption:SW_OPTION_HEADINGS value:SW_ON];
    SwordBibleTextEntry *text = (SwordBibleTextEntry *) [bible renderedTextEntryForReference:@"Numbers 1:47"];
    NSLog(@"Preverse text: %@", [text preVerseHeading]);
    XCTAssertTrue([[text preVerseHeading] length] > 0);
    XCTAssertTrue([[text preVerseHeading] isEqualToString:@"Die Sonderstellung der Leviten"]);
    [mgr setGlobalOption:SW_OPTION_HEADINGS value:SW_OFF];
}

- (void)testPreverseHeading2 {
    SwordBible *bible = (SwordBible *)[mgr moduleWithName:@"GerNeUe"];

    [mgr setGlobalOption:SW_OPTION_HEADINGS value:SW_ON];
    SwordBibleTextEntry *text = (SwordBibleTextEntry *) [bible renderedTextEntryForReference:@"Numbers 4:21"];
    NSLog(@"Preverse text: %@", [text preVerseHeading]);
    XCTAssertTrue([[text preVerseHeading] length] > 0);
    XCTAssertTrue([[text preVerseHeading] isEqualToString:@"Die Gerschoniten"]);
    [mgr setGlobalOption:SW_OPTION_HEADINGS value:SW_OFF];
}

- (void)testLoopRenderedVerses {
    SwordBible *bible = (SwordBible *)[mgr moduleWithName:@"KJV"];
    XCTAssertNotNil(bible, @"Module is nil");

    NSArray *verses = [bible renderedTextEntriesForReference:@"Gen"];
    XCTAssertNotNil(verses, @"");
    XCTAssertTrue([bible numberOfVerseKeysForReference:@"Gen"] == [verses count], @"");    
}

- (void)testRenderedVerseText {
    SwordBible *bible = (SwordBible *)[mgr moduleWithName:@"KJV"];
    XCTAssertNotNil(bible, @"Module is nil");
    
    SwordModuleTextEntry *text = [bible renderedTextEntryForReference:@"gen1.1"];
    XCTAssertNotNil(text, @"");
    NSLog(@"text: %@", [text text]);
    XCTAssertTrue([[text text] length] > 0, @"");
}

- (void)testRetrieveTextEntryWithBlock {
    SwordBible *bible = (SwordBible *)[mgr moduleWithName:@"KJV"];
    XCTAssertNotNil(bible, @"Module is nil");

    __block SwordModuleTextEntry *entry;
    [bible textEntriesForReference:@"gen1.1" renderType:RenderTypeRendered withBlock:^(SwordModuleTextEntry *entry1){
        entry = entry1;
    }];

    XCTAssertTrue(entry != nil);
    XCTAssertTrue([[entry text] length] > 0);
    NSLog(@"text: %@", [entry text]);
}

- (void)testLoopWithModulePos {
    SwordListKey *lk = [SwordListKey listKeyWithRef:@"gen" v11n:[mod versification]];
    [mod setSwordKey:lk];
    NSString *ref = nil;
    NSString *rendered = nil;
    while(![mod error]) {
        ref = [lk keyText];
        rendered = [mod renderedText];
        [mod incKeyPosition];
    }
}

- (void)testLoopWithModulePosWithHeadings {
    SwordListKey *lk = [SwordListKey listKeyWithRef:@"gen" headings:YES v11n:[mod versification]];
    [mod setSwordKey:lk];
    NSString *ref = nil;
    NSString *rendered = nil;
    while(![mod error]) {
        ref = [lk keyText];
        rendered = [mod renderedText];
        [mod incKeyPosition];
    }
}

- (void)testLoopWithModulePosWithDiverseReference {
    SwordListKey *lk = [SwordListKey listKeyWithRef:@"gen 1:1;4:5-8" v11n:[mod versification]];
    [mod setSwordKey:lk];
    NSString *ref = nil;
    NSString *rendered = nil;
    while(![mod error]) {
        ref = [lk keyText];
        rendered = [mod renderedText];
        NSLog(@"%@:%@", ref, rendered);
        [mod incKeyPosition];
    }
}

- (void)testLoopWithModulePosWithDiverseReferenceAndContext {
    int context = 1;
    SwordVerseKey *vk = [SwordVerseKey verseKeyWithVersification:[mod versification]];
    SwordListKey *lk = [SwordListKey listKeyWithRef:@"gen 1:1;4:5;8:4;10:2-5" v11n:[mod versification]];
    [mod setSwordKey:lk];
    NSString *ref = nil;
    NSString *rendered = nil;
    while(![mod error]) {
        if(context > 0) {
            [vk setKeyText:[lk keyText]];
            long lowVerse = [vk verse] - context;
            long highVerse = lowVerse + (context * 2);
            [vk setVerse:(int)lowVerse];
            [mod setSwordKey:vk];
            for(;lowVerse <= highVerse;lowVerse++) {
                ref = [vk keyText];
                rendered = [mod renderedText];                
                NSLog(@"%@:%@", ref, rendered);
                [mod incKeyPosition];
            }
            // set back list key
            [mod setSwordKey:lk];
            [mod incKeyPosition];
        } else {
            ref = [lk keyText];
            rendered = [mod renderedText];
            NSLog(@"%@:%@", ref, rendered);
            [mod incKeyPosition];            
        }
    }
}

- (void)testVersePositioning {
    SwordVerseKey *vk = [SwordVerseKey verseKeyWithRef:@"gen 1:2"];
    NSLog(@"start position: %@", [vk keyText]);
    [vk decrement];
    NSLog(@"decrement position: %@", [vk keyText]);
    XCTAssertTrue([vk chapter] == 1);
    XCTAssertTrue([vk book] == 1);
    XCTAssertTrue([vk verse] == 1);

    [vk setVerse:[vk verse] + 3];
    NSLog(@"verse + 3: %@", [vk keyText]);
    XCTAssertTrue([vk chapter] == 1);
    XCTAssertTrue([vk book] == 1);
    XCTAssertTrue([vk verse] == 4);
}

@end

//
//  SwordBibleBook.m
//  MacSword2
//
//  Created by Manfred Bergmann on 18.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SwordBibleBook.h"
#import "SwordBibleChapter.h"

@interface SwordBibleBook () {
    NSArray *_chapters;
}

@property (readwrite) int numberInTestament;
@property (readwrite) int testament;
@property (retain, readwrite) NSString *localizedName;
@property (retain, readwrite) NSArray *chapters;

@end

@implementation SwordBibleBook

//@synthesize number;
//@synthesize numberInTestament;
//@synthesize testament;
//@synthesize localizedName;
@dynamic chapters;

- (id)init {
    self = [super init];
    if(self) {
        self.number = 0;
        self.numberInTestament = 0;
        self.testament = 0;        
        self.localizedName = @"";
        self.chapters = nil;
    }
    
    return self;
}

- (id)initWithBook:(sword::VersificationMgr::Book *)aBook {
    self = [self init];
    if(self) {
        swBook = aBook;
        
        sword::VerseKey vk = sword::VerseKey(aBook->getOSISName());
        [self setTestament:vk.getTestament()];
        [self setNumberInTestament:vk.getBook()];
        
        // get system localeMgr to be able to translate the english bookName
        sword::LocaleMgr *lmgr = sword::LocaleMgr::getSystemLocaleMgr();
        const char *translated = lmgr->translate(swBook->getLongName());
        self.localizedName = [NSString stringWithUTF8String:translated];

        // in case we don't have ICU support this still works.
        if(self.localizedName == nil) {
            self.localizedName = [NSString stringWithCString:translated encoding:NSISOLatin1StringEncoding];
        }
        if(self.localizedName == nil) {
            DLog(@"Unable to get this book name: %s", translated);
        }
    }
    
    return self;
}


- (void)dealloc {
    [self setChapters:nil];
    [self setLocalizedName:nil];

    [super dealloc];
}

- (NSString *)name {
    return [NSString stringWithUTF8String:swBook->getLongName()];
}

- (NSString *)osisName {
    return [NSString stringWithUTF8String:swBook->getOSISName()];
}

- (int)numberOfChapters {
    return swBook->getChapterMax();
}

- (int)numberOfVersesForChapter:(int)chapter {
    return swBook->getVerseMax(chapter);
}

- (void)setChapters:(NSArray *)anArray {
    [_chapters release];
    _chapters = [anArray retain];
}

- (NSArray *)chapters {
    if(_chapters == nil) {
        NSMutableArray *temp = [NSMutableArray array];
        for(int i = 0;i < swBook->getChapterMax();i++) {
            [temp addObject:[[[SwordBibleChapter alloc] initWithBook:self andChapter:i + 1] autorelease]];
        }
        [self setChapters:[NSArray arrayWithArray:temp]];
    }
    return _chapters;
}

/**
 get book index for verseKey
 that is: book number + testament * 100
 */
- (int)generatedIndex {
    return self.number + self.testament * 100;
}

- (sword::VersificationMgr::Book *)book {
    return swBook;
}

/** we implement this for sorting */
- (NSComparisonResult)compare:(SwordBibleBook *)b {
    return [@(self.number) compare:@([b number])];
}

@end

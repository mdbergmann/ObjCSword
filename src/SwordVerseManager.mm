//
//  SwordVerseManager.m
//  MacSword2
//
//  Created by Manfred Bergmann on 19.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SwordVerseManager.h"
#import "SwordBibleBook.h"


@interface SwordVerseManager () {
    sword::VersificationMgr *verseMgr;
}

@property (retain, readwrite) NSMutableDictionary *booksPerVersification;

@end

@implementation SwordVerseManager

+ (SwordVerseManager *)defaultManager {
    static SwordVerseManager *singleton = nil;
    if(!singleton) {
        singleton = [[SwordVerseManager alloc] init];
    }
    
    return singleton;
}

- (id)init {
    self = [super init];
    if(self) {
        self.booksPerVersification = [NSMutableDictionary dictionary];
        verseMgr = sword::VersificationMgr::getSystemVersificationMgr();
    }
    
    return self;
}

/** convenience method that returns the books for default scheme (KJV) */
- (NSArray *)books {
    return [self booksForVersification:SW_VERSIFICATION_KJV];
}

/** books for a versification scheme */
- (NSArray *)booksForVersification:(NSString *)verseScheme {
    NSArray *ret = self.booksPerVersification[verseScheme];
    if(ret == nil) {
        // hasn't been initialized yet
        const sword::VersificationMgr::System *system = verseMgr->getVersificationSystem([verseScheme UTF8String]);

        if(system == NULL) {
            DLog(@"Unable to retrieve books for versification scheme: %@", verseScheme);
            DLog(@"Using default!");
            return [self books];
        }

        NSUInteger bookCount = (NSUInteger)system->getBookCount();
        NSMutableArray *buf = [NSMutableArray arrayWithCapacity:bookCount];
        for(int i = 0;i < bookCount;i++) {
            sword::VersificationMgr::Book *book = (sword::VersificationMgr::Book *)system->getBook(i);
            
            SwordBibleBook *bb = [[[SwordBibleBook alloc] initWithBook:book] autorelease];
            [bb setNumber:i+1]; // VerseKey-Book() starts at index 1
            
            // add to array
            [buf addObject:bb];
        }
        self.booksPerVersification[verseScheme] = buf;
        ret = buf;
    }
    
    return ret;
}

- (sword::VersificationMgr *)verseMgr {
    return verseMgr;
}

@end

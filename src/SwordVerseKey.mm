//
//  SwordVerseKey.mm
//  MacSword2
//
//  Created by Manfred Bergmann on 17.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SwordVerseKey.h"


@implementation SwordVerseKey

+ (SwordVerseKey *)verseKey {
    return [[[SwordVerseKey alloc] init] autorelease];
}

+ (SwordVerseKey *)verseKeyWithVersification:(NSString *)scheme {
    return [[[SwordVerseKey alloc] initWithVersification:scheme] autorelease];
}

+ (SwordVerseKey *)verseKeyWithRef:(NSString *)aRef {
    return [[[SwordVerseKey alloc] initWithRef:aRef] autorelease];
}

+ (SwordVerseKey *)verseKeyWithRef:(NSString *)aRef v11n:(NSString *)scheme {
    return [[[SwordVerseKey alloc] initWithRef:aRef v11n:scheme] autorelease];
}

+ (SwordVerseKey *)verseKeyWithSWVerseKey:(sword::VerseKey *)aVk {
    return [[[SwordVerseKey alloc] initWithSWVerseKey:aVk] autorelease];
}

+ (SwordVerseKey *)verseKeyWithNewSWVerseKey:(sword::VerseKey *)aVk {
    return [[[SwordVerseKey alloc] initWithNewSWVerseKey:aVk] autorelease];
}

- (id)init {
    return [self initWithRef:nil];
}

- (SwordVerseKey *)initWithVersification:(NSString *)scheme {
    return [self initWithRef:nil v11n:scheme];
}

- (SwordVerseKey *)initWithSWVerseKey:(sword::VerseKey *)aVk {
    return (SwordVerseKey *)[super initWithSWKey:aVk];
}

- (SwordVerseKey *)initWithNewSWVerseKey:(sword::VerseKey *)aVk {
    return (SwordVerseKey *)[super initWithNewSWKey:aVk];
}

- (SwordVerseKey *)initWithRef:(NSString *)aRef {
    return [self initWithRef:aRef v11n:nil];
}

- (SwordVerseKey *)initWithRef:(NSString *)aRef v11n:(NSString *)scheme {
    sword::VerseKey vk;

    self = [super initWithNewSWKey:vk.clone()];
    if(self) {
        if(scheme) {
            [self setVersification:scheme];
        }

        if(aRef) {
            [self setKeyText:aRef];
        }
    }
    
    return self;
}

- (long)index {
    return ((sword::VerseKey *)sk)->getIndex();
}

- (BOOL)intros {
    return (BOOL)((sword::VerseKey *)sk)->isIntros();
}

- (void)setIntros:(BOOL)flag {
    ((sword::VerseKey *)sk)->setIntros(flag);
}

- (BOOL)autoNormalize {
    return (BOOL)((sword::VerseKey *)sk)->isAutoNormalize();
}

- (void)setAutoNormalize:(BOOL)flag {
    ((sword::VerseKey *)sk)->setAutoNormalize(flag);
}

- (int)testament {
    return ((sword::VerseKey *)sk)->getTestament();
}

- (int)book {
    return ((sword::VerseKey *)sk)->getBook();
}

- (int)chapter {
    return ((sword::VerseKey *)sk)->getChapter();
}

- (int)verse {
    return ((sword::VerseKey *)sk)->getVerse();
}

- (void)setTestament:(char)val {
    ((sword::VerseKey *)sk)->setTestament(val);
}

- (void)setBook:(char)val {
    ((sword::VerseKey *)sk)->setBook(val);
}

- (void)setChapter:(int)val {
    ((sword::VerseKey *)sk)->setChapter(val);
}

- (void)setVerse:(long)val {
    ((sword::VerseKey *)sk)->setVerse((int)val);
}

- (NSString *)bookName {
    return [NSString stringWithUTF8String:((sword::VerseKey *)sk)->getBookName()];
}

- (NSString *)osisBookName {
    return [NSString stringWithUTF8String:((sword::VerseKey *)sk)->getOSISBookName()];
}

- (NSString *)osisRef {
    return [NSString stringWithUTF8String:((sword::VerseKey *)sk)->getOSISRef()];    
}

- (void)setVersification:(NSString *)versification {
    ((sword::VerseKey *)sk)->setVersificationSystem([versification UTF8String]);
}

- (NSString *)versification {
    return [NSString stringWithUTF8String:((sword::VerseKey *)sk)->getVersificationSystem()];
}

- (sword::VerseKey *)swVerseKey {
    return (sword::VerseKey *)sk;
}

@end

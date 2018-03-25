//
//  SwordBibleChapter.m
//  MacSword2
//
//  Created by Manfred Bergmann on 19.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SwordBibleChapter.h"

@interface SwordBibleChapter ()

@property (readwrite) int number;
@property (retain, readwrite) SwordBibleBook *book;

@end

@implementation SwordBibleChapter

- (id)initWithBook:(SwordBibleBook *)aBook andChapter:(int)aNumber {
    self = [super init];
    if(self) {
        self.book = aBook;
        self.number = aNumber;
    }
    
    return self;
}

- (void)dealloc {
    self.book = nil;
    
    [super dealloc];
}

@end

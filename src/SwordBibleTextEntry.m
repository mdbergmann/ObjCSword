//
//  SwordBibleTextEntry.m
//  MacSword2
//
//  Created by Manfred Bergmann on 01.02.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import "SwordBibleTextEntry.h"

@interface SwordBibleTextEntry ()

@end

@implementation SwordBibleTextEntry

+ (id)textEntryForKey:(NSString *)aKey andText:(NSString *)aText {
    return [[[SwordBibleTextEntry alloc] initWithKey:aKey andText:aText] autorelease];
}

- (id)initWithKey:(NSString *)aKey andText:(NSString *)aText {
    self = [super initWithKey:aKey andText:aText];
    if(self) {
        self.preVerseHeading = @"";
    }
    return self;
}

- (void)dealloc {
    self.preVerseHeading = nil;
    
    [super dealloc];
}

@end

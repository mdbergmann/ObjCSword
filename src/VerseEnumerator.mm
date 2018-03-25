//
//  VerseEnumerator.m
//  MacSword2
//
//  Created by Manfred Bergmann on 25.02.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import "VerseEnumerator.h"
#import "SwordListKey.h"

@interface VerseEnumerator ()
@property (retain, readwrite) SwordListKey *listKey;
@end

@implementation VerseEnumerator

- (id)initWithListKey:(SwordListKey *)aListKey {
    self = [super init];
    if(self) {
        self.listKey = aListKey;
        *[self.listKey swListKey] = sword::TOP;
    }
    return self;
}

- (void)dealloc {
    self.listKey = nil;

    [super dealloc];
}

- (NSArray *)allObjects {
    NSMutableArray *t = [NSMutableArray array];
    sword::ListKey *lk = [self.listKey swListKey];
    for(*lk = sword::TOP;!lk->popError(); *lk += 1) {
        [t addObject:[self.listKey keyText]];
    }
    // position TOP again
    *lk = sword::TOP;
    
    return [NSArray arrayWithArray:t];
}

- (NSString *)nextObject {
    NSString *ret = nil;
    sword::ListKey *lk = [self.listKey swListKey];
    if(!lk->popError()) {
        ret = [self.listKey keyText];
        *lk += 1;
    }
    return ret;
}

@end

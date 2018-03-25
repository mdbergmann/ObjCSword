//
//  SwordKey.m
//  MacSword2
//
//  Created by Manfred Bergmann on 17.12.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import "SwordKey.h"

@interface SwordKey () {
    BOOL created;
}
@end

@implementation SwordKey

@dynamic keyText;

+ (SwordKey *)swordKeyWithSWKey:(sword::SWKey *)aSk {
    return [[[SwordKey alloc] initWithSWKey:aSk] autorelease];
}

+ (SwordKey *)swordKeyWithNewSWKey:(sword::SWKey *)aSk {
    return [[[SwordKey alloc] initWithNewSWKey:aSk] autorelease];
}

- (SwordKey *)initWithSWKey:(sword::SWKey *)aSk {
    self = [super init];
    if(self) {
        sk = aSk;
        created = false;
    }
    return self;
}

- (SwordKey *)initWithNewSWKey:(sword::SWKey *)aSk {
    self = [self initWithSWKey:aSk];
    if(self) {
        [self swKey]->setPersist(true);
        created = true;
    }
    return self;
}

- (void)dealloc {
    if(created) {
        delete sk;
    }

    [super dealloc];
}

#pragma mark - Methods

- (SwordKey *)clone {
    return [SwordKey swordKeyWithSWKey:sk];
}

- (NSString *)keyText {
    return [NSString stringWithUTF8String:sk->getText()];
}

- (void)setKeyText:(NSString *)aKey {
    sk->setText([aKey UTF8String]);
}

- (void)setPosition:(int)pos {
    sk->setPosition(sword::SW_POSITION((char)pos));
}

- (int)error {
    return sk->popError();
}

- (void)decrement {
    sk->decrement();
}

- (void)increment {
    sk->increment();
}

- (sword::SWKey *)swKey {
    return sk;
}

@end

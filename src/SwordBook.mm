/*	SwordBook.mm - Sword API wrapper for GenBooks.

    Copyright 2008 Manfred Bergmann
    Based on code by Will Thimbleby

	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation version 2.

	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
	even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
	General Public License for more details. (http://www.gnu.org/licenses/gpl.html)
*/

#import "SwordBook.h"
#import "SwordModuleTreeEntry.h"

#define GenBookRootKey @"root"

@interface SwordBook ()

@property(retain, readwrite) NSMutableDictionary *_contentsBuffer;

- (SwordModuleTreeEntry *)_treeEntryForKey:(sword::TreeKeyIdx *)treeKey;

@end


@implementation SwordBook

- (id)initWithSWModule:(sword::SWModule *)aModule {
    self = [super initWithSWModule:aModule];
    if(self) {
        self._contentsBuffer = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)dealloc {
    self._contentsBuffer = nil;
    
    [super dealloc];
}

/**
 * Immutable copy
 * @return
 */
- (NSDictionary *)allContent {
    return [NSDictionary dictionaryWithDictionary:self._contentsBuffer];
}

- (SwordModuleTreeEntry *)treeEntryForKey:(NSString *)treeKey {
    SwordModuleTreeEntry * ret;
    
    [moduleLock lock];
    if(treeKey == nil) {
        ret = self._contentsBuffer[GenBookRootKey];
        if(ret == nil) {
            sword::TreeKeyIdx *tk = dynamic_cast<sword::TreeKeyIdx*>((sword::SWKey *)*([self swModule]));
            ret = [self _treeEntryForKey:tk];
            // add to content
            self._contentsBuffer[GenBookRootKey] = ret;
        }
    } else {
        ret = self._contentsBuffer[treeKey];
        if(ret == nil) {
            const char *keyStr = [treeKey UTF8String];
            if(![self isUnicode]) {
                keyStr = [treeKey cStringUsingEncoding:NSISOLatin1StringEncoding];
            }
            // position module
            sword::SWKey *mkey = new sword::SWKey(keyStr);
            [self swModule]->setKey(mkey);
            sword::TreeKeyIdx *key = dynamic_cast<sword::TreeKeyIdx*>((sword::SWKey *)*([self swModule]));
            ret = [self _treeEntryForKey:key];
            // add to content
            self._contentsBuffer[treeKey] = ret;
        }
    }
    [moduleLock unlock];
    
    return ret;
}

- (SwordModuleTreeEntry *)_treeEntryForKey:(sword::TreeKeyIdx *)treeKey {
    SwordModuleTreeEntry *ret = [[[SwordModuleTreeEntry alloc] init] autorelease];
    
	char *treeNodeName = (char *)treeKey->getText();
	NSString *nName;
    
    if(strlen(treeNodeName) == 0) {
        nName = GenBookRootKey;
    } else {    
        // key encoding depends on module encoding
        nName = [NSString stringWithUTF8String:treeNodeName];
        if(!nName) {
            nName = [NSString stringWithCString:treeNodeName encoding:NSISOLatin1StringEncoding];
        }
    }
    // set name
    [ret setKey:nName];
    NSMutableArray *c = [NSMutableArray array];
    // if this node has children, walk them
	if(treeKey->hasChildren()) {
        // get first child
		treeKey->firstChild();
        do {
            NSString *subName;
            // key encoding depends on module encoding
            const char *textStr = treeKey->getText();
            subName = [NSString stringWithUTF8String:textStr];
            if(!subName) {
                subName = [NSString stringWithCString:textStr encoding:NSISOLatin1StringEncoding];
            }
            if(subName) {
                [c addObject:subName];
            }
        }
        while(treeKey->nextSibling());            
	}
    [ret setContent:[NSArray arrayWithArray:c]];

	return ret;
}

- (void)testLoop {
    SwordModuleTreeEntry *entry = [self treeEntryForKey:nil];
    if([[entry content] count] > 0) {
        for(NSString *subKey in [entry content]) {
            entry = [self treeEntryForKey:subKey];
            if([[entry content] count] > 0) {
            } else {
                DLog(@"Entry: %@", [entry key]);
            }    
        }
    } else {
        DLog(@"Entry: %@", [entry key]);
    }    
}

#pragma mark - SwordModuleAccess

- (long)entryCount {
    // TODO: set value according to maximum entries here
    return 1000;
}

@end

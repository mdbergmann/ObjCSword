/*	SwordDict.mm - Sword API wrapper for lexicons and Dictionaries.

    Copyright 2008 Manfred Bergmann
    Based on code by Will Thimbleby

	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation version 2.

	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
	even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
	General Public License for more details. (http://www.gnu.org/licenses/gpl.html)
*/

#import <ObjCSword/ObjCSword.h>

@interface SwordDictionary ()

@property(readwrite, retain) NSMutableArray *keys;

- (void)readKeys;
- (void)readFromCache;
- (void)writeToCache;

@end


@implementation SwordDictionary

/**
 only the keys are stored here in an array
 */
- (void)readKeys {    
	if(self.keys == nil) {
        [self readFromCache];
    }
    
    // still no entries?
	if([self.keys count] == 0) {
        NSMutableArray *arr = [NSMutableArray array];

        [moduleLock lock];
        
        swModule->setSkipConsecutiveLinks(true);
        *swModule = sword::TOP;
        swModule->getRawEntry();        
        while(![self error]) {
            char *cStrKeyText = (char *)swModule->getKeyText();
            if(cStrKeyText) {
                NSString *keyText;
                if([self isUnicode]) {
                    keyText = [NSString stringWithUTF8String:cStrKeyText];
                } else {
                    keyText = [NSString stringWithCString:cStrKeyText encoding:NSISOLatin1StringEncoding];
                }
                
                if(keyText) {
                    [arr addObject:[keyText capitalizedString]];
                } else {
                    ALog(@"Unable to create NSString instance from string: %s", cStrKeyText);
                }
            } else {
                ALog(@"Could not get keytext from sword module!");                
            }
            
            (*swModule)++;
        }

        [moduleLock unlock];
        
        self.keys = arr;
        [self writeToCache];
    }
}

- (void)readFromCache {
	//open cached file
    NSString *cachePath = [[[Configuration config] defaultAppSupportPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"cache-%@", [self name]]];
	NSMutableArray *data = [NSMutableArray arrayWithContentsOfFile:cachePath];
    if(data != nil) {
        self.keys = data;
    } else {
        self.keys = [NSMutableArray array];
    }
}

- (void)writeToCache {
	// save cached file
    NSString *cachePath = [[[Configuration config] defaultAppSupportPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"cache-%@", [self name]]];
	[self.keys writeToFile:cachePath atomically:NO];
}


/** init with given SWModule */
- (id)initWithSWModule:(sword::SWModule *)aModule swordManager:(SwordManager *)aManager {
    self = [super initWithSWModule:aModule];
    if(self) {
        self.keys = nil;
    }
    
    return self;
}

- (void)dealloc {
    self.keys = nil;
    
    [super dealloc];
}

- (NSArray *)allKeys {
    if(self.keys == nil) {
        [self readKeys];
    }
	return [NSArray arrayWithArray:self.keys];
}

/**
 returns stripped text for key.
 nil if the key does not exist.
 */
- (NSString *)entryForKey:(NSString *)aKey {
    NSString *ret = nil;
    
	[moduleLock lock];
    [self setKeyString:aKey];    
	if([self error]) {
        ALog(@"Error on setting key!");
    } else {
        ret = [self strippedText];
    }
	[moduleLock unlock];
	
	return ret;
}

- (id)attributeValueForParsedLinkData:(NSDictionary *)data {
    return [self attributeValueForParsedLinkData:data withTextRenderType:RenderTypeStripped];
}

- (id)attributeValueForParsedLinkData:(NSDictionary *)data withTextRenderType:(RenderType)textType {
    id ret = nil;
    
    NSString *attrType = data[ATTRTYPE_TYPE];
    if([attrType isEqualToString:@"scriptRef"] || 
       [attrType isEqualToString:@"scripRef"] ||
       [attrType isEqualToString:@"Greek"] ||
       [attrType isEqualToString:@"Hebrew"] ||
       [attrType hasPrefix:@"strongMorph"] || [attrType hasPrefix:@"robinson"]) {
        NSString *key = data[ATTRTYPE_VALUE];
        ret = [self strippedTextEntriesForReference:key];
    }
    
    return ret;
}

#pragma mark - SwordModuleAccess


- (long)entryCount {
    return [self.allKeys count];
}

@end

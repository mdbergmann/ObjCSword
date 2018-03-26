//
//  SwordModuleIndex.m
//  ObjCSword
//
//  Created by Manfred Bergmann on 13.06.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import "SwordModule+Index.h"
#import "SwordModuleTextEntry.h"

@implementation SwordModule(Index)

- (BOOL)hasSearchIndex {
	NSString *dataPath = [self configFileEntryForConfigKey:@"AbsoluteDataPath"];
	dataPath = [dataPath stringByAppendingPathComponent:@"lucene"];
	dataPath = [dataPath stringByAppendingPathComponent:@"segments"];

	return [[NSFileManager defaultManager] fileExistsAtPath:dataPath];
}

- (void)createSearchIndex {
	[self swModule]->createSearchFramework();
}

- (void)deleteSearchIndex {
	[self swModule]->deleteSearchFramework();
}

- (NSArray *)performIndexSearch:(NSString *)searchString {
	sword::ListKey results = [self swModule]->search([searchString UTF8String], -4);
	results.sort();

	NSMutableArray *retArray = [NSMutableArray array];
	if(results.getCount() > 0) {
		while(!results.popError()) {
            NSString *keyString = [NSString stringWithUTF8String:results.getText()];
			SwordModuleTextEntry *entry = [SwordModuleTextEntry textEntryForKey:keyString andText:nil];
			[retArray addObject:entry];
			results++;
		}
	}
	return retArray;
}

@end

/*	SwordManager.mm - Sword API wrapper for Modules.

    Copyright 2008 Manfred Bergmann
    Based on code by Will Thimbleby

	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation version 2.

	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
	even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
	General Public License for more details. (http://www.gnu.org/licenses/gpl.html)
*/

#import <ObjCSword/ObjCSword.h>
#import "Notifications.h"

#include "encfiltmgr.h"

using std::string;
using std::list;

@interface SwordManager ()

@property (strong, readwrite) NSDictionary *modules;
@property (readwrite) BOOL deleteSWMgr;

- (void)setFiltersToModule:(SwordModule *)mod;

@end


@implementation SwordManager

# pragma mark - class methods

static SwordManager *instance = nil;

+ (NSArray *)moduleTypes {
    return @[SWMOD_TYPES_BIBLES, SWMOD_TYPES_COMMENTARIES, SWMOD_TYPES_DICTIONARIES, SWMOD_TYPES_GENBOOKS];
}

+ (SwordManager *)managerWithPath:(NSString *)path {
    SwordManager *manager = [[SwordManager alloc] initWithPath:path];
    return manager;
}

+ (SwordManager *)defaultManager {
    if(instance == nil) {
        // use default path
        instance = [[SwordManager alloc] initWithPath:[[Configuration config] defaultModulePath]];
    }
    
	return instance;
}

- (void)useAsDefaultManager {
    instance = self;
}

- (id)initWithPath:(NSString *)path {
	if((self = [super init])) {
        ALog(@"Init with path:%@", path);
        self.deleteSWMgr = YES;
        self.modulesPath = path;
		self.managerLock = (id) [[NSRecursiveLock alloc] init];

        [self initManager];
        
        // all global options off
        sword::StringList options = swManager->getGlobalOptions();
        sword::StringList::iterator	it;
        for(it = options.begin(); it != options.end(); it++) {
            [self setGlobalOption:[NSString stringWithCString:it->c_str() encoding:NSUTF8StringEncoding] value:SW_OFF];
        }
    }	
	
	return self;
}

- (id)initWithSWMgr:(sword::SWMgr *)aSWMgr {
    self = [super init];
    if(self) {
        ALog(@"Init with temporary SWMgr");
        swManager = aSWMgr;
        self.deleteSWMgr = NO;
        self.managerLock = (id) [[NSRecursiveLock alloc] init];
    }
    
    return self;
}


- (void)dealloc {
    DLog(@"");
    if(self.deleteSWMgr) {
        // only delete swManager is we created it
        // if it came from someplace else then we're not responsible
        ALog(@"Deleting SWMgr!");
        delete swManager;
    }
}

- (void)initManager {
    DLog(@"");
	[self.managerLock lock];
    if(self.modulesPath && [self.modulesPath length] > 0) {
        
        NSFileManager *fm = [NSFileManager defaultManager];
        if(![fm fileExistsAtPath:self.modulesPath]) {
            [self createModuleFolderTemplate];
        }

        swManager = new sword::SWMgr([self.modulesPath UTF8String], true, new sword::EncodingFilterMgr(sword::ENC_UTF8));

        if(!swManager) {
            ALog(@"Cannot create SWMgr instance for default module path!");
        } else {
            NSArray *subDirs = [fm contentsOfDirectoryAtPath:self.modulesPath error:NULL];
            NSString *subDir;
            for(subDir in subDirs) {
                // as long as it's not hidden
                if(![subDir hasPrefix:@"."] && 
                   ![subDir isEqualToString:@"InstallMgr"] && 
                   ![subDir isEqualToString:@"mods.d"] &&
                   ![subDir isEqualToString:@"modules"]) {
                    NSString *fullSubDir = [self.modulesPath stringByAppendingPathComponent:subDir];
                    fullSubDir = [fullSubDir stringByStandardizingPath];
                    
                    //if its a directory
                    BOOL directory;
                    if([fm fileExistsAtPath:fullSubDir isDirectory:&directory]) {
                        if(directory) {
                            DLog(@"Augmenting folder: %@", fullSubDir);
                            swManager->augmentModules([fullSubDir UTF8String]);
                            DLog(@"Augmenting folder done");
                        }
                    }
                }
            }
        }
    }
	[self.managerLock unlock];
}

- (void)reloadManager {
    if(swManager != NULL) {
        swManager->Load();
    }
}

- (void)createModuleFolderTemplate {
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm createDirectoryAtPath:self.modulesPath withIntermediateDirectories:NO attributes:nil error:NULL];
    [fm createDirectoryAtPath:[self.modulesPath stringByAppendingPathComponent:@"mods.d"] withIntermediateDirectories:NO attributes:nil error:NULL];
    [fm createDirectoryAtPath:[self.modulesPath stringByAppendingPathComponent:@"modules"] withIntermediateDirectories:NO attributes:nil error:NULL];
}

- (void)addModulesPath:(NSString *)path {
	[self.managerLock lock];
	swManager->augmentModules([path UTF8String]);
	[self.managerLock unlock];
}

- (void)setFiltersToModule:(SwordModule *)mod {
    // prepare display filters

    // only add if empty
    if(![mod swModule]->getRenderFilters().empty()) {
        return;
    }
    
    id<FilterProvider> filterProvider = [[FilterProviderFactory factory] get];

    switch([mod swModule]->getMarkup()) {
        case sword::FMT_GBF:
            [mod setRenderFilter:[filterProvider newGbfRenderFilter]];
            [mod setStripFilter:[filterProvider newGbfPlainFilter]];
            break;
        case sword::FMT_THML:
            [mod setRenderFilter:[filterProvider newThmlRenderFilter]];
            [mod setStripFilter:[filterProvider newThmlPlainFilter]];
            break;
        case sword::FMT_OSIS:
            [mod setRenderFilter:[filterProvider newOsisRenderFilter]];
            [mod setStripFilter:[filterProvider newOsisPlainFilter]];
            break;
        case sword::FMT_TEI:
            [mod setRenderFilter:[filterProvider newTeiRenderFilter]];
            [mod setStripFilter:[filterProvider newTeiPlainFilter]];
            break;
        case sword::FMT_PLAIN:
        default:
            [mod setRenderFilter:[filterProvider newOsisPlainFilter]];
            break;
    }
}

- (SwordModule *)moduleWithName:(NSString *)name {
    
    sword::SWModule *mod = [self getSWModuleWithName:name];
    if(mod == NULL) {
        ALog(@"No module by that name: %@!", name);
        return nil;
        
    } else {
        // temporary instance
        NSString *type = [NSString stringWithUTF8String:mod->getType()];
        
        ModuleType aType = [SwordModule moduleTypeForModuleTypeString:type];
        SwordModule* swMod = [SwordModule moduleForType:aType swModule:mod];
        [self setFiltersToModule:swMod];
        
        return swMod;
    }
}

- (void)setCipherKey:(NSString *)key forModuleNamed:(NSString *)name {
	swManager->setCipherKey([name UTF8String], [key UTF8String]);
}

#pragma mark - module access

- (void)setGlobalOption:(NSString *)option value:(NSString *)value {
	[self.managerLock lock];
    swManager->setGlobalOption([option UTF8String], [value UTF8String]);
	[self.managerLock unlock];
}

- (BOOL)globalOption:(NSString *)option {
    return [[NSString stringWithUTF8String:swManager->getGlobalOption([option UTF8String])] isEqualToString:SW_ON];
}

- (NSInteger)numberOfModules {
    return swManager->Modules.size();
}

- (NSDictionary *)allModules {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    sword::SWModule *mod;
    for(sword::ModMap::iterator it = swManager->Modules.begin(); it != swManager->Modules.end(); it++) {
        mod = it->second;
        if(mod) {
            SwordModule *swMod = [self moduleWithName:[NSString stringWithUTF8String:mod->getName()]];
            [dict setObject:swMod forKey:[swMod name]];
        }
    }
    return [NSDictionary dictionaryWithDictionary:dict];
}

- (NSArray *)moduleNames {
    return [[self allModules] allKeys];
}

- (NSArray *)sortedModuleNames {
    return [[self moduleNames] sortedArrayUsingSelector:@selector(compare:)];
}

- (NSArray *)modulesForFeature:(NSString *)feature {
    NSMutableArray *ret = [NSMutableArray array];
    for(SwordModule *mod in [[self allModules] allValues]) {
        if([mod hasFeature:feature]) {
            [ret addObject:mod];
        }
    }
	
    // sort
    NSArray *sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES]];
    [ret sortUsingDescriptors:sortDescriptors];

	return [NSArray arrayWithArray:ret];
}

- (NSArray *)modulesForType:(ModuleType)type {
    NSMutableArray *ret = [NSMutableArray array];
    for(SwordModule *mod in [[self allModules] allValues]) {
        if([mod type] == type || type == All) {
            [ret addObject:mod];
        }
    }
    
    // sort
    NSArray *sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES]];
    [ret sortUsingDescriptors:sortDescriptors];
    
	return [NSArray arrayWithArray:ret];
}

- (NSArray *)modulesForCategory:(ModuleCategory)cat {
    NSMutableArray *ret = [NSMutableArray array];
    for(SwordModule *mod in [[self allModules] allValues]) {
        if([mod category] == cat) {
            [ret addObject:mod];
        }
    }
    
    NSArray *sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES]];
    [ret sortUsingDescriptors:sortDescriptors];
    
	return [NSArray arrayWithArray:ret];    
}

#pragma mark - lowLevel methods

- (sword::SWMgr *)swManager {
    return swManager;
}

- (sword::SWModule *)getSWModuleWithName:(NSString *)moduleName {
	return swManager->Modules[[moduleName UTF8String]];
}

@end

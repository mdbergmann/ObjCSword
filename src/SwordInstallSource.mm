//
//  SwordInstallSource.mm
//  Eloquent
//
//  Created by Manfred Bergmann on 13.08.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "SwordInstallSource.h"
#import "SwordInstallSourceManager.h"
#import "SwordManager.h"

@interface SwordInstallSource () {
    sword::InstallSource *swInstallSource;
}

@end

@implementation SwordInstallSource

@dynamic caption;
@dynamic type;
@dynamic source;
@dynamic directory;

// init
- (id)init {
    self = [super init];
    if(self) {
        swInstallSource = new sword::InstallSource("", "");
        self.deleteOnDealloc = YES;
    }
    
    return self;
}

- (id)initWithType:(NSString *)aType {
    self = [self init];
    if(self) {
        swInstallSource->type = [aType UTF8String];
    }
    
    return self;
}

/** init with given source */
- (id)initWithSource:(sword::InstallSource *)is {
    self = [super init];
    if(self) {
        swInstallSource = is;
        self.deleteOnDealloc = NO;
    }
    
    return self;
}

- (void)dealloc {
    ALog(@"");
    if(swInstallSource != NULL && self.deleteOnDealloc) {
        ALog(@"Deleting InstallSource");
        delete swInstallSource;
    }

    [super dealloc];
}

- (NSString *)caption {
    return [[[NSString alloc] initWithUTF8String:swInstallSource->caption] autorelease];
}

- (void)setCaption:(NSString *)aCaption {
    swInstallSource->caption = [aCaption UTF8String];
}

- (NSString *)type {
    return [[[NSString alloc] initWithUTF8String:swInstallSource->type] autorelease];
}

- (void)setType:(NSString *)aType {
    swInstallSource->type = [aType UTF8String];
}

- (NSString *)source {
    return [[[NSString alloc] initWithUTF8String:swInstallSource->source] autorelease];
}

- (void)setSource:(NSString *)aSource {
    swInstallSource->source = [aSource UTF8String];
}

- (NSString *)directory {
    return [[[NSString alloc] initWithUTF8String:swInstallSource->directory] autorelease];
}

- (void)setDirectory:(NSString *)aDir {
    swInstallSource->directory = [aDir UTF8String];
}

- (BOOL)isLocalSource {
    return [[self source] isEqualToString:@"localhost"];
}

// get config entry
- (NSString *)configEntry {
    return [NSString stringWithFormat:@"%@|%@|%@", [self caption], [self source], [self directory]];
}

/** install module */
- (void)installModuleWithName:(NSString *)mName usingManager:(SwordManager *)swManager withInstallController:(SwordInstallSourceManager *)sim {
    sword::InstallMgr *im = [sim installMgr];
    im->installModule([swManager swManager], 0, [mName UTF8String], swInstallSource);
}

/** list all modules of this source */
- (NSDictionary *)allModules {
    SwordManager *sm = [self swordManager];
    if(sm) {
        return [sm allModules];
    } else {
        ALog(@"Have nil SwordManager");        
    }
    return nil;
}

- (NSArray *)listModulesForType:(ModuleType)aType {
    SwordManager *sm = [self swordManager];
    if(sm) {
        return [sm modulesForType:aType];
    } else {
        ALog(@"Have nil SwordManager");        
    }
    return nil;
}

/** list module types */
- (NSArray *)listModuleTypes {
    return [SwordManager moduleTypes];
}

- (SwordManager *)swordManager {
    // create SwordManager from the SWMgr of this source
    sword::SWMgr *mgr;
    if([self isLocalSource]) {
        // create SwordManager from new SWMgr of path
        mgr = new sword::SWMgr([[self directory] UTF8String], true, NULL, false, false);
    } else {
        // create SwordManager from the SWMgr of this source
        mgr = swInstallSource->getMgr();
    }

    if(mgr == nil) {
        ALog(@"Have a nil SWMgr!");
        return nil;

    } else {
        return [[[SwordManager alloc] initWithSWMgr:mgr] autorelease];
    }
}

/** low level API */
- (sword::InstallSource *)installSource {
    return swInstallSource;
}

@end

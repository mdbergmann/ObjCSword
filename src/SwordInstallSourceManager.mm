//
//  SwordInstallManager.mm
//  Eloquent
//
//  Created by Manfred Bergmann on 13.08.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "SwordInstallSourceManager.h"
#import "SwordInstallSource.h"
#import "SwordManager.h"
#import "ObjCSword_Prefix.pch"

#ifdef __cplusplus
typedef std::map<sword::SWBuf, sword::InstallSource *> InstallSourceMap;
typedef sword::multimapwithdefault<sword::SWBuf, sword::SWBuf, std::less <sword::SWBuf> > ConfigEntMap;
#endif

#define INSTALLSOURCE_SECTION_TYPE_FTP  "FTPSource"
#define INSTALLSOURCE_SECTION_TYPE_HTTP	"HTTPSource"


@interface SwordInstallSourceManager () {
    sword::InstallMgr *swInstallMgr;
}

@property (retain, readwrite) NSString *configPath;
@property (readwrite) BOOL createConfigPath;

@end

@implementation SwordInstallSourceManager

// -------------------- methods --------------------

static SwordInstallSourceManager *singleton = nil;
// initialization
+ (SwordInstallSourceManager *)defaultManager {
    if(singleton == nil) {
        singleton = [[SwordInstallSourceManager alloc] init];
    }
    
    return singleton;
}

/**
base path of the module installation
 */
- (id)init {
    self = [super init];
    if(self) {
        [self setCreateConfigPath:NO];
        [self setConfigPath:nil];
        [self setFtpUser:@"ftp"];
        [self setFtpPassword:@"ObjCSword@crosswire.org"];
    }
    
    return self;
}

/**
 initialize with given path
 */
- (id)initWithPath:(NSString *)aPath createPath:(BOOL)create {
    self = [self init];
    if(self) {
        [self setCreateConfigPath:create];
        [self setConfigPath:aPath];
    }
    
    return self;
}

- (void)useAsDefaultManager {
    singleton = self;
}

- (void)dealloc {
    DLog(@"");
    self.configPath = nil;
    self.ftpUser = nil;
    self.ftpPassword = nil;
    
    if(swInstallMgr != NULL) {
        DLog(@"deleting InstallMgr");
        delete swInstallMgr;
    }

    [super dealloc];
}

- (void)initManager {
    [self setupConfigPath];

    // safe disclaimer flag
    BOOL disclaimerConfirmed = NO;
    if(swInstallMgr != NULL) {
        disclaimerConfirmed = [self userDisclaimerConfirmed];
    }

    if(swInstallMgr == NULL) {
        DLog(@"Initializing swInstallMgr");
        swInstallMgr = [self newDefaultInstallMgr];
        if(swInstallMgr == nil) {
            ALog(@"Could not initialize InstallMgr!");

        } else {
            if(![self existsConfigFile]) {
                // save initial config
                [self saveConfig];
            }

            [self setUserDisclaimerConfirmed:disclaimerConfirmed];

            if(![self existsDefaultInstallSource]) {
                [self addDefaultInstallSource];
                [self saveConfig];
            }
//            [self readConfig];
        }
    }
}

- (sword::InstallMgr *)newDefaultInstallMgr {
    ALog(@"Creating InstallMgr with: %@, %i, %@, %@", [self configPath], 0, [self ftpUser], [self ftpPassword]);
    InstallMgr *installMgr = new sword::InstallMgr(
        [[self configPath] UTF8String],
        0,
        sword::SWBuf([[self ftpUser] UTF8String]),
        sword::SWBuf([[self ftpPassword] UTF8String])
    );
    installMgr->setFTPPassive(true);

    return installMgr;
}

- (BOOL)existsDefaultInstallSource {
    return !(swInstallMgr->sources.find([@"CrossWire" UTF8String]) == swInstallMgr->sources.end());
}

- (void)addDefaultInstallSource {
    SwordInstallSource *is = [[[SwordInstallSource alloc] initWithType:INSTALLSOURCE_TYPE_FTP] autorelease];
    [is setCaption:@"CrossWire"];
    [is setSource:@"ftp.crosswire.org"];
    [is setDirectory:@"/pub/sword/raw"];

    [self addInstallSource:is reload:NO];
}

- (void)setupConfigPath {
    if([self configPath] == nil) {
        ALog(@"No config path configured!");
        return;
    }

    // check for existence
    NSFileManager *fm = [NSFileManager defaultManager];
    ALog(@"Checking for config path at: %@", [self configPath]);
    if(![fm fileExistsAtPath:[self configPath]] && [self createConfigPath]) {
        ALog(@"Config dir doesn't exist, creating it...");
        [fm createDirectoryAtPath:[self configPath] withIntermediateDirectories:NO attributes:nil error:NULL];
        ALog(@"Config dir doesn't exist, creating it...done");
    }

}

- (BOOL)existsConfigFile {
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir;
    return [fm fileExistsAtPath:[self configPath] isDirectory:&isDir] && isDir;
}

- (NSDictionary *)allInstallSources {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for(InstallSourceMap::iterator it = swInstallMgr->sources.begin(); it != swInstallMgr->sources.end(); it++) {
        sword::InstallSource *sis = it->second;
        SwordInstallSource *is = [[[SwordInstallSource alloc] initWithSource:sis] autorelease];

        // compatibility, see below at addInstallSource
        if([[is type] isEqualToString:@INSTALLSOURCE_SECTION_TYPE_FTP]) {
            [is setType:INSTALLSOURCE_TYPE_FTP];
        }

        ALog(@"Adding install source: %@", [is caption]);
        dict[[is caption]] = is;
    }

    return [NSDictionary dictionaryWithDictionary:dict];
}

- (void)addInstallSource:(SwordInstallSource *)is reload:(BOOL)doReload {
    ALog(@"Adding install source: %@", [is caption]);

    if([[is type] isEqualToString:INSTALLSOURCE_TYPE_FTP]) {
        [is setType:@INSTALLSOURCE_SECTION_TYPE_FTP];
    } else {
        [is setType:@INSTALLSOURCE_SECTION_TYPE_HTTP];
    }

    [is setDeleteOnDealloc:NO];     // InstallMgr will take care.
    sword::InstallSource *swIs = [is installSource];
    swInstallMgr->sources[swIs->caption] = swIs;
}

- (void)removeInstallSource:(SwordInstallSource *)is reload:(BOOL)doReload {
    ALog(@"Removing install source: %@", [is caption]);

    sword::InstallSource *swIs = [is installSource];
    swInstallMgr->sources.erase(swIs->caption);
}

- (void)updateInstallSource:(SwordInstallSource *)is {
    ALog(@"Updating install source [remove|add]: %@", [is caption]);
    // first remove, then add again
    [self removeInstallSource:is reload:NO];
    [self addInstallSource:is reload:NO];
}

- (int)installModule:(SwordModule *)aModule fromSource:(SwordInstallSource *)is withManager:(SwordManager *)manager {
    ALog(@"Installing module: %@, from source: %@", [aModule name], [is caption]);
    int stat;
    if([is isLocalSource]) {
        stat = swInstallMgr->installModule([manager swManager], [[is directory] UTF8String], [[aModule name] UTF8String]);
    } else {
        stat = swInstallMgr->installModule([manager swManager], 0, [[aModule name] UTF8String], [is installSource]);
    }
    return stat;
}

- (int)uninstallModule:(SwordModule *)aModule fromManager:(SwordManager *)swManager {
    ALog(@"Removing module: %@", [aModule name]);
    return swInstallMgr->removeModule([swManager swManager], [[aModule name] UTF8String]);
}

- (int)refreshMasterRemoteInstallSourceList {
    ALog(@"Refreshing remote install sources from master repo.");
    int stat = swInstallMgr->refreshRemoteSourceConfiguration();
    if(stat) {
        ALog(@"Unable to refresh with master install source!");
    }
    
    return stat;
}

// list modules in sources
- (NSDictionary *)listModulesForSource:(SwordInstallSource *)is {
    return [is allModules];
}

/** refresh modules of this source 
 refreshing the install source is necessary before installation of 
 */
- (int)refreshInstallSource:(SwordInstallSource *)is {
    ALog(@"Refreshing install source:%@", [is caption]);
    int ret = 1;
    if(is == nil) {
        ALog(@"Install source is nil");
    } else {
        if(![[is source] isEqualToString:@"localhost"]) {
            ret = swInstallMgr->refreshRemoteSource([is installSource]);
        }
    }
    
    return ret;
}

/**
 returns an array of Modules with status set
 */
- (NSArray *)moduleStatusInInstallSource:(SwordInstallSource *)is baseManager:(SwordManager *)baseMgr {
    ALog(@"Retrieving module status for install source:%@", [is caption]);
    // get modules map
    NSMutableArray *ar = [NSMutableArray array];
    std::map<sword::SWModule *, int> modStats = swInstallMgr->getModuleStatus(*[baseMgr swManager], *[[is swordManager] swManager]);
    sword::SWModule *module;
	int status;
	for(std::map<sword::SWModule *, int>::iterator it = modStats.begin(); it != modStats.end(); it++) {
		module = it->first;
		status = it->second;
        
        SwordModule *mod = [[[SwordModule alloc] initWithSWModule:module] autorelease];
        [mod setStatus:status];
        [ar addObject:mod];
	}

    return [NSArray arrayWithArray:ar];
}

- (BOOL)userDisclaimerConfirmed {
    return swInstallMgr->isUserDisclaimerConfirmed();
}

- (void)setUserDisclaimerConfirmed:(BOOL)flag {
    swInstallMgr->setUserDisclaimerConfirmed(flag);
}

- (void)saveConfig {
    swInstallMgr->saveInstallConf();
}

- (void)readConfig {
    swInstallMgr->readInstallConf();
}

/** low level access */
- (sword::InstallMgr *)installMgr {
    return swInstallMgr;
}

@end

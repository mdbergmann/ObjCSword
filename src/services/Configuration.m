//
//  Configuration.m
//  ObjCSword
//
//  Created by Manfred Bergmann on 13.06.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import "Configuration.h"

@interface Configuration ()
@property (retain, readwrite) id<Configuration> impl;
@end

@implementation Configuration

+ (Configuration *)config {
    static Configuration *instance = nil;
    if(instance == nil) {
        instance = [[Configuration alloc] init];
    }
    return instance;
}

+ (Configuration *)configWithImpl:(id<Configuration>)configImpl {
    [[Configuration config] setImpl:configImpl];
    return [Configuration config];
}

- (id)init {
    return [super init];
}

- (void)dealloc {
    self.impl = nil;
    [super dealloc];
}

#pragma mark Configuration implementation

- (NSString *)osVersion {return [self.impl osVersion];}
- (NSString *)bundleVersion {return [self.impl bundleVersion];}
- (NSString *)defaultModulePath {return [self.impl defaultModulePath];}
- (NSString *)defaultAppSupportPath {return [self.impl defaultAppSupportPath];}
- (NSString *)tempFolder {return [self.impl tempFolder];}
- (NSString *)logFile {return [self.impl logFile];}

@end

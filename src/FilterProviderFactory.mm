//
// Created by mbergmann on 18.12.12.
//
//


#import "FilterProviderFactory.h"
#import "DefaultFilterProvider.h"

@interface FilterProviderFactory ()
@property(retain, nonatomic) id <FilterProvider> filterProvider;
@end

@implementation FilterProviderFactory

+ (FilterProviderFactory *)factory {
    static FilterProviderFactory *singleton = nil;

    if(singleton == nil) {
        singleton = [[FilterProviderFactory alloc] init];
    }

    return singleton;
}

- (void)initWith:(id <FilterProvider>)aFilterProvider {
    self.filterProvider = aFilterProvider;
}

- (void)dealloc {
    self.filterProvider = nil;
    
    [super dealloc];
}

- (id <FilterProvider>)get {
    if(self.filterProvider == nil) {
        ALog(@"FilterProvider is nil!");
    }
    return self.filterProvider;
}

@end

//
// Created by mbergmann on 18.12.12.
//
//


#import "FilterProviderFactory.h"
#import "DefaultFilterProvider.h"

@interface FilterProviderFactory ()

@property(nonatomic, strong) id <FilterProvider> filterProvider;

@end

@implementation FilterProviderFactory

+ (instancetype)factory {
    static FilterProviderFactory *singleton = nil;

    if(singleton == nil) {
        singleton = [[FilterProviderFactory alloc] init];
    }

    return singleton;
}

- (void)initWithImpl:(id <FilterProvider>)aFilterProvider {
    self.filterProvider = aFilterProvider;
}

- (id <FilterProvider>)get {
    if(self.filterProvider == nil) {
        ALog(@"FilterProvider is nil!");
    }
    return self.filterProvider;
}



@end

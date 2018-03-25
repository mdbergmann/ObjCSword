//
// Created by mbergmann on 18.12.12.
//
//


#import "DefaultFilterProvider.h"

@implementation DefaultFilterProvider

- (SwordFilter *)newOsisRenderFilter {
    return [SwordOsisHtmlRefFilter newFilter];
}

- (SwordFilter *)newOsisPlainFilter {
    return [SwordOsisPlainFilter newFilter];
}

- (SwordFilter *)newGbfRenderFilter {
    return [SwordGbfHtmlFilter newFilter];
}

- (SwordFilter *)newGbfPlainFilter {
    return [SwordGbfPlainFilter newFilter];
}

- (SwordFilter *)newThmlRenderFilter {
    return [SwordThmlHtmlFilter newFilter];
}

- (SwordFilter *)newThmlPlainFilter {
    return [SwordThmlPlainFilter newFilter];
}

- (SwordFilter *)newTeiRenderFilter {
    return [SwordTeiHtmlFilter newFilter];
}

- (SwordFilter *)newTeiPlainFilter {
    return [SwordTeiPlainFilter newFilter];
}

@end

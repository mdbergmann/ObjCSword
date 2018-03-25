//
// Created by mbergmann on 18.12.12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "SwordFilter.h"
#import "osishtmlhref.h"
#import "osisplain.h"
#import "osisxhtml.h"
#import "thmlhtmlhref.h"
#import "thmlplain.h"
#import "gbfhtmlhref.h"
#import "gbfplain.h"
#import "teihtmlhref.h"
#import "teixhtml.h"
#import "teiplain.h"

@interface SwordFilter ()

- (id)initWithSWFilter:(sword::SWFilter *)swFilter;

@end

@implementation SwordFilter {
    sword::SWFilter *swFilter;
}

- (id)initWithSWFilter:(sword::SWFilter *)aFilter {
    self = [super init];
    if (self) {
        swFilter = aFilter;
    }

    return self;
}

- (void)dealloc {
    if(swFilter != NULL) delete swFilter;

    [super dealloc];
}

- (sword::SWFilter *)swFilter {
    return swFilter;
}

@end

@implementation SwordOsisHtmlRefFilter
+ (SwordOsisHtmlRefFilter *)newFilter {
    return [[SwordOsisHtmlRefFilter alloc] init];
}

- (id)init {
    return [super initWithSWFilter:new sword::OSISHTMLHREF()];
}
@end

@implementation SwordOsisXHtmlFilter
+ (SwordOsisXHtmlFilter *)newFilter {
    return [[SwordOsisXHtmlFilter alloc] init];
}

- (id)init {
    return [super initWithSWFilter:new sword::OSISXHTML()];
}
@end

@implementation SwordOsisPlainFilter
+ (SwordOsisPlainFilter *)newFilter {
    return [[SwordOsisPlainFilter alloc] init];
}

- (id)init {
    return [super initWithSWFilter:new sword::OSISPlain()];
}
@end

@implementation SwordThmlHtmlFilter
+ (SwordThmlHtmlFilter *)newFilter {
    return [[SwordThmlHtmlFilter alloc] init];
}

- (id)init {
    return [super initWithSWFilter:new sword::ThMLHTMLHREF()];
}
@end

@implementation SwordThmlPlainFilter
+ (SwordThmlPlainFilter *)newFilter {
    return [[SwordThmlPlainFilter alloc] init];
}

- (id)init {
    return [super initWithSWFilter:new sword::ThMLPlain()];
}
@end

@implementation SwordGbfHtmlFilter
+ (SwordGbfHtmlFilter *)newFilter {
    return [[SwordGbfHtmlFilter alloc] init];
}

- (id)init {
    return [super initWithSWFilter:new sword::ThMLHTMLHREF()];
}
@end

@implementation SwordGbfPlainFilter
+ (SwordGbfPlainFilter *)newFilter {
    return [[SwordGbfPlainFilter alloc] init];
}

- (id)init {
    return [super initWithSWFilter:new sword::ThMLPlain()];
}
@end

@implementation SwordTeiHtmlFilter
+ (SwordTeiHtmlFilter *)newFilter {
    return [[SwordTeiHtmlFilter alloc] init];
}

- (id)init {
    return [super initWithSWFilter:new sword::TEIHTMLHREF()];
}
@end

@implementation SwordTeiXHtmlFilter
+ (SwordTeiXHtmlFilter *)newFilter {
    return [[SwordTeiXHtmlFilter alloc] init];
}

- (id)init {
    return [super initWithSWFilter:new sword::TEIXHTML()];
}
@end

@implementation SwordTeiPlainFilter
+ (SwordTeiPlainFilter *)newFilter {
    return [[SwordTeiPlainFilter alloc] init];
}

- (id)init {
    return [super initWithSWFilter:new sword::TEIPlain()];
}
@end


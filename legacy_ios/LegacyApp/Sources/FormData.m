#import "FormData.h"

@implementation FormData

- (instancetype)init {
    self = [super init];
    if (self) {
        _name = @"";
        _email = @"";
        _message = @"";
    }
    return self;
}

@end

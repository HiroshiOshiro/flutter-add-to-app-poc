#import "ItunesTrack.h"

@implementation ItunesTrack

- (instancetype)init {
    self = [super init];
    if (self) {
        _trackName = @"";
        _artistName = @"";
        _artworkUrl = @"";
    }
    return self;
}

@end

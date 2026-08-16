#import "ItunesTrack.h"

@implementation ItunesTrack

- (instancetype)init {
    self = [super init];
    if (self) {
        _trackName = @"";
        _artistName = @"";
        _collectionName = @"";
        _primaryGenreName = @"";
        _artworkUrl = @"";
        _artworkUrlLarge = @"";
    }
    return self;
}

@end

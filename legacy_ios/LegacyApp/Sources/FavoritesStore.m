#import "FavoritesStore.h"

static NSString *const kFavoriteIdsKey = @"favorite_track_ids";

@implementation FavoritesStore

+ (BOOL)isFavorite:(NSInteger)trackId {
    return [[self favoriteIds] containsObject:@(trackId)];
}

+ (void)setFavorite:(BOOL)favorite forTrackId:(NSInteger)trackId {
    NSMutableArray<NSNumber *> *ids = [[self favoriteIds] mutableCopy];
    NSNumber *key = @(trackId);
    if (favorite) {
        if (![ids containsObject:key]) {
            [ids addObject:key];
        }
    } else {
        [ids removeObject:key];
    }
    [[NSUserDefaults standardUserDefaults] setObject:ids forKey:kFavoriteIdsKey];
}

+ (NSArray<NSNumber *> *)favoriteIds {
    return [[NSUserDefaults standardUserDefaults] arrayForKey:kFavoriteIdsKey] ?: @[];
}

@end

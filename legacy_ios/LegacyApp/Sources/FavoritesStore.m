#import "FavoritesStore.h"
#import "FavoritesDatabase.h"

@implementation FavoritesStore

+ (BOOL)isFavorite:(NSInteger)trackId {
    return [[FavoritesDatabase sharedDatabase] isFavorite:trackId];
}

+ (void)setFavorite:(BOOL)favorite forTrackId:(NSInteger)trackId {
    [[FavoritesDatabase sharedDatabase] setFavorite:favorite forTrackId:trackId];
}

@end

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FavoritesDatabase : NSObject

+ (instancetype)sharedDatabase;

- (BOOL)isFavorite:(NSInteger)trackId;
- (void)setFavorite:(BOOL)favorite forTrackId:(NSInteger)trackId;

@end

NS_ASSUME_NONNULL_END

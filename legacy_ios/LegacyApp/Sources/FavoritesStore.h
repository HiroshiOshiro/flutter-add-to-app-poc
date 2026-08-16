#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FavoritesStore : NSObject

+ (BOOL)isFavorite:(NSInteger)trackId;
+ (void)setFavorite:(BOOL)favorite forTrackId:(NSInteger)trackId;

@end

NS_ASSUME_NONNULL_END

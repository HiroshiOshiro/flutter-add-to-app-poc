#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ItunesTrack : NSObject

@property (nonatomic, assign) NSInteger trackId;
@property (nonatomic, copy) NSString *trackName;
@property (nonatomic, copy) NSString *artistName;
@property (nonatomic, copy) NSString *collectionName;
@property (nonatomic, copy) NSString *primaryGenreName;
@property (nonatomic, copy) NSString *artworkUrl;
@property (nonatomic, copy) NSString *artworkUrlLarge;

@end

NS_ASSUME_NONNULL_END

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ItunesTrack : NSObject

@property (nonatomic, copy) NSString *trackName;
@property (nonatomic, copy) NSString *artistName;
@property (nonatomic, copy) NSString *artworkUrl;

@end

NS_ASSUME_NONNULL_END

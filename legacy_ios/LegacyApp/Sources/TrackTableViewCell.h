#import <UIKit/UIKit.h>
#import "ItunesTrack.h"

NS_ASSUME_NONNULL_BEGIN

@interface TrackTableViewCell : UITableViewCell

- (void)configureWithTrack:(ItunesTrack *)track;

@end

NS_ASSUME_NONNULL_END

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ArtworkLoader : NSObject

+ (void)loadURLString:(NSString *)urlString intoImageView:(UIImageView *)imageView;

@end

NS_ASSUME_NONNULL_END

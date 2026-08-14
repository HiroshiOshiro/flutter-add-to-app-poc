#import <UIKit/UIKit.h>
#import "FormData.h"

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewController : UIViewController

@property (class, nonatomic, strong, readonly) FormData *sharedFormData;

@end

NS_ASSUME_NONNULL_END

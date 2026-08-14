#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FormData : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *message;

@end

NS_ASSUME_NONNULL_END

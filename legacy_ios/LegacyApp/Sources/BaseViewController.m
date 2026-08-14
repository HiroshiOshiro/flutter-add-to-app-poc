#import "BaseViewController.h"

// Shared in-memory state for the Input -> Confirm -> Complete flow.
// Every screen after this one reaches back into this file for form state
// instead of receiving it explicitly -- implicit coupling baked into the
// base class, mirroring BaseActivity on the Android side.
static FormData *_sharedFormData;

@implementation BaseViewController

+ (FormData *)sharedFormData {
    if (!_sharedFormData) {
        _sharedFormData = [[FormData alloc] init];
    }
    return _sharedFormData;
}

@end

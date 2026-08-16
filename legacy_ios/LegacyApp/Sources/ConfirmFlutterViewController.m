#import "ConfirmFlutterViewController.h"
#import "BaseViewController.h"
#import "CompleteViewController.h"
#import <FlutterPluginRegistrant/GeneratedPluginRegistrant.h>

static NSString *const kChannelName = @"com.example.legacyapp/confirm";
static NSString *const kSubmitURLString = @"https://jsonplaceholder.typicode.com/posts";

@interface ConfirmFlutterViewController ()

@property (nonatomic, strong) FlutterEngine *ownedEngine;
@property (nonatomic, strong) FlutterMethodChannel *channel;

@end

@implementation ConfirmFlutterViewController

- (instancetype)init {
    // A fresh engine per visit (rather than one warm engine reused for the
    // app's lifetime) is deliberate here: Dart's main()/initState() only
    // ever runs once per engine, so a shared long-lived engine would only
    // ever answer getInitialData with whatever the form held the very
    // first time this screen was reached -- never the current values on a
    // second visit. A fresh engine keeps each visit correct at the cost of
    // the warm-start latency; a production app would instead keep one
    // engine alive and push fresh data into it explicitly rather than
    // relying on initState.
    FlutterEngine *engine = [[FlutterEngine alloc] initWithName:@"confirm_engine"];
    [GeneratedPluginRegistrant registerWithRegistry:engine];

    // engine.binaryMessenger only works once the engine is running
    // (registering a channel handler before run() crashes inside
    // FlutterBinaryMessengerRelay), so run() must happen first. Dart's
    // first frame (and the getInitialData call inside it) only fires once
    // this view controller's view actually loads, which happens later
    // when it's pushed on screen -- well after this synchronous init
    // method has finished setting up the channel handler below.
    [engine run];

    self = [super initWithEngine:engine nibName:nil bundle:nil];
    if (self) {
        _ownedEngine = engine;
        _channel = [FlutterMethodChannel methodChannelWithName:kChannelName
                                                binaryMessenger:engine.binaryMessenger];
        __weak typeof(self) weakSelf = self;
        [_channel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
            [weakSelf handleMethodCall:call result:result];
        }];
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([call.method isEqualToString:@"getInitialData"]) {
        FormData *data = BaseViewController.sharedFormData;
        result(@{@"name": data.name, @"email": data.email, @"message": data.message});
    } else if ([call.method isEqualToString:@"confirmSubmit"]) {
        [self submitWithCompletion:^(BOOL success) {
            result(@(success));
        }];
    } else if ([call.method isEqualToString:@"goToComplete"]) {
        CompleteViewController *completeVC = [[CompleteViewController alloc] init];
        [self.navigationController pushViewController:completeVC animated:YES];
        result(nil);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)submitWithCompletion:(void (^)(BOOL success))completion {
    FormData *data = BaseViewController.sharedFormData;
    NSDictionary *body = @{
        @"name": data.name,
        @"email": data.email,
        @"message": data.message,
    };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];

    NSURL *url = [NSURL URLWithString:kSubmitURLString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = jsonData;

    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable respData, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
        BOOL success = !error && statusCode >= 200 && statusCode < 300;
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(success);
        });
    }];
    [task resume];
}

@end

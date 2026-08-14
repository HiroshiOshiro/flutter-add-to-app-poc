#import "ConfirmViewController.h"
#import "CompleteViewController.h"

static NSString *const kSubmitURLString = @"https://jsonplaceholder.typicode.com/posts";

@interface ConfirmViewController ()

@property (nonatomic, strong) UIButton *confirmButton;

@end

@implementation ConfirmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"入力内容の確認";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    FormData *data = BaseViewController.sharedFormData;

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[
        [self row:@"名前" value:data.name],
        [self row:@"メールアドレス" value:data.email],
        [self row:@"メッセージ" value:data.message],
    ]];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 20;
    stack.translatesAutoresizingMaskIntoConstraints = NO;

    self.confirmButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.confirmButton setTitle:@"確定" forState:UIControlStateNormal];
    [self.confirmButton addTarget:self action:@selector(onConfirmTapped) forControlEvents:UIControlEventTouchUpInside];
    self.confirmButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.confirmButton.accessibilityIdentifier = @"buttonConfirm";

    [self.view addSubview:stack];
    [self.view addSubview:self.confirmButton];

    [NSLayoutConstraint activateConstraints:@[
        [stack.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:24],
        [stack.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:24],
        [stack.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-24],

        [self.confirmButton.topAnchor constraintEqualToAnchor:stack.bottomAnchor constant:32],
        [self.confirmButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:24],
    ]];
}

- (UIView *)row:(NSString *)label value:(NSString *)value {
    UILabel *l = [[UILabel alloc] init];
    l.text = label;
    l.textColor = [UIColor secondaryLabelColor];
    l.font = [UIFont systemFontOfSize:13];

    UILabel *v = [[UILabel alloc] init];
    v.text = value;
    v.font = [UIFont systemFontOfSize:17];

    UIStackView *row = [[UIStackView alloc] initWithArrangedSubviews:@[l, v]];
    row.axis = UILayoutConstraintAxisVertical;
    row.spacing = 4;
    return row;
}

- (void)onConfirmTapped {
    self.confirmButton.enabled = NO;
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

    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable respData, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            strongSelf.confirmButton.enabled = YES;

            NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
            if (!error && statusCode >= 200 && statusCode < 300) {
                CompleteViewController *completeVC = [[CompleteViewController alloc] init];
                [strongSelf.navigationController pushViewController:completeVC animated:YES];
            } else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                                 message:@"送信に失敗しました"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [strongSelf presentViewController:alert animated:YES completion:nil];
            }
        });
    }];
    [task resume];
}

@end

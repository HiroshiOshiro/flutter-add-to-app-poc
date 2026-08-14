#import "CompleteViewController.h"

@implementation CompleteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"完了";
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.navigationItem.hidesBackButton = YES;

    UILabel *messageLabel = [[UILabel alloc] init];
    messageLabel.text = @"送信が完了しました";
    messageLabel.font = [UIFont systemFontOfSize:20];
    messageLabel.translatesAutoresizingMaskIntoConstraints = NO;

    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [backButton setTitle:@"最初に戻る" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(onBackTapped) forControlEvents:UIControlEventTouchUpInside];
    backButton.translatesAutoresizingMaskIntoConstraints = NO;
    backButton.accessibilityIdentifier = @"buttonBackToStart";

    [self.view addSubview:messageLabel];
    [self.view addSubview:backButton];

    [NSLayoutConstraint activateConstraints:@[
        [messageLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [messageLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:-40],

        [backButton.topAnchor constraintEqualToAnchor:messageLabel.bottomAnchor constant:24],
        [backButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
    ]];
}

- (void)onBackTapped {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end

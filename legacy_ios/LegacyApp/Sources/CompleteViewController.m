#import "CompleteViewController.h"

@implementation CompleteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"tab_memo", nil);
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.navigationItem.hidesBackButton = YES;

    UIImageView *banner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ProfileBanner"]];
    banner.contentMode = UIViewContentModeScaleAspectFit;
    banner.translatesAutoresizingMaskIntoConstraints = NO;

    UILabel *messageLabel = [[UILabel alloc] init];
    messageLabel.text = NSLocalizedString(@"complete_message", nil);
    messageLabel.font = [UIFont systemFontOfSize:20];
    messageLabel.translatesAutoresizingMaskIntoConstraints = NO;

    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [backButton setTitle:NSLocalizedString(@"action_back_to_start", nil) forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(onBackTapped) forControlEvents:UIControlEventTouchUpInside];
    backButton.translatesAutoresizingMaskIntoConstraints = NO;
    backButton.accessibilityIdentifier = @"buttonBackToStart";

    [self.view addSubview:banner];
    [self.view addSubview:messageLabel];
    [self.view addSubview:backButton];

    [NSLayoutConstraint activateConstraints:@[
        [banner.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:24],
        [banner.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [banner.widthAnchor constraintEqualToConstant:96],
        [banner.heightAnchor constraintEqualToConstant:96],

        [messageLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [messageLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:20],

        [backButton.topAnchor constraintEqualToAnchor:messageLabel.bottomAnchor constant:24],
        [backButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
    ]];
}

- (void)onBackTapped {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end

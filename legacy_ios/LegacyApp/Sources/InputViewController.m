#import "InputViewController.h"
#import "ConfirmViewController.h"

static NSString *const kPrefsDraftName = @"draft_name";
static NSString *const kPrefsDraftEmail = @"draft_email";
static NSString *const kPrefsDraftMessage = @"draft_message";

@interface InputViewController ()

@property (nonatomic, strong) UITextField *nameField;
@property (nonatomic, strong) UITextField *emailField;
@property (nonatomic, strong) UITextField *messageField;

@end

@implementation InputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"LegacyApp";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    self.nameField = [self makeFieldWithPlaceholder:@"名前"];
    self.emailField = [self makeFieldWithPlaceholder:@"メールアドレス"];
    self.emailField.keyboardType = UIKeyboardTypeEmailAddress;
    self.messageField = [self makeFieldWithPlaceholder:@"メッセージ"];

    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [nextButton setTitle:@"次へ" forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(onNextTapped) forControlEvents:UIControlEventTouchUpInside];
    nextButton.accessibilityIdentifier = @"buttonNext";

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[
        [self labeledRow:@"名前" field:self.nameField],
        [self labeledRow:@"メールアドレス" field:self.emailField],
        [self labeledRow:@"メッセージ" field:self.messageField],
        nextButton
    ]];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 20;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:stack];

    [NSLayoutConstraint activateConstraints:@[
        [stack.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:24],
        [stack.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:24],
        [stack.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-24],
    ]];

    [self loadDraft];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Re-read the draft every time this screen appears, e.g. after coming
    // back from Complete, the same way the Android InputActivity does.
    [self loadDraft];
}

- (UITextField *)makeFieldWithPlaceholder:(NSString *)placeholder {
    UITextField *field = [[UITextField alloc] init];
    field.placeholder = placeholder;
    field.borderStyle = UITextBorderStyleRoundedRect;
    [field addTarget:self action:@selector(onFieldChanged) forControlEvents:UIControlEventEditingChanged];
    return field;
}

- (UIView *)labeledRow:(NSString *)label field:(UITextField *)field {
    UILabel *l = [[UILabel alloc] init];
    l.text = label;
    l.textColor = [UIColor secondaryLabelColor];
    l.font = [UIFont systemFontOfSize:13];

    UIStackView *row = [[UIStackView alloc] initWithArrangedSubviews:@[l, field]];
    row.axis = UILayoutConstraintAxisVertical;
    row.spacing = 4;
    return row;
}

- (void)onFieldChanged {
    [self saveDraft];
}

- (void)loadDraft {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.nameField.text = [defaults stringForKey:kPrefsDraftName] ?: @"";
    self.emailField.text = [defaults stringForKey:kPrefsDraftEmail] ?: @"";
    self.messageField.text = [defaults stringForKey:kPrefsDraftMessage] ?: @"";
}

- (void)saveDraft {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.nameField.text ?: @"" forKey:kPrefsDraftName];
    [defaults setObject:self.emailField.text ?: @"" forKey:kPrefsDraftEmail];
    [defaults setObject:self.messageField.text ?: @"" forKey:kPrefsDraftMessage];
}

- (void)onNextTapped {
    FormData *data = BaseViewController.sharedFormData;
    data.name = self.nameField.text ?: @"";
    data.email = self.emailField.text ?: @"";
    data.message = self.messageField.text ?: @"";

    ConfirmViewController *confirmVC = [[ConfirmViewController alloc] init];
    [self.navigationController pushViewController:confirmVC animated:YES];
}

@end

#import "MusicViewController.h"
#import "ItunesTrack.h"
#import "TrackTableViewCell.h"

static NSString *const kSearchURLString = @"https://itunes.apple.com/search";
static NSString *const kCellReuseId = @"TrackCell";

@interface MusicViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITextField *searchField;
@property (nonatomic, strong) UIButton *searchButton;
@property (nonatomic, strong) UILabel *emptyStateLabel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<ItunesTrack *> *tracks;

@end

@implementation MusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tracks = @[];
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    self.searchField = [[UITextField alloc] init];
    self.searchField.borderStyle = UITextBorderStyleRoundedRect;
    self.searchField.placeholder = NSLocalizedString(@"music_search_hint", nil);
    self.searchField.returnKeyType = UIReturnKeySearch;
    self.searchField.delegate = self;
    self.searchField.translatesAutoresizingMaskIntoConstraints = NO;

    self.searchButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.searchButton setTitle:NSLocalizedString(@"music_search_button", nil) forState:UIControlStateNormal];
    [self.searchButton addTarget:self action:@selector(onSearchTapped) forControlEvents:UIControlEventTouchUpInside];
    self.searchButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.searchButton setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

    self.emptyStateLabel = [[UILabel alloc] init];
    self.emptyStateLabel.textColor = [UIColor secondaryLabelColor];
    self.emptyStateLabel.textAlignment = NSTextAlignmentCenter;
    self.emptyStateLabel.hidden = YES;
    self.emptyStateLabel.translatesAutoresizingMaskIntoConstraints = NO;

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tableView registerClass:[TrackTableViewCell class] forCellReuseIdentifier:kCellReuseId];

    [self.view addSubview:self.searchField];
    [self.view addSubview:self.searchButton];
    [self.view addSubview:self.emptyStateLabel];
    [self.view addSubview:self.tableView];

    UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [self.searchField.topAnchor constraintEqualToAnchor:safeArea.topAnchor constant:16],
        [self.searchField.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],

        [self.searchButton.centerYAnchor constraintEqualToAnchor:self.searchField.centerYAnchor],
        [self.searchButton.leadingAnchor constraintEqualToAnchor:self.searchField.trailingAnchor constant:8],
        [self.searchButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16],

        [self.emptyStateLabel.topAnchor constraintEqualToAnchor:self.searchField.bottomAnchor constant:32],
        [self.emptyStateLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [self.emptyStateLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16],

        [self.tableView.topAnchor constraintEqualToAnchor:self.searchField.bottomAnchor constant:8],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self onSearchTapped];
    return YES;
}

- (void)onSearchTapped {
    NSString *term = [self.searchField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (term.length == 0) {
        return;
    }
    [self.searchField resignFirstResponder];
    self.emptyStateLabel.hidden = YES;

    NSURLComponents *components = [NSURLComponents componentsWithString:kSearchURLString];
    components.queryItems = @[
        [NSURLQueryItem queryItemWithName:@"term" value:term],
        [NSURLQueryItem queryItemWithName:@"media" value:@"music"],
        [NSURLQueryItem queryItemWithName:@"limit" value:@"25"],
    ];

    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:components.URL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSArray<ItunesTrack *> *tracks = nil;
        if (data && !error) {
            tracks = [weakSelf parseTracksFromData:data];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            if (!tracks) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                                 message:NSLocalizedString(@"music_search_error", nil)
                                                                          preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [strongSelf presentViewController:alert animated:YES completion:nil];
                return;
            }
            strongSelf.tracks = tracks;
            [strongSelf.tableView reloadData];
            strongSelf.emptyStateLabel.text = NSLocalizedString(@"music_no_results", nil);
            strongSelf.emptyStateLabel.hidden = tracks.count > 0;
        });
    }];
    [task resume];
}

- (nullable NSArray<ItunesTrack *> *)parseTracksFromData:(NSData *)data {
    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error || ![json isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSArray *results = json[@"results"];
    if (![results isKindOfClass:[NSArray class]]) {
        return nil;
    }
    NSMutableArray<ItunesTrack *> *tracks = [NSMutableArray array];
    for (NSDictionary *item in results) {
        ItunesTrack *track = [[ItunesTrack alloc] init];
        track.trackName = item[@"trackName"] ?: @"";
        track.artistName = item[@"artistName"] ?: @"";
        track.artworkUrl = item[@"artworkUrl60"] ?: @"";
        [tracks addObject:track];
    }
    return tracks;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tracks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TrackTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseId forIndexPath:indexPath];
    [cell configureWithTrack:self.tracks[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

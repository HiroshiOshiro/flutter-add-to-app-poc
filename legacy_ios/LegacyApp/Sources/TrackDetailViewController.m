#import "TrackDetailViewController.h"
#import "ArtworkLoader.h"
#import "FavoritesStore.h"

@interface TrackDetailViewController ()

@property (nonatomic, strong) ItunesTrack *track;
@property (nonatomic, strong) UIButton *favoriteButton;

@end

@implementation TrackDetailViewController

- (instancetype)initWithTrack:(ItunesTrack *)track {
    self = [super init];
    if (self) {
        _track = track;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"detail_title", nil);
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    UIImageView *artworkView = [[UIImageView alloc] init];
    artworkView.contentMode = UIViewContentModeScaleAspectFill;
    artworkView.clipsToBounds = YES;
    artworkView.layer.cornerRadius = 8;
    artworkView.translatesAutoresizingMaskIntoConstraints = NO;
    [ArtworkLoader loadURLString:self.track.artworkUrlLarge intoImageView:artworkView];

    UILabel *trackNameLabel = [[UILabel alloc] init];
    trackNameLabel.text = self.track.trackName;
    trackNameLabel.font = [UIFont boldSystemFontOfSize:22];
    trackNameLabel.textAlignment = NSTextAlignmentCenter;
    trackNameLabel.translatesAutoresizingMaskIntoConstraints = NO;

    UILabel *artistNameLabel = [[UILabel alloc] init];
    artistNameLabel.text = self.track.artistName;
    artistNameLabel.font = [UIFont systemFontOfSize:16];
    artistNameLabel.textColor = [UIColor secondaryLabelColor];
    artistNameLabel.textAlignment = NSTextAlignmentCenter;
    artistNameLabel.translatesAutoresizingMaskIntoConstraints = NO;

    self.favoriteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.favoriteButton addTarget:self action:@selector(onFavoriteTapped) forControlEvents:UIControlEventTouchUpInside];
    self.favoriteButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self updateFavoriteButton];

    UIStackView *infoStack = [[UIStackView alloc] initWithArrangedSubviews:@[
        [self row:NSLocalizedString(@"label_album", nil) value:self.track.collectionName],
        [self row:NSLocalizedString(@"label_genre", nil) value:self.track.primaryGenreName],
    ]];
    infoStack.axis = UILayoutConstraintAxisVertical;
    infoStack.spacing = 16;
    infoStack.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:artworkView];
    [self.view addSubview:trackNameLabel];
    [self.view addSubview:artistNameLabel];
    [self.view addSubview:self.favoriteButton];
    [self.view addSubview:infoStack];

    UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [artworkView.topAnchor constraintEqualToAnchor:safeArea.topAnchor constant:24],
        [artworkView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [artworkView.widthAnchor constraintEqualToConstant:200],
        [artworkView.heightAnchor constraintEqualToConstant:200],

        [trackNameLabel.topAnchor constraintEqualToAnchor:artworkView.bottomAnchor constant:24],
        [trackNameLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:24],
        [trackNameLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-24],

        [artistNameLabel.topAnchor constraintEqualToAnchor:trackNameLabel.bottomAnchor constant:4],
        [artistNameLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:24],
        [artistNameLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-24],

        [self.favoriteButton.topAnchor constraintEqualToAnchor:artistNameLabel.bottomAnchor constant:24],
        [self.favoriteButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],

        [infoStack.topAnchor constraintEqualToAnchor:self.favoriteButton.bottomAnchor constant:32],
        [infoStack.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:24],
        [infoStack.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-24],
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

- (void)updateFavoriteButton {
    BOOL isFavorite = [FavoritesStore isFavorite:self.track.trackId];
    [self.favoriteButton setTitle:NSLocalizedString(isFavorite ? @"action_remove_favorite" : @"action_add_favorite", nil)
                          forState:UIControlStateNormal];
}

- (void)onFavoriteTapped {
    BOOL newState = ![FavoritesStore isFavorite:self.track.trackId];
    [FavoritesStore setFavorite:newState forTrackId:self.track.trackId];
    [self updateFavoriteButton];
}

@end

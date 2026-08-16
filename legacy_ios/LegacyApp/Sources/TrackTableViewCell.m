#import "TrackTableViewCell.h"
#import "ArtworkLoader.h"
#import "FavoritesStore.h"

@interface TrackTableViewCell ()

@property (nonatomic, strong) UIImageView *artworkView;
@property (nonatomic, strong) UILabel *trackNameLabel;
@property (nonatomic, strong) UILabel *artistNameLabel;
@property (nonatomic, strong) UIButton *favoriteButton;
@property (nonatomic, assign) NSInteger trackId;

@end

@implementation TrackTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _artworkView = [[UIImageView alloc] init];
        _artworkView.contentMode = UIViewContentModeScaleAspectFill;
        _artworkView.clipsToBounds = YES;
        _artworkView.layer.cornerRadius = 6;
        _artworkView.translatesAutoresizingMaskIntoConstraints = NO;

        _trackNameLabel = [[UILabel alloc] init];
        _trackNameLabel.font = [UIFont boldSystemFontOfSize:16];
        _trackNameLabel.translatesAutoresizingMaskIntoConstraints = NO;

        _artistNameLabel = [[UILabel alloc] init];
        _artistNameLabel.font = [UIFont systemFontOfSize:14];
        _artistNameLabel.textColor = [UIColor secondaryLabelColor];
        _artistNameLabel.translatesAutoresizingMaskIntoConstraints = NO;

        _favoriteButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_favoriteButton addTarget:self action:@selector(onFavoriteTapped) forControlEvents:UIControlEventTouchUpInside];
        _favoriteButton.translatesAutoresizingMaskIntoConstraints = NO;

        [self.contentView addSubview:_artworkView];
        [self.contentView addSubview:_trackNameLabel];
        [self.contentView addSubview:_artistNameLabel];
        [self.contentView addSubview:_favoriteButton];

        [NSLayoutConstraint activateConstraints:@[
            [_artworkView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
            [_artworkView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:8],
            [_artworkView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-8],
            [_artworkView.widthAnchor constraintEqualToConstant:56],
            [_artworkView.heightAnchor constraintEqualToConstant:56],

            [_favoriteButton.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
            [_favoriteButton.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
            [_favoriteButton.widthAnchor constraintEqualToConstant:32],
            [_favoriteButton.heightAnchor constraintEqualToConstant:32],

            [_trackNameLabel.leadingAnchor constraintEqualToAnchor:_artworkView.trailingAnchor constant:12],
            [_trackNameLabel.trailingAnchor constraintEqualToAnchor:_favoriteButton.leadingAnchor constant:-8],
            [_trackNameLabel.topAnchor constraintEqualToAnchor:_artworkView.topAnchor],

            [_artistNameLabel.leadingAnchor constraintEqualToAnchor:_artworkView.trailingAnchor constant:12],
            [_artistNameLabel.trailingAnchor constraintEqualToAnchor:_favoriteButton.leadingAnchor constant:-8],
            [_artistNameLabel.topAnchor constraintEqualToAnchor:_trackNameLabel.bottomAnchor constant:4],
        ]];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.artworkView.image = nil;
    self.onFavoriteToggled = nil;
}

- (void)configureWithTrack:(ItunesTrack *)track {
    self.trackId = track.trackId;
    self.trackNameLabel.text = track.trackName;
    self.artistNameLabel.text = track.artistName;
    [self updateFavoriteIcon];
    [ArtworkLoader loadURLString:track.artworkUrl intoImageView:self.artworkView];
}

- (void)updateFavoriteIcon {
    BOOL isFavorite = [FavoritesStore isFavorite:self.trackId];
    NSString *symbolName = isFavorite ? @"star.fill" : @"star";
    [self.favoriteButton setImage:[UIImage systemImageNamed:symbolName] forState:UIControlStateNormal];
    self.favoriteButton.tintColor = isFavorite ? [UIColor systemYellowColor] : [UIColor systemGrayColor];
}

- (void)onFavoriteTapped {
    BOOL newState = ![FavoritesStore isFavorite:self.trackId];
    [FavoritesStore setFavorite:newState forTrackId:self.trackId];
    [self updateFavoriteIcon];
    if (self.onFavoriteToggled) {
        self.onFavoriteToggled();
    }
}

@end

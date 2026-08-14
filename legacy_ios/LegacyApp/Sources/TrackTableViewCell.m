#import "TrackTableViewCell.h"

@interface TrackTableViewCell ()

@property (nonatomic, strong) UIImageView *artworkView;
@property (nonatomic, strong) UILabel *trackNameLabel;
@property (nonatomic, strong) UILabel *artistNameLabel;
@property (nonatomic, copy) NSString *currentArtworkUrl;

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

        [self.contentView addSubview:_artworkView];
        [self.contentView addSubview:_trackNameLabel];
        [self.contentView addSubview:_artistNameLabel];

        [NSLayoutConstraint activateConstraints:@[
            [_artworkView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
            [_artworkView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:8],
            [_artworkView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-8],
            [_artworkView.widthAnchor constraintEqualToConstant:56],
            [_artworkView.heightAnchor constraintEqualToConstant:56],

            [_trackNameLabel.leadingAnchor constraintEqualToAnchor:_artworkView.trailingAnchor constant:12],
            [_trackNameLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
            [_trackNameLabel.topAnchor constraintEqualToAnchor:_artworkView.topAnchor],

            [_artistNameLabel.leadingAnchor constraintEqualToAnchor:_artworkView.trailingAnchor constant:12],
            [_artistNameLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
            [_artistNameLabel.topAnchor constraintEqualToAnchor:_trackNameLabel.bottomAnchor constant:4],
        ]];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.artworkView.image = nil;
    self.currentArtworkUrl = nil;
}

- (void)configureWithTrack:(ItunesTrack *)track {
    self.trackNameLabel.text = track.trackName;
    self.artistNameLabel.text = track.artistName;
    self.currentArtworkUrl = track.artworkUrl;

    if (track.artworkUrl.length == 0) {
        return;
    }

    NSString *targetUrl = track.artworkUrl;
    NSURL *url = [NSURL URLWithString:targetUrl];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!data || error) {
            return;
        }
        UIImage *image = [UIImage imageWithData:data];
        if (!image) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.currentArtworkUrl isEqualToString:targetUrl]) {
                self.artworkView.image = image;
            }
        });
    }];
    [task resume];
}

@end

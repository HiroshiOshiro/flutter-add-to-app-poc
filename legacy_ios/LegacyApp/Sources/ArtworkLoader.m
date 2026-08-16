#import "ArtworkLoader.h"
#import <objc/runtime.h>

static const void *kCurrentURLKey = &kCurrentURLKey;

@implementation ArtworkLoader

+ (NSCache<NSString *, UIImage *> *)cache {
    static NSCache<NSString *, UIImage *> *cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[NSCache alloc] init];
    });
    return cache;
}

+ (void)loadURLString:(NSString *)urlString intoImageView:(UIImageView *)imageView {
    imageView.image = nil;
    if (urlString.length == 0) {
        return;
    }

    UIImage *cached = [[self cache] objectForKey:urlString];
    if (cached) {
        imageView.image = cached;
        return;
    }

    objc_setAssociatedObject(imageView, kCurrentURLKey, urlString, OBJC_ASSOCIATION_COPY_NONATOMIC);

    NSURL *url = [NSURL URLWithString:urlString];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!data || error) {
            return;
        }
        UIImage *image = [UIImage imageWithData:data];
        if (!image) {
            return;
        }
        [[self cache] setObject:image forKey:urlString];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *currentURL = objc_getAssociatedObject(imageView, kCurrentURLKey);
            if ([currentURL isEqualToString:urlString]) {
                imageView.image = image;
            }
        });
    }];
    [task resume];
}

@end

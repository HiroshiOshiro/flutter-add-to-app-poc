#import "SceneDelegate.h"
#import "InputViewController.h"

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    self.window = [[UIWindow alloc] initWithWindowScene:windowScene];

    InputViewController *inputVC = [[InputViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:inputVC];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
}

@end

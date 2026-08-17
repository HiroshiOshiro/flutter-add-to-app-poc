#import "SceneDelegate.h"
#import "InputViewController.h"
#import "LegacyApp-Swift.h"

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    self.window = [[UIWindow alloc] initWithWindowScene:windowScene];

    InputViewController *inputVC = [[InputViewController alloc] init];
    UINavigationController *memoNav = [[UINavigationController alloc] initWithRootViewController:inputVC];

    MusicFlutterViewController *musicVC = [[MusicFlutterViewController alloc] init];
    musicVC.navigationItem.title = NSLocalizedString(@"tab_music", nil);
    UINavigationController *musicNav = [[UINavigationController alloc] initWithRootViewController:musicVC];

    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[memoNav, musicNav];

    memoNav.tabBarItem.title = NSLocalizedString(@"tab_memo", nil);
    memoNav.tabBarItem.image = [UIImage systemImageNamed:@"pencil"];
    musicNav.tabBarItem.title = NSLocalizedString(@"tab_music", nil);
    musicNav.tabBarItem.image = [UIImage systemImageNamed:@"music.note"];

    self.window.rootViewController = tabBarController;
    [self.window makeKeyAndVisible];
}

@end

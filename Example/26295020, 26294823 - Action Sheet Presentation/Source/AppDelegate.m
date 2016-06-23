#import "AppDelegate.h"
#import "TextViewController.h"
#import "WebViewController.h"
#import "NewerWebViewController.h"
#import "Workaround.h"
#import "PSTModernizer.h"

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //PSPDFInstallWorkaroundForSheetPresentation();

    [PSTModernizer installModernizer];

    self.window = [[UIWindow alloc] init];

    UIViewController *firstTextViewController = [[TextViewController alloc] init];
    firstTextViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Present Second" style:UIBarButtonItemStylePlain target:self action:@selector(presentSecondTextView:)];
    firstTextViewController.title = @"UITextView";
    firstTextViewController.navigationItem.title = @"First";

    UIViewController *firstWebViewController = [[WebViewController alloc] init];
    firstWebViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Present Second" style:UIBarButtonItemStylePlain target:self action:@selector(presentSecondWebView:)];
    firstWebViewController.title = @"UIWebView";
    firstWebViewController.navigationItem.title = @"First";

    UIViewController *firstNewerWebViewController = [[NewerWebViewController alloc] init];
    firstNewerWebViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Present Second" style:UIBarButtonItemStylePlain target:self action:@selector(presentSecondNewerWebView:)];
    firstNewerWebViewController.title = @"WKWebView";
    firstNewerWebViewController.navigationItem.title = @"First";

    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[
                                         [[UINavigationController alloc] initWithRootViewController:firstTextViewController],
                                         [[UINavigationController alloc] initWithRootViewController:firstWebViewController],
                                         [[UINavigationController alloc] initWithRootViewController:firstNewerWebViewController],
                                         ];

    self.window.rootViewController = tabBarController;
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)presentSecondTextView:(id)sender {
    [self presentSecondViewControllerOfClass:[TextViewController class]];
}

- (void)presentSecondWebView:(id)sender {
    [self presentSecondViewControllerOfClass:[WebViewController class]];
}

- (void)presentSecondNewerWebView:(id)sender {
    [self presentSecondViewControllerOfClass:[NewerWebViewController class]];
}

- (void)presentSecondViewControllerOfClass:(Class)klass {
    UIViewController *secondViewController = [[klass alloc] init];
    secondViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss:)];
    secondViewController.title = @"Second";

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:secondViewController];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.window.rootViewController presentViewController:navigationController animated:YES completion:nil];
}

- (void)dismiss:(id)sender {
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

@end

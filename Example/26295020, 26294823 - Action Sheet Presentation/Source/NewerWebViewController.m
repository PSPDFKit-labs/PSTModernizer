#import "NewerWebViewController.h"
@import WebKit;

@implementation NewerWebViewController

- (void)loadView {
    WKWebView *textView = [[WKWebView alloc] init];
    [textView loadHTMLString:@"<p>This is a WKWebView with an HTML link: <a href=\"https://pspdfkit.com\">PSPDFKit website</a></p>" baseURL:nil];

    self.view = textView;
}

@end

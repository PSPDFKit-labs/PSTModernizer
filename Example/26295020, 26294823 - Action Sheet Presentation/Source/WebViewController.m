#import "WebViewController.h"

@implementation WebViewController

- (void)loadView {
    UIWebView *textView = [[UIWebView alloc] init];
    textView.dataDetectorTypes = UIDataDetectorTypeAll;
    [textView loadHTMLString:@"<p>This is a UIWebView with a phone number: 01234 567890 and a detected web link: https://pspdfkit.com/ and an HTML link: <a href=\"https://pspdfkit.com\">PSPDFKit website</a> and a time: 15:40 tomorrow and an address: 1 Infinite Loop Cupertino CA 95014 United States</p>" baseURL:nil];

    self.view = textView;
}

@end

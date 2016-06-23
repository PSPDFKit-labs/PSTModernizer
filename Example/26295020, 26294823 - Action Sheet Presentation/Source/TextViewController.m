#import "TextViewController.h"

@implementation TextViewController

- (void)loadView {
    UITextView *textView = [[UITextView alloc] init];
    textView.dataDetectorTypes = UIDataDetectorTypeAll;
    textView.editable = NO;
    textView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    textView.text = @"This is a UITextView with a phone number: 01234 567890 and web link: https://pspdfkit.com/ and a time: 15:40 tomorrow and an address:\n\n1 Infinite Loop\nCupertino CA 95014\nUnited States";

    self.view = textView;
}

@end

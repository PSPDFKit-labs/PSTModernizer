# PSTModernizer

PSTModernizer carefully applies patches to UIKit and related Apple frameworks to fix known radars with the least impact.
The current set of patches just applies to iOS 9 and nothing is executed on iOS 10, as the bugs have been fixed there.

This project later on might also patch-add a few essential missing elements in iOS 10 if there's need - currently the focus is just to fix various bugs.

## Installation

Simply copy `PSTModernizer.h/mm` into your project, then call `[PSTModernizer installModernizer];` somewhere early, ideally in your app delegate.

Currently covers following radars (all of them have been fixed in iOS 10)

* [26954460 - UIImage creation has a race conditon on background threads.](https://openradar.appspot.com/26954460)<br>
  The radar is actually for fixing the documentation, [the original issue is explained here.](https://pspdfkit.com/blog/2016/investigating-thread-saftey-of-UIImage/)
* [26295020 - Action sheets presented for links/numbers don’t work in presented view controllers](https://openradar.appspot.com/26295020)

You can simply delete the workarounds that do not affect you - every workaround is self-contained and can be individually removed.

## FAQ

Q: *Why?*<br>
A: Because we need to support older UIKit versions. [At PSPDFKit we support n-1](https://pspdfkit.com/guides/ios/current/announcements/version-support/), so we're just about to drop iOS 8 and will likely use something like this for our next major release. This project should make it easier to patch up the system so you need to write less ugly code.

Q: *Isn't that partly using private API?*<br>
A: Partly. The goal is to write workarounds using just public API, but it's not always possible or would lead to much more scary code. If we revert to private API, we use it for good, not evil. You decide. Since we restrict API usage to versions that have been already released and don't apply it to unknown versions, the risk is minimal. If you do find a way to patch things without private API that are similary effective and not 10x the code, please submit a pull request. We also only use it to work around bugs, not for accessing new features. Of course I can't make any guarantees if Apple accepts this on app review. (but so far we have not gotten a report that blocks this, and worst case you disable the parts that are private and just have a slightly more broken app.) 

## License

The MIT License (MIT)

Copyright (c) 2016 Peter Steinberger, PSPDFKit GmbH.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

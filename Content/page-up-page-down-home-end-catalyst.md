title: Page Up, Page Down, Home and End in Catalyst apps
description: Apple didn’t add support for scrolling with Page Up and Page Down in UIKit: They added this in WebKit/Safari.
micro: I know a bit about the [Home and End keys in Catalyst apps so I wrote a response](). Summary: UIKit doesn’t do this; use KeyboardKit. 👍
date: 2019-12-20T11:06:33+0000
tweet: 1207980601770496000
%%%

I’ve done some investigation on this topic so I thought I would share these details about the Page Up, Page Down, Home and End keys in iOS and Mac Catalyst apps.

[John Gruber, Daring Fireball](https://daringfireball.net/2019/12/catalyst_two_months_in):

> But try moving these apps to the Mac and the nonstandard UIs stick out like a sore thumb, and whatever work the Catalyst frameworks do to support Mac conventions automatically doesn’t kick in if the apps aren’t even using the standard UIKit controls to start with. E.g. scrolling a view with Page Up, Page Down, Home, and End. An iOS app using standard UIKit controls for scrollable views should, in theory, pick up support for those keys automatically.

I wish this was the case, but unfortunately it is not. The standard UIKit scrolling class, `UIScrollView`, does not provide any keyboard-driven scrolling functionality. Let’s dive into this footnote from John:

> On iOS, it seems only Fn↑ = Page Up and Fn↓ = Page Down are standard in UIKit — the Fn←/Fn→ shortcuts for Home/End seem to be supported nowhere. But even some of Apple’s own iPad apps — like Mail and Notes to name two — don’t support Fn↑ / Fn↓ either.

There are three levels to this.

1. There’s what `UIScrollView` provides out of the box for keyboard-driven scrolling, which is nothing.
2. Then what’s possible with public, documented APIs. Also nothing.
3. Then finally what can be done using a grey area of undocumented APIs.

What’s going on here is that Apple did not add support for Page Up and Page Down in UIKit: They added this in WebKit/Safari. Fortunately [WebKit is open source so we can see how they did it](https://opensource.apple.com/source/WebKit2/WebKit2-7601.1.46.9/UIProcess/ios/WKContentViewInteraction.mm.auto.html). Developers need to use the undocumented input strings `UIKeyInputPageUp` and `UIKeyInputPageDown` and write their own code to scroll up or down by the correct amount in response to those input events. While WebKit doesn’t support Home and End it’s possible to do some guessing: The strings `UIKeyInputHome` and `UIKeyInputEnd` do in fact work.

**Update, March 2020:** These input strings are now publicly available and documented with Xcode 11.4.

[My open source KeyboardKit project](https://github.com/douglashill/KeyboardKit) aims to fill this gap in functionality from UIKit. It implements correct behaviour for scrolling with arrow keys, option + arrow keys, command + arrow keys, space bar, Page Up, Page Down, Home and End. There’s a whole lot more in there, such as selecting items in lists using the up and down arrows, changing tabs, and triggering toolbar buttons.

Developers, don’t let your iOS or Mac Catalyst app be caught not supporting Home and End. Use [KeyboardKit](https://github.com/douglashill/KeyboardKit) to add this to your app with minimal effort.

date: 2024-07-16T16:45:29+02:00
%%%

There’s [an issue where Xcode 15.4 fails to build Mac Catalyst apps with certain package dependencies](https://forums.developer.apple.com/forums/thread/751573) with:

> clang:1:1 invalid version number in '-target x86_64-apple-ios10.15-macabi'

Or:

> clang:1:1: invalid version number in '-target arm64-apple-ios10.15-macabi'

Workaround: use Xcode 15.3.

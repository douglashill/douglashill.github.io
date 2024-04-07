date: 2023-08-24T14:57:42+0000
%%%

Since Apple [removed the device support files that everyone used](https://developer.apple.com/forums/thread/730947), did anyone find a way run an app linked with the iOS 16 SDK on an iOS 17 device? (Other than TestFlight, which is a very slow iteration loop.)

**Edit:** Using `defaults write com.apple.dt.Xcode DVTEnableCoreDevice enabled` as suggeted further down that thread worked for me. Presumably there’s a reason this isn’t enabled by default though.

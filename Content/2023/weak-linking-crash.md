title: Weak linking crash
micro: Imagine if you were having a quiet Friday at work just before Christmas… and then at 6pm you discover the live version of [your app](https://apps.apple.com/app/id1120099014) is crashing at launch on older iOS versions.
date: 2023-12-22
time: 22:17:00+00:00
%%%

Imagine if you were having a quiet Friday afternoon at work just before Christmas with nobody else in the team around… and then at 6pm you discover the live version of [your app](https://apps.apple.com/app/id1120099014) is crashing at launch on older iOS versions.

I knew this was a dynamic linking failing, but not what symbol was causing trouble. The crash only happened in real release builds (not even release builds run from Xcode).

I’m very lucky to use a 1st generation iPhone SE, which can’t run anything later than iOS 15. Having a device on an older OS version was essential for confirming the issue and fix. Without this, I’d probably still be combing through two weeks of diff in our monorepo trying to work out what might be causing the `dyld` failure.

From looking at recent logs on my iPhone, I saw the problem was [`NSURLVolumeTypeNameKey`](https://developer.apple.com/documentation/foundation/urlresourcekey/4142675-volumetypenamekey), which was introduced in iOS 16.4. We added this recently to move away from an older file system API that’s now a [required reason API](https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api). This API was correctly used within runtime availability checks. (The crash happened at launch, not when this code was running.)

For now, the workaround is to use the string value of this constant, `"NSURLVolumeTypeNameKey"`, instead. Why weak linking isn’t working is a mystery to resolve in the new year.

Fortunately app review were stars and approved the app in just under an hour. (Although that’s still more than zero time, and the Mac app is still in review over two hours later.) There’s a fixed version of [PDF Viewer for iOS](https://apps.apple.com/app/id1120099014) out now.

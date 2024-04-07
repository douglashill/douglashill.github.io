date: 2023-10-13T09:52:24+0000
%%%

Compiling an existing iOS codebase for visionOS breaks the [deprecation cycle](https://pspdfkit.com/blog/2021/what-is-a-deprecated-api-on-ios/). You end up with deprecation warnings you can’t silence that aren’t actually a problem. We ought to be able to set our visionOS deployment target to -1.0 (two versions back) to match our iOS deployment target of 15.0.

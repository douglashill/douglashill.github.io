title: Nutrient iOS SDK 14.2
micro: We recently released Nutrient iOS SDK 14.2. This was an ambitious release for our three-person iOS team, and it was exciting seeing this all come together! [Here are a few interesting details from the technical side]().
date: 2024-12-02T18:29:58Z
%%%

We recently released [Nutrient iOS SDK 14.2](https://www.nutrient.io/changelog/ios/#14.2.0). This was an ambitious release for our three-person iOS team, and it was exciting seeing this all come together! Here are a few interesting details from the technical side.

## A new name for a longstanding product

[Nutrient iOS SDK](https://www.nutrient.io/sdk/ios) is the [new name](https://www.nutrient.io/blog/product-rebrand-pspdfkit-evolution-nutrient-engineering-perspective/) for PSPDFKit for iOS, our SDK for viewing and editing PDF documents. The 14 in the [version number](https://www.nutrient.io/guides/ios/best-practices/version-numbering/) reflects the [14-year history](https://www.nutrient.io/changelog/ios/#1.0) of our product.

In 14.2, we started the rename from PSPDFKit to Nutrient. Nothing changed on the technical front; we just switched to the new name in documentation. We want to make this a smooth transition.

## System text selection with `UITextInteraction`

[Peter](https://github.com/steipete) originally added text selection in [PSPDFKit 2](https://www.nutrient.io/changelog/ios/#2.0.0) back in September 2012. Seven years later, the iOS 13 SDK added [`UITextInteraction`](https://developer.apple.com/documentation/uikit/uitextinteraction) for native text selection and editing behaviours, while using your own rendering.

Our fully-custom text selection implementation improved over the years and was a very good replica of the system UI, but it required effort to maintain — especially now we support iOS, macOS and visionOS. [`UITextInteraction`](https://developer.apple.com/documentation/uikit/uitextinteraction) was clearly the way forward. In version 14.2, we’ve made the switch, completly overhauling our implementation of text selection in PDFs.

This read-only implementation is our second time using [`UITextInteraction`](https://developer.apple.com/documentation/uikit/uitextinteraction): We already use it for editable text in our [Content Editor](https://www.nutrient.io/guides/ios/editor/edit-text/). Read more in Stefan’s earlier post: [Adopting `UITextInteraction`](https://www.nutrient.io/blog/adopting-uitextinteraction/).

The huge benefit of system text selection is that it provides many built-in menu items:

- We now have Look Up instead of relying on the ancient [`UIReferenceLibraryViewController`](https://developer.apple.com/documentation/uikit/uireferencelibraryviewcontroller).
- Translate and Writing Tools (for summarisation) are also there.
- We no longer need our own [`AVSpeechSynthesizer`](https://developer.apple.com/documentation/avfaudio/avspeechsynthesizer)-based implementation of text-to-speech because this is provided by system text selection.

I hope we can share more about what we learned as we’re now experts with this advanced API!

## Big cleanup

For the last couple of years, we’ve supported two separate APIs for customising menus shown in our UI, with two separate implementations:

- The older way used [`UIMenuController`](https://developer.apple.com/documentation/uikit/uimenucontroller) and [`UIMenuItem`](https://developer.apple.com/documentation/uikit/uimenuitem), which Apple has deprecated.
- The newer way uses [`UIEditMenuInteraction`](https://developer.apple.com/documentation/uikit/uieditmenuinteraction) and [`UIMenuElement`](https://developer.apple.com/documentation/uikit/uimenuelement), which were introduced in iOS 16.

Our new release drops support for iOS 15, so we were able to remove our old menu customisation APIs. [Adrian](https://github.com/akashivskyy/) had set this up with clear separation, making this an easy clean up. It was so satisfying to say goodbye to thousands of lines of code! 👋

There are more details for customers in our [migration guide](https://www.nutrient.io/guides/ios/migration-guides/14-2-migration-guide/).

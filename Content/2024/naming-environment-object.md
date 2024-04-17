title: Naming the environment object for PSPDFKit’s toolbar buttons
description: We’re trying a new API to customise PSPDFKit toolbar buttons using SwiftUI’s standard `.toolbar` modifier. This needs an `@EnvironmentObject` so we can sync state, but we’re unsure how to name this API. So far using the magic word ‘context’.
date: 2024-04-17T09:37:30+01:00
%%%

We’re trying a new API to customise [PSPDFKit](https://pspdfkit.com/pdf-sdk/ios/) toolbar buttons using SwiftUI’s standard `.toolbar` modifier.

We need to internally sync state between our main `PDFView` (document content view) and standard buttons we provide (normally placed in a navigation bar). This is both for the buttons’ actions and state like if the buttons are enabled. Providing a modifier that internally uses an `@EnvironmentObject` works well, but we’re not sure what the best name is. Our proof-of-concept is using the all programmers’s favourite word ‘context’.

Usage is like this:

```
PDFView(document: document)
    .toolbar {
        AnnotationButton()
        ThumbnailButton()
    }
    .pdfContext(PDFContext()) // What to call this?
```

There is a similar concept in MapKit, which has a `mapScope(_:)`, although it requires a bit more typing to use. Apple has [this example showing `MapCompass` being detached from its `Map`](https://developer.apple.com/documentation/mapkit/mapcompass):

```
struct CompassButtonTestView: View {
    @Namespace var mapScope
    var body: some View {
    VStack {
            Map(scope: mapScope)
            MapCompass(scope: mapScope)
        }
        .mapScope(mapScope)
    }
}
```

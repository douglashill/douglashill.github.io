title: PencilKit
description: Talk at SwiftLeeds 2025.
%%%

Talk at SwiftLeeds 2025.

Slides to follow.

## References

- [Nutrient iOS SDK](https://www.nutrient.io/sdk/ios/)
- [NSLondon](https://nslondon.com/)
- [PencilKit documentation](https://developer.apple.com/documentation/pencilkit):
    - [`PKCanvasView`](https://developer.apple.com/documentation/pencilkit/pkcanvasview)
    - [`PKDrawing`](https://developer.apple.com/documentation/pencilkit/pkdrawing-swift.struct)
    - [`PKToolPicker`](https://developer.apple.com/documentation/pencilkit/pktoolpicker)
- [Using `PKToolPicker` with a custom drawing engine (Nutrient sample code)](https://github.com/PSPDFKit/pspdfkit-ios-catalog/blob/master/Catalog/Examples/BarButtons/PencilKitToolPickerExample.swift)

## Relevant WWDC sessions

- [Introducing PencilKit (2019)](https://developer.apple.com/videos/play/wwdc2019/221)
- [What's new in PencilKit (2020)](https://developer.apple.com/videos/play/wwdc2020/10107)
- [Inspect, modify, and construct PencilKit drawings (2020)](https://developer.apple.com/videos/play/wwdc2020/10148)
- [Squeeze the most out of Apple Pencil (2024)](https://developer.apple.com/videos/play/wwdc2024/10214)

## Code

Basic use of `PKCanvasView`:

```
import PlaygroundSupport
import PencilKit

let canvasView = PKCanvasView()
canvasView.tool = PKInkingTool(.crayon, color: .purple, width: 10)

PlaygroundPage.current.liveView = canvasView
```

Programmatically modifying a drawing to make all stokes red (mentioned, but not shown in talk):

```
canvasView.drawing.strokes = canvasView.drawing.strokes.map {
    var stroke = $0
    stroke.ink.color = .red
    return stroke
}
```

Using `PKToolPicker` with `PKCanvasView`:

```
import PlaygroundSupport
import PencilKit

let canvasView = PKCanvasView()
let toolPicker = PKToolPicker()
toolPicker.setVisible(true, forFirstResponder: canvasView)
toolPicker.addObserver(canvasView)

canvasView.becomeFirstResponder()

PlaygroundPage.current.liveView = canvasView
```

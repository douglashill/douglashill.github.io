title: “Received updates from an unknown hover gesture recognizer”
micro: We’re seeing a UIKit crash introduced in iOS 26.1: `NSInternalInconsistencyException -[UIPencilInteraction _handleHoverGestureRecognizer:]: Received updates from an unknown hover gesture recognizer` (FB21266941) [Full post]()
date: 2025-12-04T10:27:31Z
%%%

We’re seeing a UIKit crash introduced in iOS 26.1:

`Fatal Exception: NSInternalInconsistencyException`

`-[UIPencilInteraction _handleHoverGestureRecognizer:]: Received updates from an unknown hover gesture recognizer: <UIHoverGestureRecognizer: 0x12429d400 (pencilInteraction.hover.0x1105da080); id = 594; state = Cancelled; view = (nil); target= <(action=_handleHoverGestureRecognizer:, target=<UIPencilInteraction 0x1105da080>)>>`

Reported as FB21266941.

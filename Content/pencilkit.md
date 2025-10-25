title: PencilKit
subtitle: From simple drawings to custom creative tools
description: Talk at SwiftLeeds 2025.
%%%

Talk at SwiftLeeds 2025.

- [Slides](https://files.douglashill.co/pencilkit-swiftleeds-2025.pdf)

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

<pre><code class="hljs"><span class="hljs-keyword">import</span> PlaygroundSupport
<span class="hljs-keyword">import</span> PencilKit

<span class="hljs-keyword">let</span> canvasView =<span class="hljs-attribute"> PKCanvasView</span>()
canvasView.<span class="hljs-attribute">tool</span> =<span class="hljs-attribute"> PKInkingTool</span>(.<span class="hljs-attribute">crayon</span>, color: .<span class="hljs-literal">purple</span>, width: <span class="hljs-number">10</span>)

<span class="hljs-type">PlaygroundPage</span>.<span class="hljs-attribute">current</span>.<span class="hljs-attribute">liveView</span> = canvasView</code></pre>

Programmatically modifying a drawing to make all stokes red (mentioned, but not shown in talk):

<pre><code class="hljs">canvasView.<span class="hljs-attribute">drawing</span>.<span class="hljs-attribute">strokes</span> = canvasView.<span class="hljs-attribute">drawing</span>.<span class="hljs-attribute">strokes</span>.<span class="hljs-attribute">map</span> {
    <span class="hljs-keyword">var</span> stroke = $<span class="hljs-number">0</span>
    stroke.<span class="hljs-attribute">ink</span>.<span class="hljs-attribute">color</span> = .<span class="hljs-literal">red</span>
    <span class="hljs-keyword">return</span> stroke
}</code></pre>

Using `PKToolPicker` with `PKCanvasView`:

<pre><code class="hljs"><span class="hljs-keyword">import</span> PlaygroundSupport
<span class="hljs-keyword">import</span> PencilKit

<span class="hljs-keyword">let</span> canvasView =<span class="hljs-attribute"> PKCanvasView</span>()
<span class="hljs-keyword">let</span> toolPicker =<span class="hljs-attribute"> PKToolPicker</span>()
toolPicker.<span class="hljs-attribute">setVisible</span>(<span class="hljs-literal">true</span>, forFirstResponder: canvasView)
toolPicker.<span class="hljs-attribute">addObserver</span>(canvasView)

canvasView.<span class="hljs-attribute">becomeFirstResponder</span>()

<span class="hljs-type">PlaygroundPage</span>.<span class="hljs-attribute">current</span>.<span class="hljs-attribute">liveView</span> = canvasView</code></pre>

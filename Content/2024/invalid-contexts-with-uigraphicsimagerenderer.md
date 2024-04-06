title: Invalid contexts with `UIGraphicsImageRenderer`
description: Graphics contexts created by `UIGraphicsImageRenderer` are somehow invalid for reading the width and height.
date: 2024-01-11T16:33:21+0000
%%%

Graphics contexts created by `UIGraphicsImageRenderer` are somehow invalid for reading the width and height. This code:

<pre><code class="hljs"><span class="hljs-keyword">let</span> image =<span class="hljs-attribute"> UIGraphicsImageRenderer</span>(size:<span class="hljs-attribute"> CGSize</span>(width: <span class="hljs-number">100</span>, height: <span class="hljs-number">60</span>)).<span class="hljs-attribute">image</span> { context <span class="hljs-keyword">in</span>
    <span class="hljs-keyword">let</span> width = context.<span class="hljs-attribute">cgContext</span>.<span class="hljs-attribute">width</span>
   <span class="hljs-attribute"> print</span>(<span class="hljs-string">"Width is \(width)."</span>)
    <span class="hljs-keyword">let</span> height = context.<span class="hljs-attribute">cgContext</span>.<span class="hljs-attribute">height</span>
   <span class="hljs-attribute"> print</span>(<span class="hljs-string">"Height is \(height)."</span>)
}</code></pre>

Unexpectedly logs this:

```
CGBitmapContextGetWidth: invalid context 0x600003704600. If you want to see the backtrace, please set CG_CONTEXT_SHOW_BACKTRACE environmental variable.
Width is 0.
CGBitmapContextGetHeight: invalid context 0x600003704600. If you want to see the backtrace, please set CG_CONTEXT_SHOW_BACKTRACE environmental variable.
Height is 0.
```

It works fine with this older API that’s marked `API_TO_BE_DEPRECATED`:

<pre><code class="hljs"><span class="hljs-type">UIGraphicsBeginImageContext</span>(<span class="hljs-type">CGSize</span>(width: <span class="hljs-number">100</span>, height: <span class="hljs-number">60</span>))
<span class="hljs-keyword">let</span> context =<span class="hljs-attribute"> UIGraphicsGetCurrentContext</span>()!
<span class="hljs-keyword">let</span> width = context.<span class="hljs-attribute">width</span><span class="hljs-attribute">
print</span>(<span class="hljs-string">"Width is \(width)."</span>)
<span class="hljs-keyword">let</span> height = context.<span class="hljs-attribute">height</span><span class="hljs-attribute">
print</span>(<span class="hljs-string">"Height is \(height)."</span>)
<span class="hljs-keyword">let</span> image =<span class="hljs-attribute"> UIGraphicsGetImageFromCurrentImageContext</span>()!<span class="hljs-attribute">
UIGraphicsEndImageContext</span>()</code></pre>

Logs the expected output:

```
Width is 100.
Height is 60.
```

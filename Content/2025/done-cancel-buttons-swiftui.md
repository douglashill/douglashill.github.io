title: Done and Cancel buttons in SwiftUI
micro: SwiftUI in iOS 26 adds equivalents of `UIBarButtonItem.SystemItem.done` and `UIBarButtonItem.SystemItem.cancel` to get standard Done and Cancel buttons. [Here’s the code we're using to wrap this new API with fallbacks for older versions.]()
date: 2025-12-12T11:42:57+0000
%%%

SwiftUI in iOS 26 adds equivalents of `UIBarButtonItem.SystemItem.done` and `UIBarButtonItem.SystemItem.cancel` to get standard Done and Cancel buttons. This is important because to match the standard look, these buttons should show as ✔︎ and ✘ icons on iOS 26+, but they should use text labels on older versions or if `UIDesignRequiresCompatibility` is enabled.

Here’s the code we're using to wrap this new [`Button.init(role:action:)`](https://developer.apple.com/documentation/swiftui/button/init(role:action:)) API with fallbacks for older versions:

<pre><code class="hljs"><span class="hljs-comment">/// Standard Done button.</span>
<span class="hljs-comment">/// Wrapper around `Button(role: .confirm) { }`</span>
<span class="hljs-comment">/// with a fallback for older versions.</span>
<span class="hljs-class"><span class="hljs-keyword">struct</span> <span class="hljs-title">ConfirmToolbarButton</span>: <span class="hljs-title">ToolbarContent</span> </span>{
    <span class="hljs-keyword">let</span> action: () -&gt; <span class="hljs-type">Void</span>

    <span class="hljs-keyword">var</span> body: <span class="hljs-keyword">some</span> <span class="hljs-type">ToolbarContent</span> {
       <span class="hljs-attribute"> ToolbarItem</span>(placement: .<span class="hljs-literal">confirmationAction</span>) {
            <span class="hljs-keyword">if</span> #available(iOS <span class="hljs-number">26.0</span>, *) {
               <span class="hljs-attribute"> Button</span>(role: .<span class="hljs-literal">confirm</span>, action: action)
            } <span class="hljs-keyword">else</span> {
               <span class="hljs-attribute"> Button</span>(<span class="hljs-string">"Done"</span>, action: action)
            }
        }
    }
}

<span class="hljs-comment">/// Standard Cancel button.</span>
<span class="hljs-comment">/// Wrapper around `Button(role: .cancel) { }`</span>
<span class="hljs-comment">/// with a fallback for older versions.</span>
<span class="hljs-class"><span class="hljs-keyword">struct</span> <span class="hljs-title">CancelToolbarButton</span>: <span class="hljs-title">ToolbarContent</span> </span>{
    <span class="hljs-keyword">let</span> action: () -&gt; <span class="hljs-type">Void</span>

    <span class="hljs-keyword">var</span> body: <span class="hljs-keyword">some</span> <span class="hljs-type">ToolbarContent</span> {
       <span class="hljs-attribute"> ToolbarItem</span>(placement: .<span class="hljs-literal">cancellationAction</span>) {
            <span class="hljs-keyword">if</span> #available(iOS <span class="hljs-number">26.0</span>, *) {
               <span class="hljs-attribute"> Button</span>(role: .<span class="hljs-literal">cancel</span>, action: action)
            } <span class="hljs-keyword">else</span> {
               <span class="hljs-attribute"> Button</span>(<span class="hljs-string">"Cancel"</span>, action: action)
            }
        }
    }
}
</code></pre>

Usage:

<pre><code class="hljs"><span class="hljs-type">NavigationStack</span> {
    content
        .<span class="hljs-literal">navigationTitle</span>(title)
        .<span class="hljs-literal">toolbar</span> {
            <span class="hljs-type">CancelToolbarButton</span> {
                <span class="hljs-comment">// Handle cancellation</span>
            }
            <span class="hljs-type">ConfirmToolbarButton</span> {
                <span class="hljs-comment">// Handle confirmation</span>
            }
        }
}</code></pre>

If your minimum version is iOS 26 or later, there’s no need to wrap these in `ToolbarItem`. You can use `Button` directly in your toolbar builder because the placement is implied by the role.

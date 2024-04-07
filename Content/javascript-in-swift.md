title: Using JavaScript in a Swift app
description: How I used JavaScriptCore to add a JavaScript dependency to my iOS app to remove tracking parameters from URLs.
date: 2023-01-12T09:20:00+00:00
tweet: 1613467058146103296
%%%

If you’re writing an iOS app using Swift and trying to solve a problem you’re sure has been solved before, you may look for existing code that solves that problem. It’s likely you’ll first think of looking for open source code written in Swift that you can integrate into your project using Swift Package Manager. For example, by searching the the [Swift Package Index](https://swiftpackageindex.com). However, we don’t need to limit ourselves to Swift.

In an iOS app, it’s technically fairly easy to also use code written in C, C++, Objective-C, Objective-C++ or JavaScript. In this article, we’ll look at how to call JavaScript code from Swift using JavaScriptCore. As an example, I’ll go through the steps of adding a JavaScript dependency to my [iOS reading app](/reading-app/) to remove tracking parameters from URLs.

I’m not talking about hybrid technologies like React Native that let you write your app’s UI in JavaScript. This is about specific components in the logic — even single functions.

## Case study: Removing tracking parameters from URLs in JavaScript

I make a [reading app](/reading-app/) that lets users save webpages to read later. Some webpage links are shared with tracking parameters added that don’t provide any value to the user. I decided it would be nice for users if my app transparently removed these tracking parameters when saving articles.

For example this URL:

    https://example.com/something?utm_source=whatever

would become just:

    https://example.com/something

In general, query parameters are important to persevere since they can influence the page content, so the main challenge in solving this problem is knowing which parameters are likely used for tracking. I don’t want to assemble a list of common tracking parameters myself when there are open source options that already have a community invested in keeping an up-to-date list of tracking parameters.

One option that caught my eye was [Chris Newhouse’s URL Tracking Stripper Chrome extension](https://github.com/newhouse/url-tracking-stripper). In this project, I can see the URL modifications are performed by the file [`trackers.js`](https://github.com/newhouse/url-tracking-stripper/blob/master/assets/js/trackers.js).

In particular, this file defines an `ALL_TRACKERS` constant and this function:

<pre><code class="hljs"><span class="hljs-function"><span class="hljs-keyword">function</span> <span class="hljs-title">removeTrackersFromUrl</span>(<span class="hljs-params">url, trackers</span>) </span>{
    ...
}
</code></pre>

This seems likely to be a viable solution to my problem.

### Integrating the dependency

If you have a lot of JavaScript dependencies, which in turn have their own dependences, it would probably be a good idea to use a JavaScript dependency manager, like [npm](https://www.npmjs.com). In my case I don’t have many JavaScript dependencies, so I just added this repository as a Git submodule. I’ll skip over the details of this.

Next I added [`trackers.js`](https://github.com/newhouse/url-tracking-stripper/blob/master/assets/js/trackers.js) to my Xcode project and added it as a resource of my target in Xcode. Swift code is compiled into machine code. On the other hand, JavaScript is an interpreted language, and the source code is shipped inside the app bundle exactly as you see it.

### Creating a JavaScript environment

To run JavaScript from our app, we use the [JavaScriptCore](https://developer.apple.com/documentation/javascriptcore) framework from Apple.

<pre><code class="hljs"><span class="hljs-keyword">import</span> JavaScriptCore</code></pre>

JavaScriptCore provides an environment for executing JavaScript. There is no webpage, UI or document objet model (DOM).

The JavaScript environment is separate from the environment our Swift code runs in, so we need to explicitly move data between the Swift and JavaScript environments. In fact, you can have as many JavaScript environments are you like by creating instances of the [`JSContext`](https://developer.apple.com/documentation/javascriptcore/jscontext) class from our Swift code.

### Loading the JavaScript code

First we need to load [`trackers.js`](https://github.com/newhouse/url-tracking-stripper/blob/master/assets/js/trackers.js) into our JavaScript environment:

<pre><code class="hljs"><span class="hljs-keyword">let</span> context =<span class="hljs-attribute"> JSContext</span>()!
<span class="hljs-keyword">let</span> scriptURL = <span class="hljs-type">Bundle</span>.<span class="hljs-attribute">main</span>.<span class="hljs-attribute">url</span>(forResource: <span class="hljs-string">"trackers"</span>, withExtension: <span class="hljs-string">"js"</span>)!
<span class="hljs-keyword">let</span> script = <span class="hljs-keyword">try</span>!<span class="hljs-attribute"> String</span>(contentsOf: scriptURL)
context.<span class="hljs-attribute">evaluateScript</span>(script)</code></pre>

That will make the `removeTrackersFromUrl` available and load in a few constants such as `ALL_TRACKERS`.

You may have noticed I force unwrapped the call to the initialiser of [`JSContext`](https://developer.apple.com/documentation/javascriptcore/jscontext). Most of Apple’s frameworks that have an Objective-C API have been nicely bridged to Swift by adding [nullability annotations](https://developer.apple.com/documentation/swift/designating-nullability-in-objective-c-apis) and other refinements. This hasn’t been done for JavaScriptCore, so lots of its APIs are bridged to Swift using [implicitly unwrapped optionals](https://www.hackingwithswift.com/example-code/language/what-are-implicitly-unwrapped-optionals), and we don’t really know if these APIs might return nil. In this case I don’t know any reason creating a [`JSContext`](https://developer.apple.com/documentation/javascriptcore/jscontext) might fail so I took the risk, but it might be wise to handle nil more gracefully.

### Calling a JavaScript function from Swift

Now we can run the `removeTrackersFromUrl` function in the JavaScript environment like this:

<pre><code class="hljs"><span class="hljs-keyword">let</span> output = context.<span class="hljs-attribute">evaluateScript</span>(<span class="hljs-string">"removeTrackersFromUrl('https://example.com/something?utm_source=whatever', ALL_TRACKERS)"</span>)</code></pre>

Since this script calls a function directly, `evaluateScript(_:)`  will return the output of the JavaScript function into the Swift environment as a [`JSValue`](https://developer.apple.com/documentation/javascriptcore/jsvalue).

The second parameter was straightforward to pass in because we used a constant already defined in the JavaScript environment.

### Passing a value dynamically from Swift to JavaScript

For the first parameter of the JavaScript function, we need to pass in the URL. This value needs to come from the Swift environment.

We could use string interpolation like this:

<pre><code class="hljs"><span class="hljs-keyword">let</span> output = context.<span class="hljs-attribute">evaluateScript</span>(<span class="hljs-string">"removeTrackersFromUrl('\(inputURL.absoluteString)', ALL_TRACKERS)"</span>)</code></pre>

This sort of code is inviting code injection security vulnerabilities. Instead, we can set our input URL as a variable in the JavaScript environment and then reference it by name.

[`JSContext`](https://developer.apple.com/documentation/javascriptcore/jscontext) lets us read variables (in Swift) from JavaScript using `objectForKeyedSubscript(_:)` and set variables using `setObject(_:forKeyedSubscript)`. Oddly, this API is nicer to use in Objective-C since these map to subscript syntax so you can read and set values like in a dictionary. Subscript syntax doesn’t seem to work in Swift here.

Here’s setting the input URL using a variable:

<pre><code class="hljs"><span class="hljs-comment">// The prefix is very defensive to avoid overwriting a variable name already in use.</span>
<span class="hljs-keyword">let</span> inputName = <span class="hljs-string">"dh_inputURL"</span> <span class="hljs-keyword">as</span> <span class="hljs-type">NSString</span>
context.<span class="hljs-attribute">setObject</span>(inputURL.<span class="hljs-attribute">absoluteString</span>, forKeyedSubscript: inputName)
<span class="hljs-keyword">let</span> output = context.<span class="hljs-attribute">evaluateScript</span>(<span class="hljs-string">"removeTrackersFromUrl(\(inputName), ALL_TRACKERS)"</span>)
<span class="hljs-comment">// Not strictly necessary, but we could clean up:</span>
context.<span class="hljs-attribute">setObject</span>(<span class="hljs-literal">nil</span>, forKeyedSubscript: inputName)
</code></pre>

JavaScriptCore models values from the JavaScript environment using the [`JSValue`](https://developer.apple.com/documentation/javascriptcore/jsvalue) class in Swift. It’s a wrapper object, from which you can obtain values as specific types like strings and integers.

All that’s left for our case study is to convert `output` from a [`JSValue`](https://developer.apple.com/documentation/javascriptcore/jsvalue) to a `String` and then a `URL`:

<pre><code class="hljs"><span class="hljs-keyword">if</span> <span class="hljs-keyword">let</span> outputString = output?.<span class="hljs-attribute">toString</span>(), <span class="hljs-keyword">let</span> outputURL =<span class="hljs-attribute"> URL</span>(string: outputString) {
    <span class="hljs-keyword">return</span> outputURL
} <span class="hljs-keyword">else</span> {
    <span class="hljs-comment">// The output is missing or invalid for some reason. Handle error.</span>
}
</code></pre>

## Conclusion

Calling JavaScript from Swift code is easily possible, although this isn’t friction-free. The interoperability is nowhere close to as good as between Swift and Objective-C. It’s also obvious that the JavaScriptCore API was designed for Objective-C and hasn’t been properly refined for Swift. That said, in the end, I’d rather have a more robust solution to a problem regardless of the programming language used to implement that solution, even if this means a little more friction.

By searching for open source solutions using a wider range of programming languages, we broaden our search scope so are more likely to find a great existing solutions for our problems. This is especially true of JavaScript because there are so many more web developers than iOS developers.

The example I used here is simple. It wouldn’t have taken very long to manually translate the whole [`trackers.js`](https://github.com/newhouse/url-tracking-stripper/blob/master/assets/js/trackers.js) file from JavaScript into Swift. However the benefit of using the open source code directly is that if the list of trackers changes with time, I can update my project to use that just by updating the submodule. You could take this further by using a JavaScript dependency manager.

Let’s celebrate diversity of programming languages rather than being fussy about striving for some kind of purity in our codebases. While I choose to use Swift — and a tiny bit of Objective-C — I’m proud that my [reading app](/reading-app/) has major dependencies in [C](https://github.com/htacg/tidy-html5) and [JavaScript](https://github.com/mozilla/readability) that do their job well.

If you want to read more like this, you can [follow me](/follow/).

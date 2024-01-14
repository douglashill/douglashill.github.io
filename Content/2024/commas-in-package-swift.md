title: Commas in `Package.swift`
description: Is anyone else putting commas before argument labels in `Package.swift`, like [this](https://github.com/douglashill/douglashill.github.io/blob/main/Package.swift), for nicer diffs and so lines can be commented out easily?
date: 2024-01-14
time: 11:01:06+0000
%%%

Is anyone else putting commas before argument labels in `Package.swift`, like [this](https://github.com/douglashill/douglashill.github.io/blob/main/Package.swift), for nicer diffs and so lines can be commented out easily?

<pre><code class="hljs"><span class="hljs-keyword">let</span> package =<span class="hljs-attribute"> Package</span>(
	name: <span class="hljs-string">"generate"</span>
	, platforms: [
		.<span class="hljs-literal">macOS</span>(.<span class="hljs-attribute">v13</span>),
	]
	, targets: [
		.<span class="hljs-literal">executableTarget</span>(
			name: <span class="hljs-string">"generate"</span>
			, path: <span class="hljs-string">""</span>
			, exclude: [<span class="hljs-string">"Content"</span>, <span class="hljs-string">"Output"</span>]
<span class="hljs-comment">//			, swiftSettings: [</span>
<span class="hljs-comment">//				.define("ENABLE_PERFORMANCE_LOGGING")</span>
<span class="hljs-comment">//			]</span>
		),
	]
)</code></pre>

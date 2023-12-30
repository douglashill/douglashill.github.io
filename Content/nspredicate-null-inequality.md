title: `NSPredicate`: an old API with new surprises
description: Discovering an inconsistency in how `NSPredicate` handles matching inequality with nil values, and implementing something better.
micro: Recently I was working with `NSPredicate`, and a situation that looked fairly basic wasn’t working as I expected. I wrote about a new surprise with this old API.
date: 2023-01-18
time: 07:40:00+00:00
%%%

Recently I was working with [`NSPredicate`](https://developer.apple.com/documentation/foundation/nspredicate) — an API that’s been around since Mac OS X Tiger was released in 2005 — and a situation that looked fairly basic wasn’t working as I expected.

I’ve been implementing support for Apple Shortcuts in my [reading app](/reading-app/) so users can create automated workflows. I noticed certain property-based article queries using [`EntityPropertyQuery`](https://developer.apple.com/documentation/appintents/entitypropertyquery) weren’t returning the expected number of articles. I had fourteen articles saved on the iPad simulator. Four of these articles were written by me. However when I searched for articles where the author was not “Douglas Hill”, there were only two results instead of the expected ten.

It was clear that articles were not being included where the article’s author was not set. In other words, when the author property was nil. (I’ll mix the terms nil and null in this article because these represent the same concept with different names in different software stacks.)

## Tracking down the problem

Firstly let’s consider the most basic test:

<pre><code class="hljs"><span class="hljs-keyword">let</span> maybeString: <span class="hljs-type">String?</span> = <span class="hljs-literal">nil</span>
<span class="hljs-keyword">let</span> condition = maybeString != <span class="hljs-string">"test"</span></code></pre>

The expectation is that `condition` would be true in this case. If we’d used `==`, then the result would clearly be false. However this uses `!=` so we expect the opposite. Good news: this is indeed how it works!

Secondly I ran a quick test in a playground using `NSPredicate` in a simple situation:

<pre><code class="hljs"><span class="hljs-class"><span class="hljs-keyword">class</span> <span class="hljs-title">MyObject</span>: <span class="hljs-title">NSObject</span> </span>{
    <span class="hljs-meta">@objc</span> <span class="hljs-keyword">var</span> author: <span class="hljs-type">String?</span>
   <span class="hljs-attribute"> init</span>(author: <span class="hljs-type">String?</span>) {
        <span class="hljs-keyword">self</span>.<span class="hljs-attribute">author</span> = author
    }
}

<span class="hljs-keyword">let</span> array = [
   <span class="hljs-attribute"> MyObject</span>(author: <span class="hljs-string">"Douglas Hill"</span>),
   <span class="hljs-attribute"> MyObject</span>(author: <span class="hljs-string">"Someone else"</span>),
   <span class="hljs-attribute"> MyObject</span>(author: <span class="hljs-literal">nil</span>),
]

(array <span class="hljs-keyword">as</span> <span class="hljs-type">NSArray</span>).<span class="hljs-attribute">filtered</span>(using:<span class="hljs-attribute"> NSPredicate</span>(format: <span class="hljs-string">"author != %@"</span>, <span class="hljs-string">"Douglas Hill"</span>))
<span class="hljs-comment">// [{NSObject, author "Someone else"}, {NSObject, nil}]</span></code></pre>

This test showed that filtering for objects where the author was not “Douglas Hill” *did* include objects where the author was nil. This is the behaviour I’d expect.

At this point I was strongly suspecting this was related to the SQLite store that my Core Data stack is using. I’m sure SQL veterans know the answer already.

Thirdly, I did some debugging with my Core Data store without involving Shortcuts, and saw the same as what I saw with Shortcuts: filtering for an attribute not being equal to some value would not include objects where that attribute was nil.

I enabled `-com.apple.CoreData.SQLDebug 3` and this showed that the SQL commands being generated were straightforward. This predicate: `author != "Douglas Hill"` would add this to the SQL `SELECT` command:

<pre><code class="hljs"><span class="hljs-type">WHERE</span>  t0.<span class="hljs-attribute">ZAUTHOR</span> &lt;&gt; ?</code></pre>

Where the value of the `?` is:

<pre><code class="hljs"><span class="hljs-type">SQLite</span> bind[<span class="hljs-number">0</span>] = <span class="hljs-string">"Douglas Hill"</span></code></pre>

I’ve never worked with SQL directly, only with it as an implementation detail (and performance detail) of Core Data. At this point my hypothesis was that this handling of null was just how SQL works.

Sadly, SQL doesn’t seem to be a free and open standard where you can easily read the reference/specification to verify a detail like this. I did some research online and second-hand sources supported my hypothesis. `NULL` is not considered equal or unequal to anything in SQL, or in other words, comparisons with null are neither true nor false.

This comment by [jsumrall](https://stackoverflow.com/questions/5658457/not-equal-operator-on-null) on a Stack Overflow question sums it up well:

> It should also be noted that because `!=` only evaluates for values, doing something like `WHERE MyColumn != 'somevalue'` will not return the `NULL` records.

## What would a user expect?

From a programmer’s point of view, I wouldn’t say either way to handle null is unequivocally better. However I‘d expect consistency from `NSPredicate`. The surprising thing to me is that Core Data doesn’t smooth over this behaviour of SQL in order to match how comparisons usually work on Apple’s software stacks.

From a user’s point of view, I think the situation is different. Users won’t be as keenly aware of the concept of null. There is a good chance they think of null and an empty string as being the same. Since my queries will be exposed to users through Shortcuts, I think it’s more expected that filtering for items with a property not equal to some value should include items where that property is null.

## Implementing better behaviour

It’s easy to smooth over this quirk ourselves. When setting up a predicate for a Core Data SQLite store with a condition of being not equal to some value. Don’t set up the predicate like this:

<pre><code class="hljs"><span class="hljs-type">NSPredicate</span>(format: <span class="hljs-string">"%K != %@"</span>, stringKey, nonNilValue)</code></pre>

Instead we also check for equality with nil/null, setting up the predicate like this:

<pre><code class="hljs"><span class="hljs-type">NSPredicate</span>(format: <span class="hljs-string">"%K != %@ OR %K == NIL"</span>, stringKey, nonNilValue, stringKey)</code></pre>

In practice, here’s what that looks like as a convenience extension on [`NotEqualToComparator`](https://developer.apple.com/documentation/appintents/notequaltocomparator) from Apple’s App Intents framework (the Shortcuts API):

<pre><code class="hljs"><span class="hljs-keyword">private</span> <span class="hljs-class"><span class="hljs-keyword">extension</span> <span class="hljs-title">NotEqualToComparator</span>&lt;<span class="hljs-title">EntityProperty</span>&lt;<span class="hljs-title">String</span>?&gt;, <span class="hljs-title">String</span>?, <span class="hljs-title">NSPredicate</span>&gt; </span>{
    <span class="hljs-comment">/// Creates a comparator for case- and diacritic-insensitive matching of an optional string property using an NSPredicate for Core Data objects. (My objects are articles.)</span>
    <span class="hljs-keyword">convenience</span><span class="hljs-attribute"> init</span>(keyPath: <span class="hljs-type">KeyPath</span>&lt;<span class="hljs-type">ArticleEntity</span>, <span class="hljs-type">EntityProperty</span>&lt;<span class="hljs-type">String?</span>&gt;&gt;) {
        <span class="hljs-comment">// Maps from Swift key paths to string keys.</span>
        <span class="hljs-keyword">let</span> stringKey = <span class="hljs-type">Article</span>.<span class="hljs-attribute">stringKey</span>(from: keyPath)
        <span class="hljs-keyword">self</span>.<span class="hljs-attribute">init</span>() { value <span class="hljs-keyword">in</span>
            <span class="hljs-keyword">if</span> <span class="hljs-keyword">let</span> value {
                <span class="hljs-keyword">return</span><span class="hljs-attribute"> NSPredicate</span>(format: <span class="hljs-string">"%K !=[cd] %@ OR %K == NIL"</span>, stringKey, value, stringKey)
            } <span class="hljs-keyword">else</span> {
                <span class="hljs-comment">// Ignore this branch for now since Shortcuts doesn’t have any UI that lets a nil value be passed here. My actual code is slightly different due to an interesting reason, but that’s not the topic of this article.</span>
            }
        }
    }
}</code></pre>

## Summary

- In Swift, the result of `nil != nonNilValue` is true.
- Generally an `NSPredicate` created as `NSPredicate(format: "%K != %@", stringKey, nonNilValue)` will match objects where the property corresponding to `stringKey` is nil.
- When fetching from a Core Data SQLite store, a predicate created as above will *not* match objects where the property corresponding to `stringKey` is nil. This is because Core Data directly maps the command to SQL, and SQL specifies that no value is equal or unequal to null.
- This can be worked around by creating the predicate as `NSPredicate(format: "%K != %@ OR %K == NIL", stringKey, nonNilValue, stringKey)`.
- Lesson: Test all the things.

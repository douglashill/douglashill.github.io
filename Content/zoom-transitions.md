title: Zoom transitions
description: A detailed, illustrated guide to my favourite addition in the iOS 18 SDK.
micro: Zoom transitions are my favourite addition in the iOS 18 SDK. I tried out almost everything you can do with this new API and wrote a detailed, illustrated guide.
date: 2024-06-27T09:35:00+0100
%%%

Zoom transitions are my favourite addition in the iOS 18 SDK. They’re easy to implement, look great, and are fun!

<video src="article-to-image.mp4" poster="london-to-athens.jpg" controls width="100%" />

I ended up trying out almost everything you can do with the zoom transition API, both in test projects and in my [reading app](/reading-app/). In this post, I’ll share what I learned, starting with the most basic setup in both SwiftUI and UIKit, then looking at some more advanced topics further down.

<h2 id="Contents">Contents</h2>

- [When should the zoom transition be used?](#When-should-the-zoom-transition-be-used)
- [Zoom transitions in SwiftUI](#Zoom-transitions-in-SwiftUI)
  - [Using `NavigationLink`](#Using-NavigationLink)
  - [Using `fullScreenCover`](#Using-fullScreenCover)
- [Zoom transitions in UIKit](#Zoom-transitions-in-UIKit)
  - [Using navigation push](#Using-navigation-push)
  - [Using full screen presentation](#Using-full-screen-presentation)
  - [Capturing an appropriate identifier](#Capturing-an-appropriate-identifier)
- [Platform availability](#Platform-availability)
- [Fine-tuning the source view](#Fine-tuning-the-source-view)
  - [Filling an entire row/cell](#Filling-an-entire-row-cell)
  - [Avoiding gaps in grouped lists in UIKit](#Avoiding-gaps-in-grouped-lists-in-UIKit)
  - [Can the source view be missing?](#Can-the-source-view-be-missing)
  - [Does the source view need to be the same as the view that triggers the transition?](#Does-the-source-view-need-to-be-the-same-as-the-view-that-triggers-the-transition)
- [Fine-tuning the destination view](#Fine-tuning-the-destination-view)
  - [Zooming to only part of the destination view](#Zooming-to-only-part-of-the-destination-view)
  - [Can the destination view be partially transparent?](#Can-the-destination-view-be-partially-transparent)
  - [Can the zoom transition be used with sheets and popovers?](#Can-the-zoom-transition-be-used-with-sheets-and-popovers)
- [Gestures](#Gestures)
- [Can you spin items around as you pinch to close?](#Can-you-spin-items-around-as-you-pinch-to-close)
- [Resources](#Resources)

<h2 id="When-should-the-zoom-transition-be-used">When should the zoom transition be used?</h2>

A zoom transition animates from a *source view* to a *destination view* and back again.

<video src="reading-list.mp4" poster="reading-list.png" controls width="100%" />

The best fit for zooming is when the destination view shows a larger version of the source view, like going from an image thumbnail to an image that fills the window. Additionally, this transition can look decent when the source view is large and has an aspect ratio similar to the destination view. Zooming doesn’t look good when the source view is a skinny row in a list that fills the entire width of the window — although if the row shows a thumbnail image then that might be a more suitable source view.

Zoom transitions are available both for navigation push/pop and full screen present/dismiss transitions. If your destination view should have a navigation bar with a back button, use the former. If you want a close/done button instead, use the latter.

<h2 id="Zoom-transitions-in-SwiftUI">Zoom transitions in SwiftUI</h2>

Zoom transitions are easy to implement in SwiftUI. Apply the [`navigationTransition`](https://developer.apple.com/documentation/swiftui/view/navigationtransition(_:)) modifier with [`zoom(sourceID:in:)`](https://developer.apple.com/documentation/swiftui/navigationtransition/zoom(sourceid:in:)) to the destination view and the [`matchedTransitionSource`](https://developer.apple.com/documentation/swiftui/view/matchedtransitionsource(id:in:)) modifier to the source view. To connect the source view and destination view, provide a (possibly non-unique) identifier and a namespace, which together create a unique identifier for the transition.

The examples below show exactly where to apply these modifiers. I’m using a placeholder `Item` type to represent the data being shown.

<h3 id="Using-NavigationLink">Using <code>NavigationLink</code></h3>

- **Source:** Either the `NavigationLink` itself (shown below) or a child view built by the `NavigationLink`’s `label` closure.
- **Destination:** The view built by the `NavigationLink`’s `destination` closure.

<pre><code class="hljs"><span class="hljs-class"><span class="hljs-keyword">struct</span> <span class="hljs-title">ContentView</span>: <span class="hljs-title">View</span> </span>{
    <span class="hljs-keyword">let</span> items: [<span class="hljs-type">Item</span>]
    <strong class="hljs-addition"><span class="hljs-type">@Namespace</span> <span class="hljs-keyword">var</span> transitionNamespace</strong>

    <span class="hljs-keyword">var</span> body: <span class="hljs-keyword">some</span> <span class="hljs-type">View</span> {
        <span class="hljs-type">NavigationStack</span> {
           <span class="hljs-type"> List</span>(items) { item <span class="hljs-keyword">in</span>
                <span class="hljs-type">NavigationLink</span> {
                   <span class="hljs-type"> DetailView</span>(item: item)
                        <strong class="hljs-addition">.<span class="hljs-attribute">navigationTransition</span>(.<span class="hljs-attribute">zoom</span>(sourceID: item, in: transitionNamespace))</strong>
                } label: {
                   <span class="hljs-type"> ItemRow</span>(item: item)
                }
                <strong class="hljs-addition">.<span class="hljs-attribute">matchedTransitionSource</span>(id: item, in: transitionNamespace)</strong>
            }
        }
    }
}</code></pre>

<h3 id="Using-fullScreenCover">Using <code>fullScreenCover</code></h3>

- **Source:** If, for example, the transition is to be triggered by tapping a `Button`, the source view would be either the `Button` itself (shown below) or a child view built by the `Button`’s `label` closure.
- **Destination:** The view built by the `fullScreenCover` modifier’s `content` closure.

<pre><code class="hljs"><span class="hljs-class"><span class="hljs-keyword">struct</span> <span class="hljs-title">ContentView</span>: <span class="hljs-title">View</span> </span>{
    <span class="hljs-keyword">let</span> items: [<span class="hljs-type">Item</span>]
    <span class="hljs-type">@State</span> <span class="hljs-keyword">var</span> presentedItem: <span class="hljs-type">Item?</span>
    <strong class="hljs-addition"><span class="hljs-type">@Namespace</span> <span class="hljs-keyword">var</span> transitionNamespace</strong>

    <span class="hljs-keyword">var</span> body: <span class="hljs-keyword">some</span> <span class="hljs-type">View</span> {
        <span class="hljs-type">NavigationStack</span> {
           <span class="hljs-type"> List</span>(items) { item <span class="hljs-keyword">in</span>
                <span class="hljs-type">Button</span> {
                    presentedItem = item
                } label: {
                   <span class="hljs-type"> ItemRow</span>(item: item)
                }
                <strong class="hljs-addition">.<span class="hljs-attribute">matchedTransitionSource</span>(id: item, <span class="hljs-keyword">in</span>: transitionNamespace)</strong>
            }
            .<span class="hljs-attribute">fullScreenCover</span>(item: $presentedItem) { item <span class="hljs-keyword">in</span>
                <span class="hljs-type">NavigationStack</span> {
                   <span class="hljs-type"> DetailView</span>(item: item)
                        .<span class="hljs-attribute">toolbar</span> {
                            <span class="hljs-type">Button</span> {
                                presentedItem = <span class="hljs-keyword">nil</span>
                            } label: {
                               <span class="hljs-type"> Text</span>(<span class="hljs-string">"Done"</span>)
                            }
                        }
                }
                <strong class="hljs-addition">.<span class="hljs-attribute">navigationTransition</span>(.<span class="hljs-attribute">zoom</span>(sourceID: item, <span class="hljs-keyword">in</span>: transitionNamespace))</strong>
            }
        }
    }
}</code></pre>

<h2 id="Zoom-transitions-in-UIKit">Zoom transitions in UIKit</h2>

Since UIKit views are reference types, the destination and source can be established in one place by setting the [`preferredTransition`](https://developer.apple.com/documentation/uikit/uiviewcontroller/4448100-preferredtransition) property of the destination view controller to [`zoom(options:sourceViewProvider:)`](https://developer.apple.com/documentation/uikit/uiviewcontroller/transition/4448132-zoom), so the implementation is arguably easier than in SwiftUI.

<h3 id="Using-navigation-push">Using navigation push</h3>

<pre><code class="hljs"><span class="hljs-function"><span class="hljs-keyword">func</span> <span class="hljs-title">collectionView</span><span class="hljs-params">(<span class="hljs-number">_</span> collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)</span></span> {
    collectionView.<span class="hljs-attribute">deselectItem</span>(at: indexPath, animated: <span class="hljs-literal">true</span>)

    <span class="hljs-keyword">let</span> detailViewController =<span class="hljs-type"> DetailViewController</span>()
<strong class="hljs-addition">    detailViewController.<span class="hljs-attribute">preferredTransition</span> = .<span class="hljs-attribute">zoom</span>(sourceViewProvider: { context <span class="hljs-keyword">in</span>
        <span class="hljs-comment">//  Warning: This assumes indexPath will always refer to the same item later.</span>
        collectionView.<span class="hljs-attribute">cellForItem</span>(at: indexPath)?.<span class="hljs-attribute">contentView</span>
    })</strong>

    navigationController!.<span class="hljs-attribute">pushViewController</span>(detailViewController, animated: <span class="hljs-literal">true</span>)
}</code></pre>

<h3 id="Using-full-screen-presentation">Using full screen presentation</h3>

<pre><code class="hljs"><span class="hljs-function"><span class="hljs-keyword">func</span> <span class="hljs-title">collectionView</span><span class="hljs-params">(<span class="hljs-number">_</span> collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)</span></span> {
    collectionView.<span class="hljs-attribute">deselectItem</span>(at: indexPath, animated: <span class="hljs-literal">true</span>)

    <span class="hljs-keyword">let</span> detailNavigationController =<span class="hljs-attribute"> UINavigationController</span>(rootViewController:<span class="hljs-type"> DetailViewController</span>())
<strong class="hljs-addition">    detailNavigationController.<span class="hljs-attribute">preferredTransition</span> = .<span class="hljs-attribute">zoom</span>(sourceViewProvider: { context <span class="hljs-keyword">in</span>
        <span class="hljs-comment">//  Warning: This assumes indexPath will always refer to the same item later.</span>
        collectionView.<span class="hljs-attribute">cellForItem</span>(at: indexPath)?.<span class="hljs-attribute">contentView</span>
    })</strong>

   <span class="hljs-attribute"> present</span>(detailNavigationController, animated: <span class="hljs-literal">true</span>)
}</code></pre>

<h3 id="Capturing-an-appropriate-identifier">Capturing an appropriate identifier</h3>

The simple examples above assume the index path is a stable identifier and that the item shown by the destination view can’t change while the destination view is visible. To handle more realistic cases:

- If the items in the collection view might change, capture a stable identifier you define for your model objects in the `sourceViewProvider` and use that identifier to look up the index path and then the cell.

- If the item shown by the destination view might change while the destination view is visible, either weakly capture `detailViewController` or use the `sourceViewProvider`’s `context` argument to get the `zoomedViewController` and cast that to the type of your view controller subclass. Then make sure you have a way to look up the current item displayed by the destination view.

<h2 id="Platform-availability">Platform availability</h2>

- **iOS:** Zoom transitions are implemented.

- **visionOS, tvOS and watchOS:** The zoom transition APIs are available but appear to have no effect.

- **Mac Catalyst:** The zoom transition APIs are available. I haven’t yet installed macOS 15 to test if the transition has an effect on Mac. (Wouldn’t a macOS simulator be handy?) Please let me know if you’ve tested this.

- **macOS:** The SwiftUI zoom transition APIs are unavailable. It’s unclear why we need to write conditionally compiled SwiftUI code to accommodate macOS, while on all other platforms the API exists even if it’s ignored. I presume this is related to how SwiftUI is internally backed by UIKit on all other platforms, but this feels like an implementation detail that shouldn’t leak into the API.

<h2 id="Fine-tuning-the-source-view">Fine-tuning the source view</h2>

<h3 id="Filling-an-entire-row-cell">Filling an entire row/cell</h3>

SwiftUI views may hug their content. I found when using zoom transition  with `fullScreenCover` from the row of a `List`, the animation started from an area tightly hugging the visible row content. To animate the zoom from the full width of the row, I added a `Spacer` so the source view fills the available space. I’d like to hear if there is a neater solution.

<pre><code class="hljs"><span class="hljs-class"><span class="hljs-keyword">struct</span> <span class="hljs-title">ItemRow</span>: <span class="hljs-title">View</span> </span>{
    <span class="hljs-keyword">var</span> body: <span class="hljs-keyword">some</span> <span class="hljs-type">View</span> {
        <span class="hljs-type"> HStack</span>() {
            <span class="hljs-type"> Image</span>(...)
            <span class="hljs-type"> Text</span>(...)
            <span class="hljs-comment">// Without this, the source for full screen cover</span>
            <span class="hljs-comment">// doesn’t fill the whole width of the cell.</span>
            <strong class="hljs-addition"><span class="hljs-type"> Spacer</span>(minLength: <span class="hljs-number">0</span>)</strong>
        }
    }
}</code></pre>

<h3 id="Avoiding-gaps-in-grouped-lists-in-UIKit">Avoiding gaps in grouped lists in UIKit</h3>

In UIKit, a slight improvement over what’s shown in [Russell Ladd’s WWDC session](https://developer.apple.com/wwdc24/10145) is to pass the cell‘s `contentView` as the source rather than the cell itself. This matches how the transition looks when set up in SwiftUI and avoids showing gaps in grouped style lists, which I think doesn’t look good.

<figure>
  <img src="full-cell.jpg" alt="Screenshot showing a gap in the list during a zoom transition" />
  <img src="content-view.jpg" alt="Screenshot showing just the list text being removed during a zoom transition" />
  <figcaption>Using the full cell as the source view (top) versus just the content view (bottom). Note that in general a zoom transition from a skinny row like this won’t look good. I could have made nicer example screenshots.</figcaption>
</figure>

<h3 id="Can-the-source-view-be-missing">Can the source view be missing?</h3>

Yes. If your source view is not available, you can omit the `matchedTransitionSource` (SwiftUI) or return `nil` from the `sourceViewProvider` (UIKit). In this case, the destination view will zoom from, or back to, the centre of the container view. Note that because `cellForItem(at:)` may or may not return a view for cells scrolled off the edge of the window because of prefetching, you might inconsistently see the zoom animation going either off the top/bottom of the window or to the centre of the window.

<h3 id="Does-the-source-view-need-to-be-the-same-as-the-view-that-triggers-the-transition">Does the source view need to be the same as the view that triggers the transition?</h3>

No. The source view can be whatever you like so technically can be unrelated to the view that triggers the transition. However this might create a confusing user experience.

A good way to make use of this flexibility is for the source view to be a thumbnail image that’s a subview of the cell being tapped.

<h2 id="Fine-tuning-the-destination-view">Fine-tuning the destination view</h2>

<h3 id="Zooming-to-only-part-of-the-destination-view">Zooming to only part of the destination view</h3>

To make the animation look great, special care needs taking if the source view is a visual miniature of only part of the destination view. A common situation where this occurs is when zooming into an image with an aspect ratio that doesn’t match the container view. Here’s the animation in slow motion when setting up the transition without any options:

<video src="without-alignmentRectProvider.mp4" poster="london-to-athens.jpg" controls width="100%" />

Notice how the ferry shifts because the aspect ratios of the source and destination don’t match:

![Screenshot during zoom animation showing image ‘ghosting’ effect on ferry.](double-ferry.jpg)

To fix this shifting image using UIKit, specify where the image is in the destination view using an [`alignmentRectProvider`](https://developer.apple.com/documentation/uikit/uiviewcontroller/transition/zoomoptions/4448127-alignmentrectprovider):

<pre><code class="hljs"><span class="hljs-keyword">let</span> options = <span class="hljs-type">UIViewController</span>.<span class="hljs-attribute">Transition</span>.<span class="hljs-attribute">ZoomOptions</span>()
options.<span class="hljs-attribute">alignmentRectProvider</span> = { context <span class="hljs-keyword">in</span>
    <span class="hljs-keyword">let</span> detailViewController = context.<span class="hljs-attribute">zoomedViewController</span> <span class="hljs-keyword">as</span>! <span class="hljs-type">DetailViewController</span>
    <span class="hljs-keyword">let</span> imageView = detailViewController.<span class="hljs-attribute">imageView</span>
    <span class="hljs-keyword">return</span> imageView.<span class="hljs-attribute">convert</span>(imageView.<span class="hljs-attribute">bounds</span>, to: detailViewController.<span class="hljs-attribute">view</span>)
}

detailViewController.<span class="hljs-attribute">preferredTransition</span> = .<span class="hljs-attribute">zoom</span>(options: options, sourceViewProvider: { context <span class="hljs-keyword">in</span>
   .<span class="hljs-literal"></span>.<span class="hljs-attribute"></span>.<span class="hljs-attribute"></span>
})
</code></pre>

I couldn’t find equivalent API in SwiftUI. I tried applying the `navigationTransition` modifier to a child view of the `NavigationLink`’s `destination` or the `fullScreenCover`’s `content`, but this didn’t make any difference. I’d love to know if I missing something here.

Here’s the animation in slow motion with the `alignmentRectProvider` specified:

<video src="with-alignmentRectProvider.mp4" poster="london-to-athens.jpg" controls width="100%" />

This looks great:

![Screenshot during zoom animation showing only one ferry.](fixed.jpg)

The transition might look even better if the black background didn’t zoom at all and instead cross-faded in place while only the image was zoomed. The same applies to any UI elements like toolbars in the destination view. We want to give the image a sense of physical presence, while the background is supposed to be empty space rather than a shape with concrete edges. Unfortunately this isn’t what Apple implemented. To achieve this, during the transition the destination view would need removing from its regular position in the view hierarchy, similar to what happens to the source view. Therefore I don’t see how this improvement could be made without altering the API to receive a view instead of an alignment rectangle.

<h3 id="Can-the-destination-view-be-partially-transparent">Can the destination view be partially transparent?</h3>

Not really. If you set the `modalPresentationStyle` of the destination view controller to `overFullScreen`, transparent regions in the destination view will show the views underneath once the transition ends, but during a zoom transition the system adds an opaque view in the system background colour behind the destination view.

<video src="over-full-screen.mp4" poster="london-to-athens.jpg" controls width="100%" />

<h3 id="Can-the-zoom-transition-be-used-with-sheets-and-popovers">Can the zoom transition be used with sheets and popovers?</h3>

No. Zoom transitions are only available for full screen presentations. If you try to show the destination view another way, either the modal presentation style or the transition will be ignored:

- **Sheet:** The presentation will be treated as full screen instead.

- **Popover:** This will show a popover, but the presentation and dismissal animations won’t be different to usual. Interestingly, the dismiss gestures (pinch and swipe down, described below) are installed on the popover and trigger a non-interactive dismissal; I presume this is a bug, but I wouldn’t say it’s at all important as this is not exactly a valid setup.

<h2 id="Gestures">Gestures</h2>

The forwards transition (push/present) is always triggered by our code in response to a discrete action (a tap). I can’t see a way to let users start this transition interactively with a ‘spread’ gesture on the source view. This was possible in Photos on iPhone OS 3.2 on the original iPad but not in more recent versions of Photos.

Interactive gestures for the reverse transition (pop/dismiss) are available automatically:

- **Pinch:** For both navigation and presentation, users can use a two finger pinch gesture to interactively reverse the zoom transition. This is intuitive but can be inconvenient because it requires two fingers. If the destination view is itself zoomable using a scroll view, the system will give that scroll view precedence, so the scroll view must be fully zoomed out before the user can pinch to pop/dismiss.

- **Swipe vertically:** In addition, users can interactively reverse the zoom transition by swiping down with one finger anywhere in the destination view. If the destination view scrolls vertically, dismissal is only possible when scrolled to the top. In beta 1, this was only available for full screen present/dismiss, but beta 2 enables this for navigation push/pop as well.

- **Swipe horizontally:** With a navigation push/pop zoom transition users can also go back interactively by swiping with a direct touch (a finger) from near the leading edge of the container. (This is the left edge with English.) If the destination view scrolls horizontally, users must scroll from away from the leading edge of the container. When scrolling with a trackpad/mouse, the back gesture always takes precedence. To scroll left, users must scroll right slightly then scroll left in one gesture. When using the default slide transition, you can only go back with a horizontal swipe if the content is fully scrolled to the start. Therefore this looks like a bug with the zoom transition (FB14083432). Last tested with iOS 18 developer beta 2.

I don’t know any API to access the gesture recognisers driving all these interactive transitions. This might be useful if you wanted to set up custom failure requirements with your own gesture recognisers, although I didn’t see any situation so far where the behaviour wasn’t already as I would expect.

With a full screen presentation, while the pinch and swipe down gestures mean that a user will be able to ‘escape’ from the destination view automatically, you should also add a close/done button for better discoverability and accessibility. I’ve shown this in the basic SwiftUI code sample near the top of this article. Adding a button isn’t necessary for a navigation push/pop because there will be a back button in the navigation bar by default.

<h2 id="Can-you-spin-items-around-as-you-pinch-to-close">Can you spin items around as you pinch to close?</h2>

Yes! It’s so fun:

<video src="spin.mp4" poster="spin.jpg" controls width="100%" />

I’m delighted with this new API. In my [reading app](/reading-app/) (used for the screen recordings in this article) I’m definitely going to use the zoom transition to go between seeing an image inline in an article and viewing that image filling the window. I’ll probably also use this transition to go from the list of articles to reading an article because the cells are quite large and this would let me delete code implementing custom interactive dismissal on swiping down.

<h2 id="Resources">Resources</h2>

To learn more about zoom transitions on iOS, check out:

- Russell Ladd’s WWDC 2024 session: [Enhance your UI animations and transitions](https://developer.apple.com/wwdc24/10145)
- [Enhancing your app with fluid transitions](https://developer.apple.com/documentation/uikit/animation_and_haptics/view_controller_transitions/enhancing_your_app_with_fluid_transitions) in the UIKit documentation

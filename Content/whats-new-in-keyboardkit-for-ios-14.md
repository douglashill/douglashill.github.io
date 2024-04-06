title: What’s new in KeyboardKit for iOS 14?
description: Some details about KeyboardKit’s new support for Swift Package Manager, sidebars and lists with `UICollectionView`.
date: 2020-10-08T07:50:08+0000
%%%

[KeyboardKit][] is my open source framework that makes it easy to add [full keyboard control](/keyboard-control/) to UIKit apps. In this post, I’d like to share some details of KeyboardKit’s new support for Swift Package Manager and sidebars, and then I’ll end with a little about what might be next for KeyboardKit.

## KeyboardKit is available using Swift Package Manager

Since KeyboardKit provides [localised text for its key command titles in 39 languages](/localisation-using-apples-glossaries/), it wasn’t possible to support Swift Package Manager before Swift 5.3 (included with Xcode 12). But now it is, so KeyboardKit can be integrated using Swift Package Manager. It’s easier than ever to add it to your project: You simply add a package with this repository URL:

    https://github.com/douglashill/KeyboardKit.git

Huge thanks to [Seb Jachec](https://twitter.com/Iamsebj) for [kicking this off and getting it all working](https://github.com/douglashill/KeyboardKit/pull/10).

KeyboardKit is also listed in the [Swift Package Index](https://swiftpackageindex.com/douglashill/KeyboardKit).

## Support for sidebars with KeyboardSplitViewController

Two of my favourite features of iOS 14 on iPad are sidebars and triple column layouts. To better support keyboard control across columns, KeyboardKit now provides a subclass of `UISplitViewController` called `KeyboardSplitViewController`. This class enables using **tab**, **shift-tab**, and the **left and right arrows** to move focus between columns. It’s also possible to use **escape** to dismiss an overlaid sidebar.

To show the new split view support in practice, the KeyboardKit demo app has switched from using a tab bar to using a sidebar.

![iPad screenshot showing a sidebar on the left with the title ‘KeyboardKit’ above the items: ‘Table View’, ‘List’, ‘Compositional Layout’, ‘Flow Layout’, ‘Scrolling’, ‘Paging’, and ‘Text’. On the right there is a grid of variable sized rectangles containing numbers.](sidebar.png)

Examples showing a triple column split view and tab bar can be found in a menu under the ‘Modal Examples’ button. Of course these menu items are instances of `UIKeyCommand` so can be accessed from a keyboard too.

![iPad screenshot showing three columns. Left column has the title ‘Food’ and items ‘Nuts and seeds’ and ‘Fruit and vegetables’. Middle column has title ‘Fruit and vegetables’ and items ‘Fruit’, ‘Berries’ and ‘Root vegetables’. Right column has title ‘Root vegetables’ and items ‘Carrot’, ‘Cassava’, ‘Daikon’, ‘Ginger’, ‘Lotus root’, ‘Potato’, ‘Swede’, ‘Turnip’, ‘Yam’.](triple-column.png)

`KeyboardKit` can’t implement split view keyboard control entirely on its own. An app’s support for full keyboard control is only as good as its first responder management, and first responder management is very specific to each app. The whole problem of making a split view accessible from a keyboard is how keyboard focus is moved between the columns, so this presents a challenge for KeyboardKit.

`KeyboardSplitViewController`’s solution is to take a very hands-off approach. It does the reusable part of tracking which of its columns is focused, updating this state in response to keyboard input and size changes. Your app must do the app-specific part by updating the first responder based on the state tracked by KeyboardKit. You do this by providing a `delegate` for the split view controller that conforms to the `KeyboardSplitViewControllerDelegate` protocol. In the delegate’s implementation of `didChangeFocusedColumn`, update the first responder to a view controller or view within the hierarchy of the split view controller’s `focusedColumn`. You can read more in the [guide on using `KeyboardSplitViewController`](https://github.com/douglashill/KeyboardKit/blob/main/KeyboardKit/KeyboardSplitViewController.md).

`KeyboardSplitViewController` supports right-to-left layouts for Hebrew and Arabic, and it works correctly if you set the `primaryEdge` to be the trailing edge to create something like an inspector sidebar.

One nice detail that tracking the focused column enables is that when the split view collapses for compact widths, it can default to keeping the view in the focused column visible. Your app retains control over collapsing using the `splitViewController(_:topColumnForCollapsingToProposedTopColumn:)` delegate method: `KeyboardSplitViewController` just tweaks the proposed column.

## Lists with UICollectionView work just as well as UITableView

[The new recommended approach for implementing lists](https://pspdfkit.com/blog/2020/the-case-for-lists-in-uicollectionview/) (whether in a sidebar or elsewhere) is to use `UICollectionView` with `UICollectionViewCompositionalLayout` with `UICollectionLayoutListConfiguration`. When trying out these new lists, I noticed that selection didn’t wrap around when reaching the top or bottom, and there was an issue with decoration view handling.

These issue have been fixed, so I’m delighted to say that using a keyboard to change selection in a `UICollectionView` now work just as well as with `UITableView`. The cool part is that because KeyboardKit is using a standard collection view, these improvements benefit any collection view layout, not just lists.

The demo app’s new sidebar gives it space to show more than five examples, so you’ll now find examples for a basic list using `UICollectionView` and another for a collection view using a composition layout with nested groups.

## New API for lists in sidebars

To work better with sidebars, new API has been added to respond to selection changes with arrow keys in a collection view or table view. This is useful because usually pressing arrows keys with a sidebar focused is sufficient to update the contents shown in a detail view. The user doesn’t need to explicitly press space or return to activate the selection. To support this, make your `KeyboardCollectionViewController` or your `KeyboardCollectionView`’s delegate conform to the `KeyboardCollectionViewDelegate` protocol (or equivalent for `UITableView`).

<pre><code class="hljs"><span class="hljs-function"><span class="hljs-keyword">func</span> <span class="hljs-title">collectionViewDidChangeSelectedItemsUsingKeyboard</span><span class="hljs-params">(<span class="hljs-number">_</span> collectionView: UICollectionView)</span></span> {
    <span class="hljs-keyword">if</span> <span class="hljs-keyword">let</span> indexPath = collectionView.<span class="hljs-attribute">indexPathsForSelectedItems</span>?.<span class="hljs-attribute">first</span> {
        <span class="hljs-comment">// Change detail view for new sidebar selection.</span>
    }
}
</code></pre>

These keyboard delegate protocols also feature new API to prevent clearing the selection in a collection view or table view. You typically want to prevent clearing selection with the escape key in a sidebar because sidebars usually have a persistent selection. This also enables the escape key to go straight though to dismissing an overlaid sidebar. Typical usage would be something like this:

<pre><code class="hljs"><span class="hljs-function"><span class="hljs-keyword">func</span> <span class="hljs-title">collectionViewShouldClearSelectionUsingKeyboard</span><span class="hljs-params">(<span class="hljs-number">_</span> collectionView: UICollectionView)</span></span> -&gt; <span class="hljs-type">Bool</span> {
    <span class="hljs-keyword">return</span> <span class="hljs-keyword">self</span>.<span class="hljs-attribute">splitViewController</span>.<span class="hljs-attribute">isCollapsed</span>
}
</code></pre>

## What’s next?

The most exciting keyboard-related development to come out of WWDC 2020 was the addition of the focus engine on Mac Catalyst. Using arrows keys to move focus is now a first class concept in UIKit on the Mac. This is based on the focus engine developed for tvOS, and it enables using arrow keys to move around within `UITableView` and `UICollectionView`, but in a more general purpose way to spatially navigate between *any* views if they choose to be focusable. The concept of a *focus group* has been added to bridge the behaviour of the focus engine on tvOS with how keyboard navigation works in AppKit. Arrow keys move focus within a focus group. Tab and shift-tab cycle through focus groups. The best thing about focus being a first class concept in UIKit is that UIKit takes care of tracking the currently focused item.

Presumably (hopefully?) this will make its way from the Mac to iPad at some point in the future For now, KeyboardKit’s support for focus in split views, collection views, and table view is the best option if your UIKit app supports iPad and iPhone as well as Mac. That said, I see this Catalyst addition as a hugely encouraging sign of what’s to come.

If UIKit takes care of focus in the future, KeyboardKit can take on a more specialised role of assisting with taking actions on items that have been selected. As far as I can tell, UIKit in iOS 14 added a single key command to perform an action: command-control-L to show and hide the sidebar of a `UISplitViewController`. It’s fantastic to see this kind of functionality in UIKit itself, but at a rate of one command per year there will be plenty of space for KeyboardKit to fill for many years.

I hope you give [KeyboardKit][] a try and make use of these new features. If you have suggestions for improving KeyboardKit I’d love to hear them: Please open a [pull request](https://github.com/douglashill/KeyboardKit/pulls) or an [issue](https://github.com/douglashill/KeyboardKit/issues/new).

[KeyboardKit]: https://github.com/douglashill/KeyboardKit

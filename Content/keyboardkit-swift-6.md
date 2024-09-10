title: Migrating KeyboardKit to Swift 6 language mode
description: [KeyboardKit](https://github.com/douglashill/KeyboardKit) is a small UI framework that runs only on the main thread, so was a simple test case to try out strict concurrency. I wanted to share three interesting situations that came up in the migration.
micro: Here are three interesting situations that came up migrating KeyboardKit to Swift 6 strict concurrency. It’s a small UI framework that runs only on the main thread, so was a great test case.
date: 2024-08-11T11:59:25+0100
%%%

Over the weekend, I updated [KeyboardKit](https://github.com/douglashill/KeyboardKit) to full data race safety with Swift 6 language mode. KeyboardKit is my open source framework that‘s the easiest way to add comprehensive hardware keyboard control to an iPad, iPhone, or Mac Catalyst app.

This is a great test case because KeyboardKit is a small UI framework that doesn’t perform any slow operations, so all its code is intended to be run on the main thread. It should be trivial to opt into strict concurrency. I didn’t want to spent more than about an hour on this.

Many issues were resolved simply by annotating types with `@MainActor`, but I wanted to share three interesting situations that came up in the migration, two of which seem like issues on Apple’s side. I used Xcode 16.0 beta 5.

## `UIView` and `UIViewController` subclasses can’t have a parameterless `init`

**Update:** This issue was [reported by Nacho Soto](https://github.com/swiftlang/swift/issues/75732) five days ago and [Holly Borla had a fix ready](https://github.com/swiftlang/swift/pull/75749) the same day. Thanks to [James Savage for bringing this to my attention](https://social.axiixc.com/@axiixc/112945383778325026).

I don’t use Interface Builder, so in my `UIViewController` subclasses I always want to change the designated initialisers away from `init(nibName:bundle:)` and `init(coder:)`. The KeyboardKit demo app had a couple of view controllers that reset the designated initialiser to a parameterless `init`. One of these is an abstract class where I reset the initialiser to avoid repeating this boilerplate in every subclass. However there was a concurrency warning:

```
class FirstResponderViewController: UIViewController {
    init() {
        super.init(nibName: nil, bundle: nil) // ❌ Call to main actor-isolated initializer 'init(nibName:bundle:)' in a synchronous nonisolated context
    }

    @available(*, unavailable) required init?(coder: NSCoder) { preconditionFailure() }
}
```

This is odd, because this entire class inherits main actor isolation from `UIViewController`. If we explicitly mark `init` as isolated, we see a more illuminating error message:

```
class FirstResponderViewController: UIViewController {
    @MainActor init() { // ❌ Main actor-isolated initializer 'init()' has different actor isolation from nonisolated overridden declaration
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable) required init?(coder: NSCoder) { preconditionFailure() }
}
```

It looks like `init` is considered non-isolated because it comes from the root class `NSObject`, which is not isolated to the main actor. This is odd because we haven’t had to write `override`.

My very silly solution is to change from a parameterless `init` to an initialiser with a `Void`-typed parameter. To avoid changes to all subclasses of `FirstResponderViewController`, I added a new direct subclass of `UIViewController`:

```
class InitialiserClearingViewController: UIViewController {
    init(onMainActor: Void) {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable) required init?(coder: NSCoder) { preconditionFailure() }
}
```

Then instead of subclassing `UIViewController` directly I subclassed `InitialiserClearingViewController`. At this point, a parameterless `init` will inherit main actor isolation from the class:

```
class FirstResponderViewController: InitialiserClearingViewController {
    init() {
        super.init(onMainActor: ())
    }
}
```

The same issue applies to `UIView` and to subclasses of `UIViewController` and `UIView` such as `UITableViewCell`.

I’ve reported this to Apple as *FB14752444: UIView and UIViewController subclasses can’t have a parameterless init with strict concurrency*.

## Global constants like `UIKeyCommand.inputUpArrow` are incorrectly isolated

UIKit’s global string constants for non-character keyboard inputs like `UIKeyCommand.inputUpArrow` are marked being isolated to the main actor. In Objective-C, these are free-standing constants, and I see no reason why they should be enforced to only use on the main thread. The `UIKeyCommand` class is isolated to the main actor, and I think the main actor isolation of these constants is an accidental side effect of the Swift refinement of these constants moving them into the `UIKeyCommand` namespace.

I’ve reported this to Apple as *FB14752336: UIKeyCommand.inputUpArrow and related constants are isolated to main actor*.

A lesson we can learn: When marking a type as isolated to an actor, consider whether there are any `static` /`class` constants that should be marked as `nonisolated`.

Back to KeyboardKit: During my quick first pass adding strict concurrency support, I simply marked code using these constants with `@MainActor`. I then marked code using that code with `@MainActor`, and so on since isolation spreads like a virus. This was not a problem internally for KeyboardKit, because all its code is intended to run on the main thread anyway. However the spread reached as far as public API, and that’s where I draw a line. I don’t want to pass on UIKit limitations to users of my framework. To be fair, these were a couple of constants that weren’t very important, but years of working on an SDK at [PSPDFKit](https://pspdfkit.com/) have made me strict about public API.

I didn’t find a way to force Swift to let me read a constant marked as isolated in a non-isolated context. Instead I created Objective-C wrapper functions around the UIKit constants. These are exported to Swift as (non-isolated) top-level functions. It’s been a while since I last made new Objective-C files, but here we go!

(Ironically considering the goal of having a great public API, these Objective-C functions leak into the public interface so that they can be accessed internally by KeyboardKit in Swift. They do at least each have an underscore prefix and are clearly documented as being for internal use only. You can’t win everything.)

## Swift concurrency doesn’t work well with protocol interposers that leverage the Objective-C runtime

This last situation is a bit more advanced, and I understand why Swift strict concurrency wouldn’t fit in well in this case.

I have a couple of classes in KeyboardKit that (mostly transparently) interpose as the delegate of `UIScrollView` and `UISplitViewController`, while allowing users of KeyboardKit to set their own delegate. This way, users of KeyboardKit can implement `UIScrollViewDelegate` and `UISplitViewControllerDelegate` as normal, while KeyboardKit can make the customisations it needs for full keyboard control.

This requires overriding the Objective-C runtime methods `respondsToSelector:` and `forwardingTargetForSelector:`, which results in these strict concurrency errors:

```
class ScrollViewKeyHandler: InjectableResponder, UIScrollViewDelegate {
    /// The delegate external to KeyboardKit.
    weak var externalDelegate: UIScrollViewDelegate?

    override func responds(to selector: Selector!) -> Bool {
        if super.responds(to: selector) {
            return true
        } else {
            return externalDelegate?.responds(to: selector) ?? false // ❌ Main actor-isolated property 'externalDelegate' can not be referenced from a nonisolated context
        }
    }

    override func forwardingTarget(for selector: Selector!) -> Any? {
        if let delegate = externalDelegate, delegate.responds(to: selector) { // ❌ Main actor-isolated property 'externalDelegate' can not be referenced from a nonisolated context
            return delegate
        } else {
            return super.forwardingTarget(for: selector)
        }
    }
}
```

The Swift compiler doesn’t know these methods simply forward the method call. The isolation expectations are hidden in the `Selector` (basically a string).

The solution I went for to opt out of strict concurrency here:

```
nonisolated(unsafe) weak var externalDelegate: UIScrollViewDelegate?
```

## Was the switch worthwhile?

I’m not sure. No data race safety issues were exposed. Overall it *was* fairly quick and easy to migrate, and this was a good learning experience. In the end it took about 1 hour and 20 mins, so that‘s not too bad. I spent more time writing this post.

Strict concurrency is complicated, as you can see by the number of issues that came up even with a small codebase that runs entirely on the main thread.

These changes have no impact on developers using KeyboardKit, but if you want to try it anyway these internal changes are available in [KeyboardKit](https://github.com/douglashill/KeyboardKit) 9.0.1, which also adds support for iOS 18 and Xcode 16. You can also see the [pull request implementing these changes](https://github.com/douglashill/KeyboardKit/pull/26).

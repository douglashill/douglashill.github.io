title: iPad-focused WWDC 2020 wish list
description: New stuff I’d like to see on iPad.
micro: With just a few days to go, here’s my iPad-focused WWDC 2020 wish list. It’s the only wish list with things like improving the feel of `UINavigationController`.
date: 2020-06-18
time: 22:21:07+0000
tweet: 1273742566173835266
%%%

As a heavy iPad user and iOS developer, what would I like to see in iOS 14? While my focus is on iPad, many of the points here would be beneficial on iPhone too.

## Views and view controllers

With trackpad and mouse support on iPad, you can swipe to go back from anywhere. It’s amazing. With fingers, you have to swipe from the edge — except for in the [lovely](https://apps.apple.com/app/unread-2/id1363637349) [apps](https://apps.apple.com/app/bear/id1016366447) that go out of their way to build custom UI that supports [sloppy swiping](https://jaredsinclair.com/2014/04/22/sloppy-swiping-how-to-make-an-a.html). I feel the current design (added in iOS 7) was a hedged bet to not interfere with other gestures in apps. Things are well established now: swiping to go back is a good interaction — let’s go all in and allow **swiping to go back from anywhere** in a `UINavigationController`.

iOS 7 was a long time ago and since then the state of the art in [fluid interfaces](https://developer.apple.com/wwdc18/803) has advanced. I find the physics of navigation controller’s interactive back transition feels clunky, especially by modern standards. The momentum is off. In fact, paging `UIScrollView`s have always felt better. Given how foundational `UINavigationController` is, a bit of tweaking would do a lot to boost the feel of the whole system.

`UISplitViewController` seems to make some decisions based on portrait versus landscape rather than looking at the actual width available. This is a rather antiquated way of doing layout in 2020. If you don’t customise `UISplitViewController`’s behaviour, it doesn’t make effective use of larger screens. If you do customise its behaviour, stuff seems to go wrong. If you nest `UISplitViewController`s things go bad fast. I’m not sure what the best route would be, but I would love to see some kind of UIKit container that decides how to lay out based on the content to show and the space available, and can easily handle modern iPad app layouts that use three or even four columns.

Paging scroll views are one of my favourite things. They feature prominently in every app I’ve ever worked on, and one thing I’ve wanted since my first app in 2012 is an easy way to have adjacent pages partially visible on the sides. There are several ways to achieve this but each has some complexity and downsides. `UIScrollView` can do this internally, but the API is not public so far. If you were ambitious, you could probably achieve this now with public API by ‘wrapping’ a scroll view in a `UICollectionView` with a compositional layout scrolling in the opposite direction. (Or you could set a `CGSize` value for the key `"interpageSpacing"`, but let’s keep that quiet.)

## Videos calls

The front facing camera on every model of iPad is much higher quality than the camera on any Mac. I’m amazed how it gets a clearer picture in much dimmer lighting. That said, iPads don’t work so well for video calls for two reasons. One is a hardware issue: for the more common landscape orientation the camera is to the side and not as high as it could be. The other reason is in software though: the camera can only be used by an app if it’s in the foreground. This limitation should be lifted so apps can use the **camera in the background**. It looks bad in a meeting when your video stops because you’re checking your notes or whatever.

## Contextual menus

The main improvement I think should be made to contextual menus is to [improve readability by putting the icons on the leading side](/menu-icon-swizzling/).

Apple’s apps sometimes include the default (single tap) action in the contextual menu. [The Human Interface Guidelines advise not doing this](https://developer.apple.com/design/human-interface-guidelines/ios/controls/context-menus/), but I believe this recommendation punishes hesitant users. My vote would be for the **default action to always be included at the top of contextual menus**.

## Text selection

**Bring back the text selection magnifying loupe**. The loss of the text selection loop is less of a problem for me simply because I mostly select text with a hardware keyboard or mouse. The mechanics of iOS 13’s updated text selection system are great, but this isn’t mutually exclusive with showing the loupe.

(As an aside, iOS 13’s text selection mechanics aren’t new: it’s been possible to select a range of text in a single gesture ever since text selection was added to iOS in iPhone OS 3. You did this by using a ‘tap-and-a-half’ instead of a long press. We now have two gestures that do the same thing.)

## Trackpad and mouse

The trackpad and mouse support added in iOS 13.4 is fantastic, and against all my expectations it transformed how I use my iPad. Now I have it in full-on desktop mode with the screen at eye level. I just have one little request: **hide the pointer in screenshots** (maybe optionally).

## Dynamic Type

Looking at our [Dynamic Type usage data from PDF Viewer](https://pspdfkit.com/blog/2018/improving-dynamic-type-support/), people are bunched up using the smallest text size. My hypothesis is that a significant number of people using the smallest size would go smaller if given the option. It would be interesting to find out by Apple adding an **extra extra small Dynamic Type category** that uses a body text size of 13 points. The main reason I’m considering adding a custom text size setting in my [reading app](/reading-app/) is to be able to go smaller, which would allow more columns in some configurations.

(There is also bunching up at the largest non-accessibility size. I’m not sure why the larger accessibility text sizes setting isn’t always turned on, since all it does is let the text size slider optionally slide up some more. More people would cross into the accessibility sizes if they didn’t have to find a separate more hidden setting.)

## Dark Mode

The great pure black versus dark grey on OLED debate seems to have been settled by many apps offering a setting so users can choose which type of darkness they prefer. I don’t think it’s just about OLED either. Personally I usually prefer pure black even on LCDs because I mostly use Dark Mode in dark environments where I want the screen to be as dim as possible. Apple could save us all implementing extra settings by adding a **system-wide setting for whether Dark Mode is pure black or dark grey**. This would kick in when an app uses dynamic system colours such as [`systemBackground`](https://developer.apple.com/documentation/uikit/uicolor/3173140-systembackground).

## Voice Control

The simultaneity of inputs on iPad is what makes it feel like a truly modern computer to me. You can freely mix and match touch, keyboard, mouse, Apple Pencil, and voice. iOS 13’s Voice Control seems groundbreaking as an accessibility feature, and Siri has been around for ages, but I feel there’s a tremendous amount of untapped potential with voice input as a mainstream way to interact with computers.

I hope we’ll be looking at gradual improvements for a few years, such as performance improvements, attention detection, and real-time dictation. Long term I can’t see there being such a binary separation between Voice Control and Siri. Computers that aren’t responsive to voice will feel broken, just as screens that aren’t touch screens feel broken today.

## Hardware keyboards

I’ve been banging the drum about [full hardware keyboard control in UIKit apps](/keyboard-control/) for a couple of years now. These days if you hop over to [apple.com/ipad](https://www.apple.com/ipad/) three of the four iPad models pictured are attached to hardware keyboards. I’m so pleased to see Apple taking keyboards seriously, although it feels as if software support isn’t quite in sync. I’d like to see **comprehensive and consistent support for keyboard commands across the system and apps**. This should cover almost all actions and navigation, with a few exceptions for things that work way better with touch such as text selection and drawing.

This will not happen unless **standard keyboard behaviour is built into UIKit itself**, as it is with AppKit on the Mac. There are many places where UIKit could go even further than AppKit in providing apps with great keyboard support out of the box. I know this because I implemented a lot of this in my [open source KeyboardKit framework](https://github.com/douglashill/KeyboardKit). Apple should steal every feature of KeyboardKit, and hopefully go even further with features such as multiple selection and re-ordering items in table views. There would be so many benefits. For example if `UICollectionView` supported keyboard navigation out of the box then the share sheet would inherit that. Since the share sheet process is run by the system there’s nothing app developers can do to make it keyboard navigable.

When selecting text, it would be nice to have control-command-D be an equivalent of the Look Up menu item, as it is on the Mac. The only reason I haven’t added this to KeyboardKit is that the Look Up popup can only be shown using private API.

Additionally, being able to operate system-level functionality from the keyboard would speed up common tasks. For example I’d like to use the keyboard to:

- Lock the screen. (The physical button is way up high when using an iPad in desktop mode with the screen at eye level. Reaching up there is a pretty weird interaction.
- Go to the space on the left or right.
- Make or break pairings in Split View.
- Show or hide Slide Over.
- Toggle the Slide Over app. (A kind of alternate command-tab.)
- Activate anything in control centre with system-wide key equivalents. (For example to start screen recording or toggle Dark Mode.)

## Software keyboard

It’s not all about hardware keyboards. I also use my iPad in tablet mode so I want to use the software keyboard (while the iPad stays connected to the hardware keyboard over Bluetooth). Counterintuitively, it’s possible to long press the keyboard dismiss button to show the software keyboard. (The down arrow at the right end of the keyboard suggestions bar.) While I’m usually all for reducing clutter, I think a matching **up arrow to show the software keyboard** would make this scenario more discoverable and feel less of an afterthought.

One further issue is that when a hardware keyboard is connected the button in the bottom-right corner of the software keyboard hides the software keyboard rather than making the current text input drop it’s typing focus (first responder). There is no **consistent way to drop typing focus** while a hardware keyboard is connected, and I feel there should be.

The two finger software keyboard scrub gesture to move the insertion point is a clever design but it has never worked well for me. I usually want to move the insertion point by small amounts. However the two finger gesture seems optimised for large scale movements, which I could do by touching the text directly. I have a suspicion that **arrow keys on the software keyboard** might work better for me.

I get a lot of use out of the paste button above the iPad keyboard. I know space is tight, but it would be so handy to have a **paste button on iPhone** too. The three finger gestures added in iOS 13 were a nice idea, but I find them too awkward.

## Multitasking and multiple windows

The multiple window support added in iOS 13 is a big step forward to making the iPad a mature platform for productivity. However I don’t use it that much, which is at least in part because the interactions can feel unwieldy. To not make this post even longer, I’ll ignore the possibility of a more ground-up redesign and consider some possible refinements.

Perhaps the simplest thing would be to **make it easier to close windows when they are paired**. When I want two webpages visible at once, I can make a quick window in Safari by dragging a tab to the side. However closing that window afterwards requires a little dance of first unpairing it from my original Safari window, and then going into the app switcher and swiping up on the window.

On the subject of swiping up, **app serial killers are still at large**. They’re wasting their time flicking away apps because for some reason iOS makes it so easy and satisfying to do an action that harms the performance of the device. I hope Apple puts an end to this terrible squandering of human time.

Slide Over on iOS 13 is so efficient for pulling apps up for quick use. I have Bear and OmniFocus in there all the time. One thing that’s a little odd is the way apps in Slide Over open in full screen instead when launched from the home screen (and sometimes even when not from the home screen). This quirk could be useful if I could work out how to predict what will happen, but unfortunately I haven’t even after all these months.

On the API side, one current omission is there is no way to **activate window scenes without forcing them into Split View**. It seemed to be a design goal of the iOS 11 multitasking system to make spaces user-controlled and stable. The fact that the only API to activate a window breaks space pairing seems at odds with this.

Finally, a design decision that’s baffled me for years is that the home screen is included in the command-tab switcher. The home screen is not an app, and I can get to it by pressing command-H. It’s presence in the switcher is actively harmful by breaking the common workflow of being in an app, going to a different app (via the home screen because that’s the standard way to switch apps) and then trying to tap command-tab to switch back to the previous app. I probably make this mistake several times a day. The **home screen should be removed from the command-tab switcher**. (**Edit:** This was indeed resolved in iOS 14 by always showing the home icon last in the switcher, which effectively removes it.)

## Default apps

Yes, this is a popular pick. There’s some nuance to this that I haven’t seen discussed elsewhere though. (Prerequisite to this: universal links should work reliably. I often need to pipe links through [Opener](https://apps.apple.com/app/opener-open-links-in-apps/id989565871) to force links to go to apps instead of Safari.) I see three things someone could mean by a default app:

- **Replace apps with system integration**. This is mainly the camera access from the lock screen. This would be cool, but I wouldn’t say I’m clamouring for it.
- **Open files of a certain type in a user-chosen app**. The other day when I dragged PDFs from the document browser in [PDF Viewer](https://itunes.apple.com/app/pdf-viewer-by-pspdfkit/id1120099014?mt=8) to the side of the screen, they would open in another PDF app. The next day doing the same thing would open new windows in PDF Viewer. Dragging PDFs in the same way in Files would open new Files windows. The user should be able to choose default apps for document types, and then the system wouldn’t need to pick randomly.
- **Open certain web links in a user-chosen app**. I’d like to send all twitter.com links to Tweetbot and all github.com links to Safari. That way I could have the (very slick) GitHub app installed without it stealing links it can’t yet handle (which is fair enough given how new the app is).

## Mail

After Safari, my most used Apple iPad app is Mail. I love the clean appearance and how it downloads messages directly from my email provider to my device. Mail in iOS 13.4 was a great improvement by adding a convenient button to delete whole threads.

[Self-sizing table view cells](https://pspdfkit.com/blog/2018/self-sizing-table-view-cells/) are a nicety of modern iOS development that it’s easy to take for granted. Previously, apps would display a fixed number of lines of text, which meant content could be truncated — especially for users who prefer large text sizes. Mail still uses a fixed number of lines. With only one line to display each message subject, it’s pretty likely they get truncated. Exacerbating the issue, recent versions of Mail don’t show the subject on the message detail screen either. I think Mail would be easier to use if it used self-sizing cells to **avoid truncating message subjects**, and also brought back **showing subjects on the message detail screen**.

I’m a fan of plain text, so I’d be delighted to see an option to force **message composition in plain text**. Pasted text being a different size to the surrounding text just isn’t my thing.

It’s cool that Mail supports drag and drop to export messages. It would be even more convenient to be able to export messages using the standard **share sheet**. One problem here is that the data provided by Mail is difficult for apps to make use of. Emails are encoded in an ancient format called MIME — it’s not much fun to work with in 2020. Apple could solve this by adding a tiny **MailKit framework** to the iOS SDK. All it needs to provide is a model object with strongly typed access to properties like recipients and plain text or HTML content of emails.

## Photos

The new editing UI added to Photos in iOS 13 has been working really well for me. It strikes a great balance between simplicity and power — and all these tools work with videos too! (How do you even crop and rotate videos on a Mac?)

Photos keep getting better at picking out highlights from my collection, and I love that. More of this please.

The presentation of actions available on photos is inconsistent, which throws me off just a little bit but quite often. Here’s how these appear across the app:

- The grid view in the Photos tab puts Share in the  bottom-left and Delete in the  bottom-right.
- The grid view in other tabs put both Share and Delete in the top-left.
- The full screen photo view put Share, Favourite and Delete in the top-right.

The action buttons can appear in all four corners of the screen depending on where you are in the app. Some consistency here would be appreciated.

I delete a lot of images. Photos often acts as a temporary place for screenshots on their way to some other location. Photos has both a delete confirmation step, and keeps deleted images around in Recently Deleted for a generous 40 days. For me the delete confirmation slows down operation of the app without providing useful safety, so I’d prefer if it were removed.

I have such a jumble of stuff in Photos. An easy way to toggle between screenshots, non-screenshots, and both in the all photos view would be really handy.

Lastly on Photos, I think it would look crisper and cleaner overall if the bar at the top of the Photos tab was an honest toolbar with a well defined edge.

## Privacy and App Store policy

Apple is so laudable for really caring about privacy. Sadly it seems there’s always going to be space for Apple to pressure apps further on upholding respectable privacy standards. Two violations that have been bothering me are unnecessary full Photos access and unnecessary full Contacts access.

Granting an app access to your Photo library gives the app an enormous quantity of personal data. Our photos contain detailed information on places we’ve been and people we’ve seen going back many years. Apple provides [`UIImagePickerController`](https://developer.apple.com/documentation/uikit/uiimagepickercontroller) so users can pick photos via a system provided UI. This means apps can access photos without being granted full photo library access.

Unfortunately many apps seem to build their own image pickers that are, without exception, worse than `UIImagePickerController`. As well as requiring us to place great trust in an app by granting it full Photos access, some of these custom pickers have atrocious performance. For example, Hinge takes 22 seconds to load its image picker, and you have to sit through this for every single photo you add. `UIImagePickerController` loads in about one second. This is a fine line to tread, but perhaps apps could be required to use `UIImagePickerController` if their custom image pickers don’t add any value.

(**Edit:** I was surprised and delighted that photos privacy was addressed incredibly effectively by the [Limited Photos Library](https://developer.apple.com/wwdc20/10641) in iOS 14. Unfortunately as of June 2021, Slack hasn’t been updated to follow modern best practices for photo handling and seems confused when granted limited access.)

Similarly, I don’t want to give WhatsApp access to all my contacts, but the app requires this to create group chats. A [`CNContactPickerViewController`](https://developer.apple.com/documentation/contactsui/cncontactpickerviewcontroller) would work perfectly well without compromising privacy. I’m sure WhatsApp is not the only example of this malpractice. Again, it’s a fine line, but I hope Apple can find a way to leverage their influence here.

## And more

I have to stop to get this post out before WWDC kicks off. Last but not least, it would be awesome to see:

- External screen support on iPad (native size, non-mirroring)
- Xcode for iPad
- TestFlight automatic updates (**Edit:** This was not part of WWDC 2020 but was added in TestFlight 3.0 in November 2020.)
- [Blue selection highlights in table views](https://daringfireball.net/2019/05/vibrant_tapdown_states)

Most of all, I’m glad we have a WWDC this year, and I’ll be excited to see what’s new whatever it is. In some ways, not having the distraction of travelling to WWDC is making me even more excited about the shiny new things.

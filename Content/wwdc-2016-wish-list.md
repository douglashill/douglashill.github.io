title: iOS 10 and OS X 10.12 wish list
description: Here are some changes I would like to see in the next versions of Apple’s major platforms.
micro: I wrote up my wish list for iOS 10 and OS X 10.12. Synchronised notifications, tones, faster share sheet, and more.
date: 2016-05-30
time: 21:26:51+0000
tweet: 737394866859151360
%%%

Here are some user-facing changes I would like to see in the next versions of iOS and OS X, and across both platforms.

## Stop serial killers ##

I see so many people using their iPhones follow a clearly frequently rehearsed dance: double click the home button then flick, flick, flick the apps away until there are none left. I think people have some idea that all those apps are ‘running’ and using battery power, or maybe have a general notion that this is a good habit. It isn’t. Two things Apple is obsessed with are user experience and energy efficiency. They would be utterly incompetent if having the user manually terminate every app was a productive use of time. There are a few rare cases where targeted killing of a particular app may be beneficial, but indiscriminate, serial killing is a waste of time. Users doing this are punishing themselves because they have to wait for apps to relaunch, and hope state is restored fully. The current design of iOS doesn’t discourage this behaviour: it almost makes it fun. At the scale of the iPhone this is a terrible waste of human time. Apple should redesign how this process works to prevent misinformed users from wasting their time. (rdar://26407699, duplicate of rdar://9226204)

After I wrote the first draft of this article, I was extremely pleased to hear John Siracusa cover this topic very well in [Accidental Tech Podcast 170](http://atp.fm/episodes/170) at [around 1:27](https://overcast.fm/+CdSv9LfI/1:27:57).


## Synchronised notifications ##

I receive slightly different notifications on my iPhone, iPad and Mac. This means I sometimes check all three to make sure I have seen everything. Could we have **all our notifications on all our devices**? Check one and you know you’ve seen everything, even for apps not downloaded on that device. A disadvantage is that it would only be possible to open an app from a notification if the app is installed, which might be confusing. (rdar://26407715)

Apple offers fine-grained control over how notifications are delivered, which is great except there are *so many switches*. Making a broad change like disabling sounds for most apps can easily take hundreds of taps on each device. Could these screens be redesigned to allow **easier control of notifications settings**? A big Notification Centre on/off switch would help me a lot. An option to **sync notification preferences** might help, although I can see this would not work for some people because you might want, for example, sounds on iPhone but not on Mac. (rdar://26407733)

When an app asks for permission to send notifications, I usually tap the allow button, then immediately hop over to Settings and tweak things. (I like notifications silent and non-persistent.) This flow could be improved so there is a way to set things as you like without losing context. (rdar://26407748)

Being able to take phone calls on an iPad or Mac is handy, but the cacophony of out-of-time ringtones puts me on edge when taking a call. Imperfect timing is sloppy, even if timer coalescing is power efficient. I would like to see and hear **perfectly synchronised notification delivery** across devices, including ringing for calls. (rdar://26407761)

## Dynamic Type on OS X ##

*Dynamic Type* is the marketing name for the *Text Size* setting on iOS. In UIKit, this is called a *content size category*.

John Siracusa has been writing about [resolution independence on OS X](http://arstechnica.com/staff/2006/04/3720/) since [OS X 10.4 in 2005](http://arstechnica.com/apple/2005/04/macosx-10-4/20/#scalable-ui). Retina displays with the @2x, @3x system only meet some of the goals of resolution independence; making text sharper doesn’t help if eyesight is the bottleneck. Some people want text to be physically larger (or smaller).

We have layout constraints, resizable windows, and a familiar API on iOS. The technological stepping stones are in place: it’s time for Dynamic Type to come to OS X, so everyone can read text comfortably. (rdar://26407769)

## Dark mode ##

OS X sort of has a dark mode setting — it changes the menu bar and Dock — but there is no API for apps to access this. With Night Shift and the True Tone display, there is interest from iOS in adapting to the lighting of the environment. Maybe this year everything will come together. The hardware would detect if the environment is dark, and the system and apps would update appropriately. Federico Viticci included dark mode in his [iOS 10: Wishes article on MacStories](https://www.macstories.net/stories/ios-10-wishes/) and has some nice concept screen shots.

A few things need to happen to make this a reality:

- Dark mode setting on iOS, with an automatic option
- Automatic dark mode setting on OS X
- Dark mode API in UIKit and AppKit, which reads the system setting
- Changes to default theming in UIKit and AppKit, probably opt-in to avoid messing up existing apps
- Adoption of dark mode in Apple’s apps
- Adoption of dark mode in third-party apps

## Tones ##

Putting tones onto iOS devices is the one reason I connect them to iTunes on my Mac like it’s 2007. I guess nobody uses this feature so it is low on the iOS to-do list; I don’t blame anyone given how much of a hassle custom tones are. It would be nice be able to **add and delete custom tones on iOS without plugging into iTunes**. That would bring tones to the state-of-the-art about five years ago. The next step would be **syncing tones** using iCloud — and naturally part of this is having **custom tones on OS X**, which is currently not possible in FaceTime and Messages.

## OS X power management ##

If a Mac is plugged in, it should not stop doing things (like Xcode indexing) after some arbitrary user-specified time that the screen should turn off. Even when not plugged in, some things should happen when the lid is closed, like uploads (especially to iCloud). I would like to see power management on Macs that is more like iOS. Power Nap is a step in the right direction but does not seem to go far enough.

## TextEdit ##

If a document is open in TextEdit and it changes externally (such as from Dropbox) you see a confusing question about reverting. It would be nice to have **automatic refresh on file changes** if there are no conflicts (and there aren’t usually conflicts because of automatic saving.)

TextEdit can detect URLs and make them clickable, but it only does this when text is inserted after the URL. I spend quite a bit of time deleting and reinserting the space or new line after URLs to make them clickable. This could be fixed with **proper URL detection**.

(Yes, I know: just add my two features, but make sure it stays simple. Surely nobody else could have their two different features. 😄)

## Other little iOS things ##

The iOS share sheet is the only good way for apps to work together (using *Extensions*). It’s a crucial component of the system — and it is slow to appear. Tap a share button and think how many cycles a gigahertz processor can do before the sheet appears. The delay is obviously more noticeable on older devices. There shouldn’t be any perceivable delay between lifting off the button and the sheet appearing, so I hope Apple can **make the share sheet appear faster**.

Rearranging apps on the iOS home screens is really clunky. We’re so used to it by now a more dramatic reimagining seems unlikely.  Dragging items to the side to change pages is especially clumsy, especially in folders. With screens getting larger, this could be much better without breaking this existing paradigm by allowing **multitouch home screen rearrangement**, so you can pick up an app with one finger and change pages with the other hand, or even grab a couple of apps at once with two fingers.

I find the **iPad keyboard trackpad mode** often causes what I call *text clobbering*, where the last word typed is selected then overwritten, which is very annoying. I would welcome any improvements here, even if it means an option to disable this feature.

It would be nice if the remaining first party apps (Settings and the Stores) were updated for Split View and Slide Over.

- - - - - - - - - -

It’s quite possible that none of these things will happen this year — or ever. One can hope. In any case, I’m sure there will be plenty of cool new features and fixes. Let’s see what WWDC 2016 brings!

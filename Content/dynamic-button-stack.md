title: DynamicButtonStack
subtitle: Motivation and design details
date: 2020-04-12
time: 12:15:10+0000
%%%

In this article, I’ll discuss the problems solved by, and the design principles behind, my small open source project [DynamicButtonStack](https://github.com/douglashill/DynamicButtonStack).

Typically when a range of action buttons are presented to the user in an iOS app, the buttons are either stacked horizontally in a toolbar or vertically in a scrolling list.

## Horizontal stacks

The problem with toolbar-like layouts is there is limited space to grow. Bars are typically given a limited amount of height so that they don’t take too much space away from the main content area.

Icons on buttons help with fast recognition, but the meaning of icons can be unclear. On the other hand, button titles can clearly explain what the button does, but are harder to scan. Toolbar buttons usually have to pick between either an icon or a title because there is insufficient space for both.

When button titles are used, space can be limited with certain localisations, which can encourage the use of abbreviations or other terms that are shorter and not as clear. For example many words require more space in German compared to other languages.

Perhaps worst of all, in a toolbar there is no space to accommodate users who prefer larger text and icons. This was well put in this [tweet from Marc Palmer](https://twitter.com/marcpalmerdev/status/1227928899746705408):

> There are a lot of people in the middle ground between VoiceOver users and default text size users who are IMO not well served by current UI design patterns where key UI elements don’t scale.

To address this to some extent, Apple created the Large Content Viewer. When the system text size is set to an accessibility size, an overlay showing a large icon and text label appears in the middle of the screen when the user holds down on a button. You can learn more about it in [WWDC 2019 session 261: Large Content Viewer - Ensuring Readability for Everyone](https://developer.apple.com/wwdc19/261). However, as discussed in this session, making content readable to begin with is preferred over relying on the Large Content Viewer.

## Vertical stacks

Showing buttons in a vertically scrolling list solves the space problem of toolbars. We can use contextual menus or `UITableView` with [self-sizing cells](https://pspdfkit.com/blog/2018/self-sizing-table-view-cells/) to get unlimited space. More content just means more scrolling. The downside is that showing a menu like this typically involves a screen transition. It is a much more heavyweight interaction compared to tapping an item in a toolbar.

In situation where a vertical stack of buttons can be shown inline with other content, it may take up more space than needed for a small number of actions.

## Dynamic stacks

Hybrids of horizontal and vertical stacks of buttons are showing up in Apple’s apps. Maps uses one on the place details screen. It has three layout modes: fitting three, two and one button across the width respectively. This scales pretty well, although the ‘Add to…’ title is truncated in German at the largest text size.

![Composite screenshot of the Maps app showing the Call, Add to… and Share buttons.](maps.png)

The iOS 13 Mail app shows the first four buttons in its reply/actions sheet in either a two-by-two grid or a vertical stack.

![Composite screenshot of the Mail app showing the Reply, Reply All, Forward, Delete, Flag etc. buttons.](mail.png)

I took a somewhat similar approach in my [reading app](/reading-app/). The app is designed to provide a stable and focused environment for reading. I did not want either an anchored toolbar on the reading screen, or to require the user to tap to show and hide bars. The reading screen is for reading. Buttons for taking actions on an article are only shown at the end of the article, in the content area.

![Screenshot of reading app on iPad. It shows two columns of text. The article is from the Dark Sky Blog. There are three buttons are at the bottom of the right-hand column: Open in Safari, Share, and Delete.](reading-app.png)

## DynamicButtonStack

With [DynamicButtonStack](https://github.com/douglashill/DynamicButtonStack), I’ve extracted my implementation of hybrid button stacking from my app. Depending on the content to be displayed and the space available, the button stack dynamically switches its layout. This means it can be highly compact if possible, but it will take up as much space as needed to ensure usability.

DynamicButtonStack has four layout modes, from most vertically compact to least vertically compact:

![Composite screenshot of the four layout modes. The first mode uses small text and shows buttons horizontally stacked with the icon and title horizontally stacked within each button. The second mode shows buttons horizontally stacked with the icon and title vertically stacked within each button. The third mode shows buttons vertically stacked with the icon and title horizontally stacked within each button. The fourth mode uses large text and shows buttons vertically stacked with the icon and title vertically stacked within each button.](text-size.png)

You can add as many buttons as you like. As well as dealing with any text size, it’s ready for localisation, including handling right-to-left layouts:

![Composite screenshot of DynamicButtonStack in various languages. Chinese, English, German, Arabic.](localistion.png)

## Design details

### Give the content as much space as it needs

DynamicButtonStack is intended to be used in a scrollable area, so conserving space is not a goal. The stack will calculate the smallest possible size for its buttons *given that readability is not compromised*.

### Image and title

Since saving space is not a goal, all buttons include both an icon and a title to provide the best of both worlds with comprehension and fast recognition.

### Don’t stretch the layout

When given more space than it requires, DynamicButtonStack will more comfortably fill the space by using a more expanded layout rather than stretching the most compact layout that fits.

![On the left, three very tall buttons are stacked horizontally. On the right, three buttons are shown occupying the same size but stacked vertically to better fill the space. There is a red cross on the left and a green tick on the right.](stretch.png)

### Regular rhythm

All buttons are laid out the same way. If one button requires the image and title to be vertically stacked, then all buttons will be stacked that way.

Unlike Apple Maps, the buttons won’t use horizontal stacking with wrapping. Instead it will switch to vertical stacking.

### Alignment

The icons and titles are always aligned in a regular way that aids the eye in scanning. You can see this in the third layout mode, where the icons are all centred on a vertical line, and so are the leading edges of the titles. ([The iOS contextual menus and share sheet ought to work like this too.](/menu-icon-swizzling/))

### Define layout, not appearance

DynamicButtonStack deals with layout, but is hands off about all other aspects of the button appearance. Apps using DynamicButtonStack can make the buttons in the stack look as they like. Flat, skeuomorphic, neumorphic — it’s up to you.

---

I’d love to hear feedback about this project. You can find [DynamicButtonStack on GitHub](https://github.com/douglashill/DynamicButtonStack), or [let me know what you think](/follow/).

title: Localisation using Apple’s glossaries
description: How I localised KeyboardKit into 39 languages without needing translators.
date: 2020-03-28T21:10:48+0000
%%%

Users of Apple platforms benefit when apps and the system use consistent terminology. However Apple’s SDKs do not provide a convenient way to access user interface text from the system at runtime. Therefore apps typically provide their own UI text for common action names, and if the app is localised then this text is translated from scratch. Translation is likely to be expensive, and translators need to take care to match the Apple system text otherwise the terminology used may end up being inconsistent.

Apple provides all their system translations in localisation glossaries, which are available to [download from the developer website](https://developer.apple.com/download/more/) (search for ‘glossaries’). For most apps these glossaries will contain some fraction of the app’s localisable text. Think about common terms like OK, Cancel, Close, Delete, Refresh, Back, Settings, Untitled or Open in Safari.

My open source [KeyboardKit](https://github.com/douglashill/KeyboardKit) framework makes it easy to add hardware [keyboard control](/keyboard-control/) to iOS and Mac Catalyst apps. To aid discoverability, it’s important for key commands provided by an app to have user-facing titles. Due to the nature of KeyboardKit, *all* key command titles needed by the framework already exist somewhere in either iOS or macOS so can be found in the glossaries. Also since this is an open source project with no revenue, paying for professional translation is not a desirable option.

By leveraging Apple’s glossaries, [I localised KeyboardKit into 39 languages](https://github.com/douglashill/KeyboardKit/pull/6). This was done without using professional translators, although it did take quite a lot of my own time. In this article, I’ll walk though how I achieved this.

![Screenshot of iPad keyboard discoverability overlay localised into Spanish (Latin America)](es-419.png)

## Parsing the glossaries

Glossary-based localisation used to be possible using a tool from Apple called AppleGlot. I learned about this from this article by [Dorin Danciu on AppleGlot 4](https://blog.dorindanciu.com/posts/appleglot), which links to the [*Localizing Strings Files Using AppleGlot* section in Apple’s archived *Internationalization and Localization Guide*](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPInternational/MaintaingYourOwnStringsFiles/MaintaingYourOwnStringsFiles.html#//apple_ref/doc/uid/10000171i-CH19-SW22). However the AppleGlot installer certificate expired last October. Beyond that, it isn’t compatible with Catalina because it installs private system frameworks, which isn’t possible with Catalina’s read-only system volume.

![Screenshot of Installer on Mac. The text reads: Install AppleGlot v4. This package is incompatible with this version of macOS.](AppleGlot-Catalina.png)

That’s a setback, but surely AppleGlot can’t be magic. What’s inside one of these localisation glossaries? Here is the top of `UIKitCore.lg`:

<pre><code class="hljs"><span class="hljs-meta">&lt;?xml version="1.0" encoding="UTF-8"?&gt;</span>
<span class="hljs-tag">&lt;<span class="hljs-name">Proj</span>&gt;</span>
  <span class="hljs-tag">&lt;<span class="hljs-name">ProjName</span>&gt;</span>UIKitCore<span class="hljs-tag">&lt;/<span class="hljs-name">ProjName</span>&gt;</span>
  <span class="hljs-tag">&lt;<span class="hljs-name">File</span>&gt;</span>
    <span class="hljs-tag">&lt;<span class="hljs-name">Filepath</span>&gt;</span>UIKitCore/System/iOSSupport/System/Library/PrivateFrameworks/UIKitCore.framework/Versions/A/Resources/English.lproj/Localizable.strings<span class="hljs-tag">&lt;/<span class="hljs-name">Filepath</span>&gt;</span>
    <span class="hljs-tag">&lt;<span class="hljs-name">TextItem</span>&gt;</span>
      <span class="hljs-tag">&lt;<span class="hljs-name">Description</span>&gt;</span> File Upload alert sheet button string for choosing an existing media item from the Photo Library <span class="hljs-tag">&lt;/<span class="hljs-name">Description</span>&gt;</span>
      <span class="hljs-tag">&lt;<span class="hljs-name">Position</span>&gt;</span>Photo Library<span class="hljs-tag">&lt;/<span class="hljs-name">Position</span>&gt;</span>
      <span class="hljs-tag">&lt;<span class="hljs-name">TranslationSet</span>&gt;</span>
        <span class="hljs-tag">&lt;<span class="hljs-name">base</span> <span class="hljs-attr">loc</span>=<span class="hljs-string">"en"</span>&gt;</span>Photo Library<span class="hljs-tag">&lt;/<span class="hljs-name">base</span>&gt;</span>
        <span class="hljs-tag">&lt;<span class="hljs-name">tran</span> <span class="hljs-attr">loc</span>=<span class="hljs-string">"de"</span>&gt;</span>Fotomediathek<span class="hljs-tag">&lt;/<span class="hljs-name">tran</span>&gt;</span>
      <span class="hljs-tag">&lt;/<span class="hljs-name">TranslationSet</span>&gt;</span>
    <span class="hljs-tag">&lt;/<span class="hljs-name">TextItem</span>&gt;</span>
    <span class="hljs-tag">&lt;<span class="hljs-name">TextItem</span>&gt;</span>
      <span class="hljs-tag">&lt;<span class="hljs-name">Description</span>&gt;</span> Recents section in the font picker <span class="hljs-tag">&lt;/<span class="hljs-name">Description</span>&gt;</span>
      <span class="hljs-tag">&lt;<span class="hljs-name">Position</span>&gt;</span>FONT_PICKER_RECENTS<span class="hljs-tag">&lt;/<span class="hljs-name">Position</span>&gt;</span>
      <span class="hljs-tag">&lt;<span class="hljs-name">TranslationSet</span>&gt;</span>
        <span class="hljs-tag">&lt;<span class="hljs-name">base</span> <span class="hljs-attr">loc</span>=<span class="hljs-string">"en"</span>&gt;</span>Recents<span class="hljs-tag">&lt;/<span class="hljs-name">base</span>&gt;</span>
        <span class="hljs-tag">&lt;<span class="hljs-name">tran</span> <span class="hljs-attr">loc</span>=<span class="hljs-string">"de"</span>&gt;</span>Letzte<span class="hljs-tag">&lt;/<span class="hljs-name">tran</span>&gt;</span>
      <span class="hljs-tag">&lt;/<span class="hljs-name">TranslationSet</span>&gt;</span>
    <span class="hljs-tag">&lt;/<span class="hljs-name">TextItem</span>&gt;</span>
    <span class="hljs-tag">&lt;<span class="hljs-name">TextItem</span>&gt;</span>
      <span class="hljs-tag">&lt;<span class="hljs-name">Description</span>&gt;</span> Recents button in tab bar <span class="hljs-tag">&lt;/<span class="hljs-name">Description</span>&gt;</span>
      <span class="hljs-tag">&lt;<span class="hljs-name">Position</span>&gt;</span>Recents<span class="hljs-tag">&lt;/<span class="hljs-name">Position</span>&gt;</span>
      <span class="hljs-tag">&lt;<span class="hljs-name">TranslationSet</span>&gt;</span>
        <span class="hljs-tag">&lt;<span class="hljs-name">base</span> <span class="hljs-attr">loc</span>=<span class="hljs-string">"en"</span>&gt;</span>Recents<span class="hljs-tag">&lt;/<span class="hljs-name">base</span>&gt;</span>
        <span class="hljs-tag">&lt;<span class="hljs-name">tran</span> <span class="hljs-attr">loc</span>=<span class="hljs-string">"de"</span>&gt;</span>Verlauf<span class="hljs-tag">&lt;/<span class="hljs-name">tran</span>&gt;</span>
      <span class="hljs-tag">&lt;/<span class="hljs-name">TranslationSet</span>&gt;</span>
    <span class="hljs-tag">&lt;/<span class="hljs-name">TextItem</span>&gt;</span>
</code></pre>

It’s a relatively easy to understand XML format. I wrote a crude parser for the `.lg` files using macOS Foundation’s [`XMLDocument`](https://developer.apple.com/documentation/foundation/xmldocument) to extract the needed information into a Swift `struct` like this:

<pre><code class="hljs"><span class="hljs-class"><span class="hljs-keyword">struct</span> <span class="hljs-title">LocalisationEntry</span> </span>{
    <span class="hljs-comment">/// The file where the entry was read from.</span>
    <span class="hljs-keyword">let</span> fileURL: <span class="hljs-type">URL</span>
    <span class="hljs-comment">/// The usage description to help with translation.</span>
    <span class="hljs-keyword">let</span> comment: <span class="hljs-type">String?</span>
    <span class="hljs-comment">/// The key to look up this string. This is may be &lt;NO KEY&gt; because some Apple strings files use just whitespace as a key and NSXMLDocument can not read whitespace-only text elements.</span>
    <span class="hljs-keyword">let</span> key: <span class="hljs-type">String</span>
    <span class="hljs-comment">/// The English text.</span>
    <span class="hljs-keyword">let</span> base: <span class="hljs-type">String</span>
    <span class="hljs-comment">/// The localised text.</span>
    <span class="hljs-keyword">let</span> translation: <span class="hljs-type">String</span>
}
</code></pre>

## Finding translations

The same English text will be localised in many different places. Many of these will have the same translated text, but some will have different translations because the text may be used in a different context, such as both *Letzte* and *Verlauf* for *Recents* above.

I tried two approaches to deal with there being multiple matches in Apple’s glossaries for given English text:

- Specifying a particular key that Apple uses. For example, whether we want `Recents` or `FONT_PICKER_RECENTS`.
- Finding the most common translation for any given English text, without considering the context where the text is used.

We’ll get back to these two approaches later. Before that, I used the first script I wrote to explore the possible translations. For this exploratory stage, it’s fine to just download glossaries for one language. I used German because I can understand it a little bit. I downloaded both the iOS and macOS glossary DMGs.

Generally, I didn’t know which glossary file would be best to look in, so I used my script to find all matching English text and print all the possible translations, including their key. The usage comment may also be useful although that would bloat the script output. I then selected one that looked appropriate. Here’s some example output of the script:

    ✅ Read 367123 localisation entries.
    ✅ There are 144708 unique English strings.

    scrollView_zoomOut = Zoom Out

    Verkleinern ZOOM_OUT                         AssistiveTouch.lg
    Verkleinern MAP_SETTING_ZOOM_OUT             GreenTorch.lg
    Verkleinern Zoom Out [tv]                    MapKit.lg
    Verkleinern 1704.title                       AirPortUtility.lg
    Verkleinern 564.title                        AssistiveControl.lg
    Verkleinern Zoom Out                         ColorSyncUtility.lg
    Kleiner     ZOOMOUT_TOOLBARITEM_LABEL        GraphingCalculator.lg
    Kleiner     ZOOMOUT_TOOLBARITEM_PALETTELABEL GraphingCalculator.lg
    Kleiner     ZOOMOUT_TOOLBARITEM_TOOLTIP      GraphingCalculator.lg
    Kleiner     1437.title                       GraphingCalculator.lg
    Kleiner     1752.title                       GraphingCalculator.lg
    Kleiner     1802.title                       GraphingCalculator.lg
    Verkleinern MAP_SETTING_ZOOM_OUT             GreenTorch.lg
    Verkleinern 737.title                        iBooks.lg
    Verkleinern Zoom Out                         MapKit.lg
    Verkleinern Zoom Out [tv]                    MapKit_iosmac.lg
    Verkleinern 1081.title                       Maps.lg
    Verkleinern fFD-ku-8kU.title                 Notes.lg
    Verkleinern Zoom Out                         PDFKit.lg
    Verkleinern Zoom Out                         PDFKit_iosmac.lg
    Verkleinern K6I-xK-DjR.title                 Photos_Apps.lg
    Verkleinern PXLibraryAllPhotosZoomOut        Photos_Apps.lg
    Verkleinern PXLibraryAllPhotosZoomOut        Photos_iosmac.lg
    Verkleinern Zoom Out                         Preview.lg
    Verkleinern 220.title                        Preview.lg
    Verkleinern Zoom Out                         Stocks.lg
    Verkleinern 898.title                        TextEdit.lg
    Verkleinern 439.title                        WebBrowser.lg
    Verkleinern Zoom Out (menu item)             WebBrowser.lg

The full script is available as [explore-localisation-glossaries.swift](https://gist.github.com/douglashill/7d8ef0b5e1ae2e95e02a30c129aaf4de).

## Extracting translations

The consistency and accuracy of translations depends on how consistent Apple is and how well you pick the source text. It was important to pick a match from the possible localisations where the context Apple uses the text in and the context KeyboardKit uses the text are as similar as possible. I picked what seemed best in each case and made a table of each key needed and the glossary that key comes from. These will be used by the second script, which will generate initial `.strings` files for all localisations. Here’s an excerpt of the table in the second script:

<pre><code class="hljs"><span class="hljs-comment">/// A localised strings entry that we want to extract from Apple’s glossary files.</span>
<span class="hljs-class"><span class="hljs-keyword">struct</span> <span class="hljs-title">NeededLocalisation</span> </span>{
    <span class="hljs-comment">/// The key to use in the generated KeyboardKit .strings file.</span>
    <span class="hljs-keyword">let</span> targetKey: <span class="hljs-type">String</span>
    <span class="hljs-comment">/// The key (AKA Position) that Apple uses in their glossary.</span>
    <span class="hljs-keyword">let</span> appleKey: <span class="hljs-type">String</span>
    <span class="hljs-comment">/// The file base name of the glossary file in which this localisation can be found. I.e. the filename is glossaryFilename.lg.</span>
    <span class="hljs-keyword">let</span> glossaryFilename: <span class="hljs-type">String</span>
}

<span class="hljs-keyword">let</span> neededLocalisations = [
   <span class="hljs-attribute"> NeededLocalisation</span>(targetKey: <span class="hljs-string">"app_newWindow"</span>,          appleKey: <span class="hljs-string">"fluid.switcher.plus.button.label"</span>, glossaryFilename: <span class="hljs-string">"AccessibilityBundles"</span>),
   <span class="hljs-attribute"> NeededLocalisation</span>(targetKey: <span class="hljs-string">"app_settings"</span>,           appleKey: <span class="hljs-string">"Settings"</span>,                         glossaryFilename: <span class="hljs-string">"MobileNotes"</span>         ),
    <span class="hljs-comment">// UIKit is inconsistent here. It uses "Share" for the accessibility label, but "Action" for the large content viewer.</span>
   <span class="hljs-attribute"> NeededLocalisation</span>(targetKey: <span class="hljs-string">"barButton_action"</span>,       appleKey: <span class="hljs-string">"Share"</span>,                            glossaryFilename: <span class="hljs-string">"UIKitCore"</span>           ),
.<span class="hljs-literal"></span>.<span class="hljs-attribute"></span>.<span class="hljs-attribute"></span>
   <span class="hljs-attribute"> NeededLocalisation</span>(targetKey: <span class="hljs-string">"scrollView_zoomIn"</span>,      appleKey: <span class="hljs-string">"438.title"</span>,                        glossaryFilename: <span class="hljs-string">"WebBrowser"</span>          ),
   <span class="hljs-attribute"> NeededLocalisation</span>(targetKey: <span class="hljs-string">"scrollView_zoomOut"</span>,     appleKey: <span class="hljs-string">"439.title"</span>,                        glossaryFilename: <span class="hljs-string">"WebBrowser"</span>          ),
   <span class="hljs-attribute"> NeededLocalisation</span>(targetKey: <span class="hljs-string">"scrollView_zoomReset"</span>,   appleKey: <span class="hljs-string">"863.title"</span>,                        glossaryFilename: <span class="hljs-string">"WebBrowser"</span>          ),
   <span class="hljs-attribute"> NeededLocalisation</span>(targetKey: <span class="hljs-string">"window_close"</span>,           appleKey: <span class="hljs-string">"Close Window"</span>,                     glossaryFilename: <span class="hljs-string">"AppKit"</span>              ),
   <span class="hljs-attribute"> NeededLocalisation</span>(targetKey: <span class="hljs-string">"window_cycle"</span>,           appleKey: <span class="hljs-string">"Cycle Through Windows"</span>,            glossaryFilename: <span class="hljs-string">"AppKit"</span>              ),
]
</code></pre>

With all the input data ready, it was time to generate the initial `.strings` files.

I downloaded the remaining iOS and macOS localisation glossaries from Apple. Each download needs to be authenticated, so I found I needed to click on each link and wait a second for the download to actually start before clicking on the next link. I didn’t find a way to automate this. Then I mounted all the disk images. This was surprisingly challenging because DiskImageMounter would lock up if I tried to open twenty or forty DMGs at once. I found opening in batches of around fifteen worked. This disk image setup is rough. I wish Apple would provide a single zip file containing all their glossaries (or at least a single zip file for each platform).

With the glossaries mounted in the filesystem, I ran the second script to extract the translations. The full script is available as [extract-specific-localised-strings.swift](https://gist.github.com/douglashill/c5b08a9099883475294d27cecc56ec29).

## Manual editing

The next step was to manually audit the generated translations. My main reference was putting a device in the language being translated and seeing what text was used by the system and Apple’s apps. The new Voice Control accessibility feature with the setting enabled to always show names was really useful to see button labels. It’s a bit like having the Accessibility Inspector on your device.

![Screenshot of the Mail app on iPad showing labels in Finnish.](Voice-Control.png)

I found my translations needed some improvements. Some didn’t match the text displayed by iOS. Some actions were inconsistent in form, such as mixing verbs and nouns. It looks like Apple’s glossary files contain many sets of translations for the set of `UIBarButtonSystemItem`s and they’re not consistent. You can see this even in English: the large content title for `UIBarButtonSystemItemAction` is *Action* while the accessibility label is *Share*. I tried adjusting the keys the second script was using, but it became clear there is no clear superior source in the Apple translations. How do you pick between `button.done` and `done.button` when they’re described in much the same way in the glossary file?

This is where the third script came into play. It’s similar to the second script except it looks in all glossary files and generates `.strings` files based on the most common translation for each English text. This approach will give poor translations on its own, but is useful as a way to distil the vast quantity of information in Apple’s glossary files into something more digestible.

I was therefore able to [improve the translations](https://github.com/douglashill/KeyboardKit/pull/7) by manually editing all the `.strings` files and considering:

- The translations from looking up specific keys (the second script).
- The most common translations across Apple’s strings files (the third script).
- Text used by iOS and system apps, especially the bar button item accessibility labels.
- Words looked up in dictionaries.

The manual editing was a considerable time investment. I found this process incredibly interesting, but if you don’t then you should probably hire translators! That said, I believe combining these sources of information with good judgment should have resulted in pretty decent translations. If you notice anything you think could be improved I’m [open to suggestions](https://github.com/douglashill/KeyboardKit/pulls).

![Screenshot of iPad keyboard discoverability overlay localised into Japanese](ja.png)

## Summary

- [KeyboardKit](https://github.com/douglashill/KeyboardKit) is now localised into 39 languages! 🎉
- This was achieved by leveraging the glossary files Apple provides, which contain all the translations used by iOS, macOS, tvOS and watchOS.
- [explore-localisation-glossaries.swift](https://gist.github.com/douglashill/7d8ef0b5e1ae2e95e02a30c129aaf4de) was used to look at all glossary files in a particular localisation to find appropriate Apple translations to use.
- [extract-specific-localised-strings.swift](https://gist.github.com/douglashill/c5b08a9099883475294d27cecc56ec29) was used to read particular glossary files across all localisations and generate `.strings` files.
- [extract-most-common-localised-strings.swift](https://gist.github.com/douglashill/54a138f3de68790c29112b9d8a1fac9a) was used to read the most common translations from the glossary files as an additional source of information.
- To create higher quality localisations, a significant amount of time was spent manually editing the translations by combining various source of information.

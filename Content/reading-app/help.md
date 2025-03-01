title: [Reading app](/reading-app/) help
description: Frequently asked questions (FAQ) about Reading.
%%%

This page answers some frequently asked questions (FAQ) about [Reading](../).

- [Adding articles](#add)
- [Deleting articles](#delete)
- [Changing the appearance when reading articles](#appearance)
- [Exporting to PDF](#export-pdf)
- [Automating with Shortcuts](#shortcuts)
- [Feedback](#feedback)

<h2 id="add">Adding articles</h2>

You can add links or text using the share sheet, copy and paste, drag and drop, or the Shortcuts app.

### Share sheet

1. When viewing an article in Safari, tap the share button to show the share sheet.
2. Tap the yellow Reading icon in the row of app icons. If you don’t see the yellow Reading icon in the share sheet, scroll to the end of the row of app icons, tap More, tap Edit, and enable Reading.

In many apps (including Safari), you can also show the share sheet by long pressing on links and then tapping “Share…” in the menu.

Another option is to add any text by selecting the text and then tapping “Share…” in the menu.

### Copy and paste

1. Copy a link or text in another app. In many apps, you can do this by long pressing to show a menu and selecting Copy.
2. Paste that link or text into Reading by long pressing in the articles list to show a menu and selecting Paste.

You can also copy and paste by “pinching” and “spreading” with three fingers or with command + C and command + V if you’re using a hardware keyboard.

### Drag and drop

1. Use a long press to drag links and text from other apps
2. Drop them in the articles list.

Drag and drop is easiest when viewing multiple apps at once on iPad, but it is also possible on iPhone by using a second finger to switch apps while dragging.

### Shortcuts

This is a more advanced option if you’re interested in integrating with other apps or creating automated workflows. Pass a URL or some text to the “Add Article” action. Shortcuts actions are available on iOS 16 or later.

<h3 id="websites-that-require-signing-in">Websites that require signing in</h3>

By default, no saved data (cookies) are sent to websites when saving articles. This is similar to private browsing in Safari, and makes it more difficult for website owners to track you. Signing into websites removes this privacy protection in Reading when saving articles from those specific websites, but is necessary for websites with paywalls.

When saving using the share sheet in Safari, the webpage will be saved as you see it without loading the text again. This means you can save the full text for websites that have a paywall or otherwise require signing in to see the content by following these steps:

1. Open the article webpage in Safari and make sure you’re signed in
2. Tap the share button in Safari’s toolbar
3. Tap Reading in the row of app icons in the share sheet

When saving articles in any other way, you can sign into websites in Reading like this:

1. On iPad, tap Settings in the sidebar. On iPhone, tap the back button from the list of articles and then tap Settings.
2. Tap Sign in to Websites
3. Tap +
4. Enter the website address (URL)
5. Sign into the website
6. Tap Done

The list of Saved Websites in Reading shows all websites with saved cookies. This may include subdomains. For example, if you sign into website.com, cookies may also be saved for myaccount.website.com.

You can remove saved cookies with swipe-to-delete in the Saved Websites list.

<h2 id="delete">Deleting articles</h2>

Delete articles in the app by any of the following means:

- In the articles list, long press on an article to show the menu, and then tap delete.
- In the articles list, swipe from right to left on an article.
- When reaching the end of an article on the reading screen, tap the Delete button.
- Advanced: Using the “Delete Articles” action in Shortcuts.

Deleted articles will still be available in the “Recently Deleted” list for one week. From this list, you can long press on an article to show the menu to restore (“un-delete”) the article or immediately delete it.

<h2 id="appearance">Changing the appearance when reading articles</h2>

You can use a light or dark appearance, change the text size, and switch between a serif and sans serif typeface.

iOS system settings are used to set a light or dark appearance and the text size. Change these settings from Control Center or in the Settings app. To learn more, please see Apple’s help pages on [Dark Mode](https://support.apple.com/en-us/HT210332), [changing text size](https://support.apple.com/en-us/HT202828), and on Control Center for [iPad](https://support.apple.com/en-us/HT210974) and [iPhone](https://support.apple.com/en-us/HT202769).

Larger accessibility text sizes are supported.

You can select either the system serif font (New York) or the standard system font (San Francisco) from the settings screen in Reading. On iPad, tap Settings in the sidebar. On iPhone, tap the back button from the list of articles and then tap Settings.

<h2 id="export-pdf">Exporting to PDF</h2>

To create PDF screenshots of articles:

1. In Reading, open the article you’d like to export to PDF.
2. Take a screenshot. To learn more, please see Apple’s help pages on taking screenshots on [iPad](https://support.apple.com/en-us/HT210781) and [iPhone](https://support.apple.com/en-us/HT200289).
3. Tap the screenshot thumbnail that appears in the corner of the screen.
4. Tap the “Full Page” tab at the top of the screen.
5. Tap “Done” or the share button to save the PDF or send it somewhere.

Exporting to PDF will preserve the article as you see it, so for example changing the text size or rotating your device can result in different pages sizes and numbers of columns of text. PDFs will always be saved with black text on a white background, even when in Dark Mode. Links (both web links and internal links) will be preserved in the PDF.

<h2 id="shortcuts">Automating with Shortcuts</h2>

You can use Apple’s Shortcuts app to automate workflows and perform advanced searches. Shortcuts actions for Reading require iOS 16 or later.

### Add Articles

Saves webpages or text snippets as articles in Reading. Optionally opens the first article to read immediately. Must be passed the webpage URLs or text snippets to add.

### Delete Articles

Deletes the specified articles. The articles will temporarily remain available in Recently Deleted.

### Find Articles

Searches for articles in the app that match the given criteria. Articles can be filtered and sorted using these properties:

- Author
- Date Saved
- Date Updated
- Excerpt
- Publication
- Storage Size
- Title
- URL
- Word Count

If articles are passed into this action, then the action will filter/sort from these specified articles rather than from all saved articles.

To filter for a certain property being missing or not missing (e.g. to search for text snippets by filtering for articles with no URL) you can use the following special terms as your filter text: “None”, “Nil”, “Null”. (It doesn’t matter if you use uppercase or lowercase letters in these terms.)

The properties listed above can also be read by other actions when the resulting articles are used as a variable.

### Get Body of Article

Gets the full text of a specified article as rich text. Images in articles are not supported and will be removed from the output.

### Open Article

Opens a specific article in Reading.

<h2 id="feedback">Feedback</h2>

If you have any feedback, please get in touch:

<ul>
<script type="text/javascript">
//<![CDATA[
<!--
var x="function f(x){var i,o=\"\",l=x.length;for(i=l-1;i>=0;i--) {try{o+=x.c" +
"harAt(i);}catch(e){}}return o;}f(\")\\\"function f(x,y){var i,o=\\\"\\\\\\\""+
"\\\\,l=x.length;for(i=0;i<l;i++){if(i<13)y++;y%=127;o+=String.fromCharCode(" +
"x.charCodeAt(i)^(y++));}return o;}f(\\\"\\\\j\\\\\\\\177qa{}th0WPMRBDG\\\\\\"+
"\\002\\\\\\\\t\\\\\\\\020AG\\\\\\\\021\\\\\\\\014P\\\\\\\\022[FPP\\\\\\\\nd" +
"\\\\\\\\033WZUQJPz)'/(*\\\\\\\\006#'<-'->&&<=|0;\\\\\\\\tti\\\\\\\\0354;20a" +
"q>^]M\\\\\\\\017\\\\\\\\r[DNSYQ\\\"\\\\,13)\\\"(f};)lo,0(rtsbus.o nruter};)" +
"i(tArahc.x=+o{)--i;0=>i;1-l=i(rof}}{)e(hctac};l=+l;x=+x{yrt{)49=!)31/l(tAed" +
"oCrahc.x(elihw;lo=l,htgnel.x=lo,\\\"\\\"=o,i rav{)x(f noitcnuf\")"           ;
while(x=eval(x));
//-->
//]]>
</script>
</ul>

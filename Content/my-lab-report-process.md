title: My lab report process
description: I’ve developed a somewhat unusual process for writing university lab experiment reports.
date: 2011-02-13
time: 14:58:00+0000
tumblr: 3272400046
%%%

In the third year of the [Engineering Tripos][ET], we do four or five laboratory experiments in each of the first two terms (Michaelmas and Lent). Reports must be written after doing these experiments. I have developed a somewhat unusual process for writing these reports.

The report goes through four different formats:

1. Markdown
2. HTML
3. Pages (iWork)
4. PDF and print

## Writing in Markdown ##

The first stage is writing. I do this in [Markdown][M], which is very close to plain text. I start from an outline, which I expand into a first draft. I edit this until almost all the text content of the report is satisfactory.

My choice tool for this is [Notational Velocity][NV]. In theory I could also do some of the work in [Simplenote][S]; in practice I do not do this.

This stage works very well. It’s so easy to throw thoughts into Notational Velocity: almost friction-free. There is no need to worry about saving or where to put a ‘file’. My work is extremely safe, since it is backed up to Google run servers approximately every seven seconds. I can’t be distracted by text and page formatting either.

Links to figures can be put in at this stage. (But you can’t create images using Notational Velocity, of course!)

## Markdown to HTML ##

Next, I use John Gruber’s Markdown Perl script to convert the plain text to HTML. I usually do this by copying the full text from Notational Velocity and then running this shell command from the same directory as the Markdown script:

	pbpaste | ./Markdown.pl -> report.html

## HTML to Pages ##

I open the HTML file in Safari. Fix the text encoding by specifying an encoding in the HTML file or by setting the encoding with the menu command View > Text Encoding > Unicode (UFT-8).

Select all, then copy and paste into a [Pages][P] document in word processing mode.

## Pages ##

In Pages, I fine tune the style and layout. Specifically:

- Fonts
	- Set sizes
	- Set typefaces
- Content
	- Final editing of text
	- Add tables
- Title Page
- Footer
- Page Layout
	- Set margins
	- Insert manual page breaks

The first thing to be done after putting the report in Pages is to set a smaller font. The HTML page comes out at 16 pt, the default size. I want 10 or 11 pt for printed pages.

Setting font styles is more difficult than it ought to be. If you want to use Pages’ styles (so you can tweak the font for all headings at once for example) then it is necessary to manually apply styles. It would be wonderful if Pages would, for example, recognise all `h1` elements as the style called title, `h2`s as heading and `h3`s as sub-heading. (Note: I am still using iWork ’08. I was really hoping for ’10 and now where’s ’11?)

Much could probably be done in just HTML and CSS by adding a print stylesheet to the HTML file. I haven’t made such a stylesheet yet, or looked into print stylesheets at all. (How do I set margins at the top and bottom of pages?) A critical part of putting the report into Pages is that the footer is added at this stage. (My name, document title, page number.) I don’t know if this is possible with HTML and CSS.

## Finally: PDF and print ##

Finish off by exporting the document from Pages in PDF. I put this file on either my College’s server (using AFP with the Finder) or the Engineering Department’s server (`scp`, Terminal). Then I go and use the College’s or the Department’s printing facilities.

## Conclusions ##

- Writing in Markdown with Notational Velocity works well.
- Converting from Markdown/HTML to Pages does not work well.

[ET]: http://www.eng.cam.ac.uk/
[M]: http://daringfireball.net/projects/markdown/
[NV]: http://notational.net/
[P]: http://www.apple.com/iwork/pages/
[S]: http://simplenoteapp.com/

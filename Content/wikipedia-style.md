title: Wikipedia style
date: 2011-01-08T15:14:00+0000
tumblr: 2652342310
%%%

I used Kridsada Thanabulpong’s [User CSS][UC] Safari Extension to apply some custom CSS rules to Wikipedia. (Extension found via [Daring Fireball][DF])

![Top of Wikipedia’s article on Bears, shown with my style adjustments](bears.png)

My goal was to increase readability by changing the font and removing page elements I never use. I required that my modifications were lightweight; I don’t want to make as many changes as [Beautipedia][B]. Here is the CSS:

	@media screen {
		* {
			background-image: none !important;
		}
		#mw-page-base,
		#mw-head-base,
		#mw-panel,
		#mw-head,
		#fwpHeaderContainer,
		span.editsection,
		table.navbox {
			display:none;
		}
		#content, #footer {
			max-width: 600px;
			margin: 0em auto !important;
			padding: 1em 2em 2em !important;
		}
		body {
			font: 20px Georgia !important;
		}
	}

I use User CSS to apply this to the domains: `http://en.wikipedia.org/wiki/*` (Amusingly, that’s a real page.)

What’s going on:

- Don’t make changes to other media (such as print).
- Remove all background images to take out blue borders. There might be a better way of doing this than using a wildcard, but this works.
- Use `display:none` to remove things I don’t use. This includes pretty much everything except the article. (I search Wikipedia using [Alfred][A].)
- Put the article in a column of maximum width 600 pixels, centred with the `auto` margins.
- Use Georgia and a base font size of 20 pixels. The article body is at 0.8 em, so 16 pixels. You may want to alter the base font size, but consider reducing the maximum width if using smaller type.

![Top of Wikipedia’s article on NetNewsWire, shown with my style adjustments](netnewswire.png)

![Bottom of Wikipedia’s article on the Nintendo 64, shown with my style adjustments](nintendo-64.png)

## Known Problems

- Does not cope well with very wide images and tables. Usually when viewing the page for an image resource, rather than in an article.
- Info box does not cope well when the window is very narrow.

[UC]: http://code.grid.in.th/
[B]: http://davidbenjones.com/beautipedia/
[DF]: http://daringfireball.net/linked/2011/01/05/user-css
[A]: http://www.alfredapp.com/

title: Hard-to-see scroll bars
date: 2012-01-29T19:28:00+0000
tumblr: 16710526470
%%%

Have you perchance been viewing the [Python documentation][P] in Safari on Lion, and been frustrated that the overlay scroll bars can barely be seen?

![Screenshot showing white scroll bar on white background. It’s only visible due to a very faint outline.](light-bar.png)

I promise the scroll bar is there; I can see it viewing this page on my iPhone 4.

This CSS, applied with [Kridsada Thanabulpong’s User CSS extension][U], should remedy the situation.

	body {
		background-color: white !important;
	}

![Screenshot showing dark bar on light background. It’s easily visible.](dark-bar.png)

There is no change to the appearance of the page as the `body` element is completely covered. **Update:** The footer at the bottom of the page becomes unreadable white text on a white background, but whatever.

[U]: http://code.grid.in.th/
[P]: http://docs.python.org/

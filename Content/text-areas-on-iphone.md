title: Text areas on iPhone
date: 2011-04-30
time: 13:11:40+0000
tumblr: 5068438799
%%%

The HTML `textarea` tag is used to include multiple line text input areas on webpages.

<textarea>This is a text area.</textarea>

## The Problem ##

Text areas are tricky to use on iOS, particularly on the iPhone or iPod Touch. If there is too much text to fit in the box, you need to use two fingers to scroll around. Pushing with one finger just scrolls the whole page.

<img class="iphone4" src="actual-text-area.png" alt="screen shot of text area on mobile Tumblr website in Safari on iPhone">

Text areas could be more usable. I don’t have a definitive solution; it would be ridiculous to claim to have such a thing.

## Something Better? ##

I’m only going to think about making things better for iPhone or iPod Touch. Basically, my idea is to show the text area full screen. Here’s a mockup:

<img class="iphone4" src="full-screen-mock-up.png" alt="mocked up screen shot of full screen text editing view">

When tapping a text area or ‘tabbing’ into one using the Previous and Next buttons on Safari’s form assistant, the text area fills the screen. Text is inputted with a standard font, and scrolling is done normally (with one finger). The transition to this modal view could be slide up (like composing a new message in Mail) or a zoom onto the text area while fading nearby content. The modal view is exited by ‘tabbing’ to a different input element, or by pressing the Done button in the form assistant.

The disadvantage of this specific design is that I have eliminated all information about the current context. If you went to a text area and you were then distracted, when looking back at the iPhone you may forget what you intended to type. The title in the title bar usually acts as a prompt, but a it may not be possible to derive a simple title for all text areas. That’s why I left the title bar out of my mockup.

However, this specific solution is not key. The problem exists, and something better must be possible.

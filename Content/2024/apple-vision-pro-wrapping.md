date: 2024-01-08T21:18:00+0000
%%%

Style guides are hard ([source](https://developer.apple.com/visionos/submit/))

![Screenshot of Apple webpage highlighting the text “Don’t break Apple Vision Pro over two lines.” and further down showing that same text split over two lines.](screenshot.png)

They’ve done this using CSS `white-space: nowrap`: <span style="white-space: nowrap;">Apple Vision Pro</span> — but missed it in some places.

An alternative is to use non-breaking spaces (option + space): Apple Vision Pro — this will work if CSS is removed, such as in my [reading app](/reading-app/).

title: Why I made Magic Spell
description: I found myself fixing a lot of spelling errors in source code, so I made a Mac app to check spelling in many files at once.
micro: I wrote about [why I made Magic Spell]().
date: 2016-02-05T09:52:54+0000
tweet: 695545626982019072
%%%

Towards the end of last year, I found myself fixing a lot of spelling errors in source code. Spelling errors look unprofessional, especially when documentation is generated from header files. I created a little tool to automate the process of finding all the spelling errors. It found all the text files in a folder and used AppKit’s [NSSpellChecker][NSSC] API to check each file.

I like making apps and have been wanting to ship something of my own for ages, but until now I’ve never had the discipline and focus to turn any of my side projects from prototypes into products. Bart Jacobs describes the situation accurately in [Build That Application][BJ]. My little spell checker seemed like a perfect opportunity to make a product: it doesn’t tackle any hard technical problems, and stands on its own without any server infrastructure.

So that’s what I did, and the result is [Magic Spell][MS].

![screen shot of Magic Spell Mac app](/magicspell/screen-shot.png)

It’s a Mac app. You open a folder in Magic Spell and it checks the spelling of all the documents inside, showing the results in one convenient list. You can specify settings such as words that should be ignored, which are shared for all documents in that folder.

Magic Spell works best for solving my original problem: a software project is a large collection of plain text documents that change rapidly, and are often edited without spell checking. I made the app more general purpose by supporting other common document formats, notably Microsoft Word documents.

I initially intended to release Magic Spell on the Mac App Store, and went as far as submitting a version I was happy with — but it was rejected. That rejection was fair; I had not read the rules carefully enough, and I could have adapted the app fairly easily to follow the rules. However, it led me to thinking about the uncertainty of releasing on the Mac App Store: the first version might pass Apple’s review, but I have future features in mind that surely move further into the grey area of acceptability. I decided the uncertainty was not worth it for Magic Spell.

I bolted on features the Mac App Store would otherwise provide after preparing everything else. Matt Gemmell’s article form 2012 on [Releasing Outside the App Store][MG] was a tremendous help. Right now, I would say the roughest part of the app is the pre-purchase experience. However, at least there’s something — it’s better than the Mac App Store where there is no pre-purchase trial. (**Edit:** Magic Spell is now free, removing this rough spot.)

There is a lot more I want to do with Magic Spell to make the app more useful and pleasant to use. I can’t help but see countless potential extra features and opportunities to apply more polish — but a line needs to be drawn: there can’t be a 1.1 and 1.2 until 1.0 has shipped. As Daniel Jalkut says, most recently on [the latest episode of Core Intuition][CI], shipping software is like a muscle and you need to exercise it to make it strong.

[Magic Spell is available to download now.][MS]

[MS]: http://douglashill.co/magicspell/

[NSSC]: https://developer.apple.com/library/mac/documentation/Cocoa/Reference/ApplicationKit/Classes/NSSpellChecker_Class/index.html

[CI]: http://www.coreint.org/2016/01/episode-217-surely-i-can-get-this-done/

[MG]: http://mattgemmell.com/releasing-outside-the-app-store/

[BJ]: http://bartjacobs.com/build-that-application/

title: Designing notifications
date: 2011-03-01T21:30:00+0000
tumblr: 3587705237
%%%

Before continuing, please see [Sebastiaan de With’s Getting Notified][C], where he looks at notifications in WebOS, Android and iOS.

## Types of notifications

A notification is a *message* presented to the user, often with an optional *action*. There is a difference between notifications from *foreground* applications and *background* notifications.

<table><tr><td> </td><th>Foreground</th><th>Background</th></tr><tr><th>Optional action</th><td>No internet connection, do you want to go to Settings (Mail)</td><td>Text messages, push notifications</td></tr><tr><th>No action</th><td>Instapaper’s ‘No internet connection’ in toolbar</td><td>Low battery</td></tr></table>

Last year, rather than allow unrestricted multitasking, Apple added key services such as background location and task completion. Notifications could be similar: there does not need to be just one solution to fit every problem.

## Foreground notifications

I object to Sebastiaan’s example of Mail, which presents a barrage of messages.

> when I am abroad, with my three email accounts, whenever I open Mail on my iPhone, I have to dismiss three ‘data roaming is off’ dialogs, and three ‘cannot get mail’ dialogs

The root of the problem is the number of messages generated. There should be a single ‘no internet connection’, because that’s all we need to know. However, notifications is the topic at hand. Even if there was just one blue box message, it would still be obtrusive. On the plus side, it provides an easy way to resolve the problem (go to Settings).

[Instapaper][I] deals with the absence of an internet connection in a less aggressive way. Just a text label in the toolbar. This interface is not intrusive, but does not help out if we do want to reconnect. The situation is very similar between Mail and Instapaper. Both are apps that require an internet connection to load new data, but can usefully show saved data when offline.

There must be a happy middle ground that is both unobtrusive and provides a convenient shortcut to fix the ‘problem’.

## Background notifications with actions

The situation for foreground notifications is easier because the notification is welcome to use space within the application; the notification is part of the app. See how Instapaper puts the message in the toolbar.

Things are more difficult for notifications from background applications. The principle example is incoming text messages. We are looking for a way to alert the user, while avoiding disrespectfully taking screen space from the foreground app or stealing attention. Remember, while Maps is open, the iPhone *is a map* and maps can’t receive text messages. (Well this one can, but I hope you can see my line of thought.)

I shall not suggest a solution to this problem. It would be foolish to suggest I could get this right with so little thought, discussion or — critically — user testing.

## Background notifications with no action

Why would a notification require no response? I used the low battery warning as an example above. Well low battery does have an action — charging the device — but this happens outside the realm of the OS. Aza Raskin would describe such an interface as having an efficiency of zero percent. (See his great post: [Know When to Stop Designing, Quantitatively][AR].)

Another example is carrier messages. After making a call or sending a text message, I am notified of my balance. O2 also send me messages:

<img class="iphone4" src="zero-minutes.png" alt="iPhone screen shot showing message telling me I have made zero minutes of qualifying calls">

Imagine if your internet service provider block interaction of your whole computer screen to send you a message. This is the same situation, but with your mobile ISP. These carrier messages are ripe for an overhaul.

I’ll give a specific idea here: hide the clock and display the message centred in the status bar. Flash the status bar if it’s important. This would work well for low battery and balance. The example carrier message above is too long, but… I don’t really care.

## Flood of notifications

Finally, I don’t want lots of notifications. I have Mail set up to only check for new messages when I open it. Other people have different preferences.

In the comments on Sebastiaan’s post, Ilari Sani says :

> In a way, I hope that Apple doesn’t make notifications too convenient for developers. Having a notification API in place makes developers feel they need to notify about every trivial thing. This is why I don’t run Growl on my Mac – it turns apps into petulant children, constantly vying for the user’s attention.

Spot on.

[C]: http://blog.cocoia.com/2011/notify/
[AR]: http://www.azarask.in/blog/post/know_when_to_stop_designing_quantitatively/
[I]: http://www.instapaper.com/

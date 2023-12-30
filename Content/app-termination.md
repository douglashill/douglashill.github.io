title: FB6185896
subtitle: App unexpectedly terminates instead of receiving `application:didDiscardSceneSessions:`
date: 2019-06-20
time: 12:00:00+0000
%%%

Copy of feedback filed with Apple.

## Steps to reproduce

1. Open three windows in an app that supports multiple scenes/windows
2. Swipe up from the multitasking switcher to close the first window, and observe that the app delegate is sent `application:didDiscardSceneSessions:`
3. Close the second window, and observe that the app delegate is sent `application:didDiscardSceneSessions:`
4. Close the third window

## Observed

The process is terminated.

## Expected

The process should stay alive, and the app delegate should be sent `application:didDiscardSceneSessions:`.

For an app that does not support multiple windows (and on iPhone), the expected behaviour when swiping up from the multitasking switcher is that the tile is removed from the app switcher and no changes are made to the process.

## Discussion

There are numerous problems with forcefully terminating the process, including:

- The next time the app is opened the user must wait for the app to relaunch. On the other hand resuming a suspended app is extremely quick.
- Relaunching requires more energy than resuming a suspended app, using the user’s battery.
- The app may have just entered the background and be stopped in the process of saving user data.
- The app might be running background tasks such as to sync user data.

There is a widespread misconception that swiping apps up from the multitasking switcher is somehow good hygiene. This is a waste of human time, but as discussed above it’s also harmful to battery life and potentially user data.

My proposed solution is good for these users. They can keep their habits, but magically their apps open way faster and their battery life improves. Gradually word will spread that swiping apps up does nothing except remove them from the list. People that swipe up on everything because they like a clean slate can keep doing it. Hopefully more people conclude that they’re wasting their time and stop doing it.

I can think of two legitimate reasons for the user to manually terminate a process: fixing apps in a bad state and stopping background execution.

## Fixing apps in a bad state

This should be unusual. However this is implemented, it should be different (and much harder) than discarding windows.

My proposal is to add a button in the Settings app under the section for each app. The button could be labelled something like ‘Restart SomeApp’ perhaps with detail text. On tapping this button:

- If running, the process is terminated. The user sees no indication whether it was running or not.
- Saved UI state is cleared.
- The app is launched and shown.

The app gets launched for two reasons:

- The user would only want to resolve an app being stuck if they wanted to use it. If they don’t want to use the app, they would just not use it.
- This emphasises that this is not a mechanism to reduce the number of running processes.

## Stopping background execution

The other reason users swipe up on apps up is to stop user-aware background execution. In general, terminating the process is not an elegant way to stop background execution. A better way would be to stop the background operation and leave the process alive. (For the same reasons as always: resume speed, battery life, saving data.) The reality is swiping up from the multitasking switcher can be the easiest way for the user to stop an app.

VoIP apps are fine because the user can easily hang up the call. Background audio is fine because the user can use the pause button on the lock screen or in Control Center.

The case that needs attention is background location. Swiping up from the multitasking switcher is the easiest way to stop Waze. A pragmatic solution would be to keep applying the existing behaviour of terminating when the last window is closed from the multitasking switcher if an app uses background location.

## Conclusion

iOS has a beautifully architected multitasking system where the system manages process lifetimes. This frees the user from the burden of managing this technical detail, and it improves system responsiveness and battery life. This system is undermined by the multitasking switcher.

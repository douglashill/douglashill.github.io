title: Gesture recogniser dependency logging
micro: Since iOS 17, we saw logs about “Abnormal number of gesture recognizer dependencies”. We never observed an actual issue, and it seemed like lot of work to add ‘gate’ recognisers to silence some logging. Good news is this logging was removed in iOS 26, so it was worth holding out. [Full post]()
date: 2025-11-25T16:33:24+0000
%%%

Since iOS 17, we saw these log messages from UIKitCore:

> Abnormal number of gesture recognizer dependencies: xxx. System performance may be affected. Please investigate reducing gesture recognizers and/or their dependencies.

We never observed an actual performance issue related to gesture recognisers. It seemed like lot of work to add ‘gate’ nodes to the gesture recogniser graph to reduce the number of relationships just to silence some system logging.

Good news is this logging was removed in iOS 26, so it was worth holding out.

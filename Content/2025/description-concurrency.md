title: `description` for main actor classes with Swift strict concurrency
description: Is there a best practice for implementing `description` and `debugDescription` for main actor classes with Swift strict concurrency? [I’m going with checking the thread for now](), which works, but seems off.
date: 2025-01-22T19:43:54+0100
%%%

Is there a best practice for implementing `description` and `debugDescription` for main actor classes with Swift strict concurrency? This works, but seems off:

```
override var description: String {
    if Thread.isMainThread {
        MainActor.assumeIsolated {
            "\(type(of: self)) Property 1: \(property1), Property 2: \(property2)"
        }
    } else {
        "\(type(of: self))(Not on main thread)"
    }
}
```

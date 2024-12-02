title: Drop doesn’t work over `List`
description: Copy of feedback sent to Apple as FB16024301.
micro: One of the issues I have rewriting much of my reading app in SwiftUI is that drops don’t work over `List`. Here’s a [copy of the feedback sent to Apple as FB16024301]().
date: 2024-12-02T22:02:05Z
%%%

I’m rewriting the list/navigation/settings part of my [reading app](/reading-app/) in SwiftUI. My app is for reading web articles and text, so getting content into the app is important. One way to do that is with drag and drop.

One of the issues I’m facing with SwiftUI is that drops don’t work over `List`. Here’s a copy of the feedback sent to Apple as FB16024301. I didn’t include the sample project here because the code shown is basically all there is.

Currently the only workaround I know is to require users to drop on a navigation bar (the only part of my window not covered by a `List`.) I feel I must be missing something here.

---

## Drop doesn’t work over List

Drop operations (as in: drag and drop) don’t work over SwiftUI List.

### Steps

1. Run the attached minimal sample project
2. Open another app in split view that can drag text, such as Safari
3. Drag text from the other app
4. Drop that text over the sample app

This is the relevant code:

```
struct ContentView: View {
    var body: some View {
        List(0..<5, id: \.self) { _ in
            Text("This is a test.")
        }
        .dropDestination(for: String.self) { items, location in
            print("Dropped \(items) at \(location).")
            return true
        }
    }
}
```

### Expected

Console should print the dropped text.

### Observed

Drop is not possible.

### Configuration

I’m running on iOS 18.1.1 on an M4 iPad Pro 13-inch.

### Notes

Same occurs with the `.onDrop` modifiers.

If you swap the `List` for something like `Text` you can see drop will work.

No similar issue occurs using UIKit. I.e if you put a `UICollectionView` with a compositional layout with a list configuration as a subview of a view with a `UIDropInteraction`, the drop interaction still works.

The SwiftUI `List` also blocks a UIKit `UIDropInteraction` set up parent view. I tested with the parent view controller of my `UIHostingController`.

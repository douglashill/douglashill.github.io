title: Invalid contexts with `UIGraphicsImageRenderer`
description: Graphics contexts created by `UIGraphicsImageRenderer` are somehow invalid for reading the width and height.
date: 2024-01-11
time: 16:33:21+0000
%%%

Graphics contexts created by `UIGraphicsImageRenderer` are somehow invalid for reading the width and height. This code:

```
let image = UIGraphicsImageRenderer(size: CGSize(width: 100, height: 60)).image { context in
    let width = context.cgContext.width
    print("Width is \(width).")
    let height = context.cgContext.height
    print("Height is \(height).")
}
```

Unexpectedly logs this:

```
CGBitmapContextGetWidth: invalid context 0x600003704600. If you want to see the backtrace, please set CG_CONTEXT_SHOW_BACKTRACE environmental variable.
Width is 0.
CGBitmapContextGetHeight: invalid context 0x600003704600. If you want to see the backtrace, please set CG_CONTEXT_SHOW_BACKTRACE environmental variable.
Height is 0.
```

It works fine with this older API that’s marked `API_TO_BE_DEPRECATED`:

```
UIGraphicsBeginImageContext(CGSize(width: 100, height: 60))
let context = UIGraphicsGetCurrentContext()!
let width = context.width
print("Width is \(width).")
let height = context.height
print("Height is \(height).")
let image = UIGraphicsGetImageFromCurrentImageContext()!
UIGraphicsEndImageContext()
```

Logs the expected output:

```
Width is 100.
Height is 60.
```

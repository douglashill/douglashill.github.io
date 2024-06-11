date: 2024-06-11T11:52:17+01:00
%%%

With [automatic trait tracking](https://developer.apple.com/documentation/uikit/app_and_environment/automatic_trait_tracking), UIKit detects when you read traits (like the size class) in `layoutSubviews` (etc.) and automatically calls `setNeedsLayout` (etc.) when those traits change. 🤯

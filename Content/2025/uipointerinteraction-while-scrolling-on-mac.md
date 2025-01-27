date: 2025-01-27T17:11:02+01:00
%%%

Interesting finding: `UIPointerInteraction` updates continuously while scrolling on Mac, but not on iPad (only when the pointer moves on screen). The Mac behaviour is more correct because the content under the pointer might change when scrolling, but this makes the performance way less forgiving.

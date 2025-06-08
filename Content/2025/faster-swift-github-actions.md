date: 2025-06-08T15:07:45+01:00
%%%

Since I might want real-time posting during Apple’s keynote tomorrow, I made my site build a bit quicker on GitHub Actions. [My key finding](https://github.com/douglashill/douglashill.github.io/commit/26d5722a13b89036b7874f94e4d5fb25562e111c) is that calling `swift` has a high startup cost here. Even `swift --version` can take 9 seconds. I went with caching the compiled Swift build script.

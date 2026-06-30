title: RustWeek
description: Notes from attending the RustWeek conference in Utrecht.
date: 2026-07-01T00:00:28+0200
%%%

In May, I attended [RustWeek](https://rustweek.org/) in Utrecht. This was my first time at a conference outside of iOS/Swift development, and except for [try! Swift Tokyo](https://tryswift.jp/), it was the biggest conference I’ve been to. Someone said there were around 800 attendees, which sounds plausible.

The conference had three parallel talk tracks, and you could easily switch tracks between each talk. Everything ran impressively on schedule so it was easy to switch rooms.

I’m fairly new to Rust so some of the more technical details in talks were harder for me to follow, but it was great learning about Rust and the Rust community. There were enough general talks that someone who never worked with Rust could probably find the two days useful treating this as a general software development conference.

Since I went into the conference knowing nobody, I would have appreciated more structure in place to help with meeting people. Of course I still met people, just this was harder work. There were social activities, but these were mostly *after* the main conference days, and I wasn’t able to stay around that long. Ideally you’d meet more people before. [UIKonf](https://uikonf.com/) did this best, with a range of excellent social activities on the Sunday afternoon before their conference (kayaking, bike tour, museums) and volunteers organising dinner groups.

Below are notes on some of the talks I attended.

## Day 1

The main track started with [*The Language of Empathy*](https://2026.rustweek.org/talks/taylor/) by [Taylor Cramer](https://github.com/cramertj/). This was a great opener. Taylor spoke about empathy as part of Rust’s design philosophy, tooling, and community, then turned that into practical advice for building better systems and better teams. The advice wasn’t specific to Rust or software development really. For example, if someone is expressing an opposing view to you, make sure you’ve each communicated your *trade-offs*. Making different trade-offs is likely leading to the different conclusions.

![Photo of Taylor Cramer on stage with summary slide that says: Empathy; Focus on OFNR (observations, feelings, needs, requests); Discuss your trade-offs; Be open to having your mind changed; Find positive-sum solutions!](empathy.jpg)

[*When is never?*](https://2026.rustweek.org/talks/waffle/) by [waffle](https://blog.ihatereality.space/) switched to a technical topic: the never type. It explained what Rust’s [`!` never type](https://doc.rust-lang.org/std/primitive.never.html) is, why this has been unstable for so long, and what is involved in bringing this to stable Rust. The talk was still easy enough for me to follow along. There are some inconsistencies in how never behaves, and it’s desirable to resolve these before making the API stable. To do this, some existing code would have to be broken one way or another. The chosen approach is to make this a warning first. We’ll be able to retain the old behaviour by staying on an older edition of Rust.

The never type being called [`!` in Rust](https://doc.rust-lang.org/std/primitive.never.html) and [`Never` in Swift](https://developer.apple.com/documentation/swift/never) is a great example of the trade-offs in the languages. Rust often likes to express things with a minimum of characters. Swift is more verbose, but I would say generally ends up with more clarity and consistency.

[*Scaling up Rust development at the Dutch Electoral Council*](https://2026.rustweek.org/talks/mark/) by [Mark Janssen](https://github.com/praseodym) covered lessons from using Rust in production for Dutch elections and scaling Rust usage to new projects at the [Dutch Electoral Council](https://www.kiesraad.nl/). This included an overview of how the voting system works in the Netherlands: individual votes are made on paper and summed up locally on an air-gapped system running [Abacus](https://github.com/kiesraad/abacus), which is implemented in Rust and React/TypeScript.

By regulation, the entire toolchain, including the compiler, must be open source. They thought Rust was the more unproven thing, but actually had more issues with React.

[*How we replace common C(++) libraries with Rust at scale*](https://2026.rustweek.org/talks/bastian/) by [Bastian Kersting](https://github.com/1c3t3a) from Google was about replacing libraries with Rust alternatives, then exposing them back to C++ using [Crubit](https://github.com/google/crubit). Rather than rewriting all their C++ in Rust, what they’re focusing on first is swapping out dependencies for things like image decoding and compression from C/C++ to Rust dependencies. This addresses the most likely areas for memory safety bugs first. They mostly wrap these for use from their C++ code. A useful resource shared was Google’s [safe-bindings](https://github.com/google/safe-bindings) repository.

[*Lessons Learnt from using Rust as the Intro to Programming*](https://2026.rustweek.org/talks/andreea/) by [Andreea Costea](https://andrecostea.github.io/) explored using Rust as the first language in an introductory programming course. One concern was whether Rust not allowing many types of programming errors would deprive students from learning from their mistakes. As it turned out, they still make the mistakes, but the compiler catches these, so the compiler itself is like a teaching assistant.

[*Common Pitfalls of Rewriting Things In Rust*](https://2026.rustweek.org/talks/cliff/) by [Cliff L. Biffle](https://cliffle.com/blog/) was focused on systems programming and common patterns from C, C++, and Go that don’t translate cleanly to Rust. My main takeaway was that it’s aliasing: two references back to the same memory. Global variables are also common in C, and Rust doesn’t like them, but they can still be a good option.

[*When Iterators Aren’t Zero Cost*](https://2026.rustweek.org/talks/xavier/) by [Xavier Denis](https://github.com/xldenis) was a look at when iterators in Rust can and can’t be compiled to vector instructions. This was technically deep, but was clearly presented so I found it easy to follow. It was useful to learn about [speedscope](https://speedscope.app/), a flame graph visualiser for analysing where programs spend their time.

The first day finished with [*Completion-based IO*](https://2026.rustweek.org/talks/alice/) by [Alice Ryhl](https://ryhl.io/). The talk was about the history of operating system APIs for reading and writing files and how [Tokio](https://tokio.rs/) provides async behaviour on top of these mostly synchronous APIs. The technical details went a bit over my head at the end of a long day!

## Day 2

In [*Untrusted data in Linux — How Rust is going to save us*](https://2026.rustweek.org/talks/greg/), [Greg Kroah-Hartman](http://www.kroah.com/log/) spoke about making the boundary between trusted and untrusted data explicit in the Linux kernel, using Rust to track data that crosses from userspace into the kernel. The kernel abstracts away the hardware and is never finished because hardware keeps changing. Linux is used everywhere, including in cow-milking machines.

A recurring theme was “all input is evil”. Greg talked about `guard()` in C for scoped locks and allocations, inspired by Rust, and about using `Untrusted<T>` and different pointer types for data originating outside the kernel. At the snapshot shown in the talk, Linux had around 36 million lines of C and 113,000 lines of Rust. Adding Rust has also forced them to review C APIs. They want more developers; the place to start is [Rust for Linux](https://rust-for-linux.com/).

[*Debunking Rust Wasm Performance Myths: Why We Moved Core Business Logic to Rust at Canva*](https://2026.rustweek.org/talks/wasm/) by [Andrew Jakubowicz](https://andrewjakubowicz.me/) and [Taj Pereira](https://github.com/taj-p) covered lessons from shipping Rust and WebAssembly in production at Canva. WebAssembly is a compile destination that complements JavaScript, can run on the server as well as in the browser, and is sandboxed by default. It has no knowledge of the host, so it can’t even log to the console without help, and Rust commonly integrates with JavaScript via [`wasm-bindgen`](https://github.com/rustwasm/wasm-bindgen).

The performance section pushed back on several myths. JavaScript might be fast enough on high-end devices, but many people use low-end devices that aren’t getting faster in the same way. JavaScript can also hit slow cases with megamorphic input and garbage collection spikes. The talk also covered the “bridge tax”: function calls don’t necessarily have meaningful overhead, but strings are more complicated because JavaScript uses UTF-16 while Rust uses UTF-8. Their supporting book for the talk is [Rust Wasm Performance Myths](https://rust-wasm-myths.rustweek2026.workers.dev/). They also mentioned that there is no JavaScript JIT in hybrid apps on iOS, so compiling Rust natively can make sense there.

[*Learning Rust as First Programming Language*](https://2026.rustweek.org/talks/karin/) by [Karin Lammers](https://github.com/jkarinkl) covered what it is like to learn Rust with no previous programming experience. She described five pillars of learning: motivation, growth mindset, habit, a network of people, and resources. One useful framing was “I can’t do this *yet*.” She also kept a journal, so she could look back and see her progress. Good resources were [The Rust Programming Language book](https://doc.rust-lang.org/book/) (which I read already) and [Rustlings](https://rustlings.rust-lang.org/), which provides small exercises and was new to me.

There aren’t many learning resources out there for learning Rust as a first language. You can learn how to write a function in Rust, but not what a function is.

[*Obsessive Optimization with String Interning*](https://2026.rustweek.org/talks/arya/) by [arya dradjica](https://bal-e.org/) was a deep dive into low-level optimisation through string interning, based on building a fast multi-threaded string interner. A couple of interesting crates are [`string-interner`](https://docs.rs/string-interner) and [`hashbrown`](https://docs.rs/hashbrown/latest/hashbrown/).

[*Are we interop yet?*](https://2026.rustweek.org/talks/teor/) by [Teor](https://github.com/teor2345) covered the current state of Rust interop features, especially for C++ and similar languages. C interfaces rule the world, and a lot of interop is specified in terms of C, but C can’t capture features of modern languages. Some of the tools mentioned were [Zngur](https://hkalbasi.github.io/zngur/), [Crubit](https://github.com/google/crubit), [cxx](https://cxx.rs/), [autocxx](https://google.github.io/autocxx/), [bindgen](https://rust-lang.github.io/rust-bindgen/), and [cbindgen](https://github.com/mozilla/cbindgen).

[*Overcoming GitHub shortcomings with Triagebot*](https://2026.rustweek.org/talks/urgau/) by [Urgau](https://github.com/Urgau) was about improving Rust’s GitHub workflow with [Triagebot](https://forge.rust-lang.org/triagebot/index.html). GitHub can make large or long-lived PRs hard to review: it collapses large numbers of comments and only loads more comments in chunks. Triagebot adds a [view of all comments](https://forge.rust-lang.org/triagebot/view-all-comments-link.html), which is also useful if the main GitHub site is down but the API still works.

Another useful feature was a [`git range-diff`](https://git-scm.com/docs/git-range-diff) viewer: a diff of diffs. This can be confusing manually, so the bot detects rebases and posts a comment linking to a range-diff view.

[*Typst: Designing for Incrementality*](https://2026.rustweek.org/talks/laurenz/) by [Laurenz Mädje](https://laurmaedje.github.io/) covered how [Typst](https://typst.app/) is designed to support real-time preview for large documents.

An interesting point was that you can’t lay out a document in one pass. A table of contents depends on headings, but comes first, so it can push following pages later. With LaTeX you often need to run the compiler multiple times. Typst automatically runs multiple times until the result stabilises. Laurenz also talked about memoization with [comemo](https://github.com/typst/comemo). Since Typst is like a program with no extra input, everything is determined; you can hover over code and it shows the result of that code.

The conference closed, for me, with [*Between Computer Code And Legal Code: Open Source’s Influence*](https://2026.rustweek.org/talks/aeva/) by [Æva Black](https://aeva.online/). This was about the relationship between open source, policy and regulation. Æva talked about how open source communities can participate in shaping rules that will affect them.

There were several interesting examples. MySQL was an open source company acquired for a billion dollars. Companies building on top of open source can be incentivised not to share security patches. The [EU Cyber Resilience Act](https://digital-strategy.ec.europa.eu/en/policies/cra-open-source) changes some of that by obliging companies to provide patches, while open source projects are not obliged to incorporate them. Open source stewards have some fairly lightweight responsibilities under this act.

## In general

It was clear from the conference just how important *community* is to Rust.

People at the conference works on all sorts of different things, and it seems like many people didn’t use Rust at the main jobs (like me). This makes sense given how awesome the language is but how painful big code migrations are.

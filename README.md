# douglashill.co

This is the source for Douglas Hill’s personal website, [douglashill.co](https://douglashill.co/). It’s a static site with a bespoke build system written in Swift. See [`generate.swift`](generate.swift).

Pages are created as Markdown files in [`Content`](Content). At it‘s core, the site generator copies files in `Content` to `Output`, while processing Markdown files from `path/file.md` to `path/file/index.html`.

A blog post is a page with a date in the front matter. Various index pages and feeds are generated for blog posts, including `micro-feed.json`, which is the data source for [@douglas](https://micro.blog/douglas) on [Micro.blog](https://micro.blog/), which cross-posts to various social media sites.

## Requirements

[Swift](https://www.swift.org/)

## Build and preview

Compile the executable:

```sh
swift build
```

Compile the executable and run it to generate the website (use this to check code changes):

```sh
swift run
```

Generate the website while only compiling the executable if not cached at `generate` (fastest option for previewing content if code and dependencies haven’t changed):

```sh
./cached-build.sh
```

Remove the cached executable:

```sh
rm generate
```

## Deployment

The site deploys to GitHub Pages on pushes to `main` using GitHub Actions. See [`publish.yml`](.github/workflows/publish.yml).

## Repository guidelines

The Swift package defined in `Package.swift` builds a single executable target named `generate` using Apple’s `swift-markdown`. The entry point lives in `generate.swift` with supporting Markdown formatters in `markdown.swift`. 

Content authoring happens in `Content` in Markdown files with front matter separated by a line with `%%%`. The front matter only supports simple key-value pairs, not full YAML.

New Markdown files go in the subfolder for the current year. Binary assets live alongside the Markdown files so paths can be written simply as `![description](image.png)`. Content files use kebab-case-filenames.

Running the generator writes HTML and feeds to `Output` (ignored by Git).

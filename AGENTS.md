# Repository guidelines for AI agents

For background information and build commands, see `README.md`.

The Swift package defined in `Package.swift` builds a single executable target named `generate` using Apple’s `swift-markdown`. The entry point lives in `generate.swift` with supporting Markdown formatters in `markdown.swift`. 

Content authoring happens in `Content` in Markdown files with front matter separated by a line with `%%%`. The front matter only supports simple key-value pairs, not full YAML.

New Markdown files go in the subfolder for the current year. Binary assets live alongside the Markdown files so paths can be written simply as `![description](image.png)`. Content files use kebab-case-filenames.

Running the generator writes HTML and feeds to `Output` (ignored by Git).

NEVER run `swift build` or `swift run` with the `--disable-sandbox` option. If this means you can’t verify something, then ask the user to verify it instead.

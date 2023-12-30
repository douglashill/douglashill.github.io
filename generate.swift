// Douglas Hill, January 2018

import Foundation
import Markdown

@main
public struct Whatever {
	public static func main() {
		autocompletion()
	}
}

func logDebug(_ message: @autoclosure () -> String) {
	// print(message())
}

extension URL {
	func pathRelative(toBase baseURL: URL) -> String {
		var path = absoluteString
		path.removeSubrange(baseURL.absoluteString.startIndex..<baseURL.absoluteString.endIndex)
		return path
	}
}

extension DateComponents {
	var formattedHowILike: String {
		var components: [String] = []
		if let day {
			components.append("\(day)")
		}
		if let month {
			components.append(monthString(month))
		}
		if let year {
			components.append("\(year)")
		}
		return components.joined(separator: " ")
	}

	private func monthString(_ month: Int) -> String {
		switch month {
		case 1: return "January"
		case 2: return "February"
		case 3: return "March"
		case 4: return "April"
		case 5: return "May"
		case 6: return "June"
		case 7: return "July"
		case 8: return "August"
		case 9: return "September"
		case 10: return "October"
		case 11: return "November"
		case 12: return "December"
		default: fatalError("Month \(month) is out of bounds :)")
		}
	}
}

let publishedSiteRoot = "https://douglashill.co/"
let author = "Douglas Hill"

func autocompletion() {

#if ENABLE_PERFORMANCE_LOGGING
	let startTime = CFAbsoluteTimeGetCurrent()
#endif

	let fileManager = FileManager.default

    // When running using seemingly anything except Xcode, the current directory (.) would be the directory containing the package.
    // With Xcode, the current directory is somewhere in DerivedData, so use `#file` to get what we want.
    let projectDirectory = URL(fileURLWithPath: #file, isDirectory: false).deletingLastPathComponent()

	let contentDirectory = projectDirectory.appendingPathComponent("Content", isDirectory: true)
	let destinationDirectory = projectDirectory.appendingPathComponent("Output", isDirectory: true)

	let enumerator = fileManager.enumerator(at: contentDirectory, includingPropertiesForKeys: [.isDirectoryKey], options: []) { fileURL, error -> Bool in
		fatalError("Enumerator had trouble with \(fileURL): \(error)")
	}

	var articlesWithDates: [Article] = []
	/// Track files we generate so other files can be deleted at the end.
	var outputFiles: Set<URL> = []

	for untypedFileURL in enumerator! {
		let fileURL = untypedFileURL as! URL

		let value = try! fileURL.resourceValues(forKeys: [URLResourceKey.isDirectoryKey])
		if value.isDirectory! {
			logDebug("Skipping directory \(fileURL.path)")
			continue
		}

		if fileURL.lastPathComponent == ".DS_Store" {
			continue
		}

		if fileURL.pathExtension == "md" {
			let relativePath = fileURL.deletingPathExtension().pathRelative(toBase: contentDirectory)
			let isFrontPage = relativePath == "-front-page"
			let fileContents = try! String(contentsOf: fileURL, encoding: .utf8)

			let article = Article(relativePath: isFrontPage ? "" : relativePath, fileContents: fileContents)

			if article.rawDate != nil {
				articlesWithDates.append(article)
			}

			if article.externalURL == nil {
				let dir = isFrontPage ? destinationDirectory : destinationDirectory.appendingPathComponent(relativePath, isDirectory: true)
				let indexFileURL = try! article.writeAsIndexFile(inDirectory: dir, fileManager: fileManager)
				outputFiles.insert(indexFileURL)
			}

			continue
		}

		// Regular file. Copy it.

		let relativePath = fileURL.pathRelative(toBase: contentDirectory)
		let destination = destinationDirectory.appendingPathComponent(relativePath, isDirectory: false)

		try! fileManager.createDirectory(at: destination.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
		// It’s not that efficient reading both these files (which might be large images) to compare them, especially
		// since copying a file with APFS should be efficient. However avoiding disk writes seems like a good thing.
		if (try? Data(contentsOf: destination)) != (try? Data(contentsOf: fileURL)) {
			print("Copying to \(destination.path)")
			do {
				try fileManager.removeItem(at: destination)
			} catch {
                // `fileNoSuchFile` is fine; other errors are not.
                // `catch CocoaError.fileNoSuchFile` doesn’t seem to match on GitHub Actions so check in a different way.
                let nsError = error as NSError
                precondition(nsError.domain == NSCocoaErrorDomain && nsError.code == CocoaError.fileNoSuchFile.rawValue, "Some other error removing file before copying over it: \(error)")
			}
			try! fileManager.copyItem(at: fileURL, to: destination)
		} else {
			logDebug("Unchanged. Skipping copying to \(destination.path)")
		}

		outputFiles.insert(destination)
	}

#if ENABLE_PERFORMANCE_LOGGING
	print("Enumerated files in \(CFAbsoluteTimeGetCurrent() - startTime)s.")
#endif

	articlesWithDates.sort {
		if $0.rawDate! == $1.rawDate! {
			if $0.rawTime == nil || $1.rawTime == nil {
				fatalError("Missing time for articles on same day: \($0.relativePath) and \($1.relativePath)")
			}
			return $0.rawTime! > $1.rawTime! // Time must be explicit for articles published on the same day.
		} else {
			return $0.rawDate! > $1.rawDate!
		}
	}

	// Add redirects for Twitter and Tumblr posts with new paths.
	for article in articlesWithDates {
		for tweetID in article.tweetIDs ?? [] {
			if article.relativePath != "status/\(tweetID)" {
				let redirectDir = destinationDirectory.appendingPathComponent("status/\(tweetID)/", isDirectory: true)
				try! outputFiles.insert(article.writeRedirectFile(inDirectory: redirectDir, fileManager: fileManager))
			}
		}
		for tumblrID in article.tumblrIDs ?? [] {
			if article.relativePath != "post/\(tumblrID)" {
				let redirectDir = destinationDirectory.appendingPathComponent("post/\(tumblrID)/", isDirectory: true)
				try! outputFiles.insert(article.writeRedirectFile(inDirectory: redirectDir, fileManager: fileManager))
			}
		}
	}

	// Generate archive page.
    let archiveOutputFileURL = try! writeArchive(fromSortedArticles: articlesWithDates.filter { $0.type != .short }, title: "[\(author)](/)’s archive", toDestinationDirectory: destinationDirectory, filename: "archive", fileManager: fileManager) {
		// This will break if the title Markdown has a link in it, but long articles should not be link posts.
		var string = "[\($0.title!.markdown)](\($0.relativeURL))"

		if let description = $0.description {
			if CharacterSet.punctuationCharacters.contains($0.title!.plainText.unicodeScalars.last!) == false {
				string.append(":")
			}
			string.append(" \(description.markdown)")
		}

		return string
	}
	outputFiles.insert(archiveOutputFileURL)

	// Generate micro archive pages for each year.
	var articlesByYear: [Int: [Article]] = [:]
	for article in articlesWithDates {
		let year = article.dateComponents!.year!
		var articlesForThisYear = articlesByYear[year] ?? []
		articlesForThisYear.append(article)
		articlesByYear[year] = articlesForThisYear
	}
    if let firstYear = articlesWithDates.last?.dateComponents!.year!, let lastYear = articlesWithDates.first?.dateComponents!.year! {
        for year in firstYear...lastYear {
            logDebug("Number of posts in \(year): \(articlesByYear[year]!.count)")
            let outputFileURL = try! writeMicroArchive(fromSortedArticles: articlesByYear[year]!.reversed(), sectionGranularity: [.year, .month, .day], title: "[\(author)](/)’s posts in \(year)", toDestinationDirectory: destinationDirectory, filename: "\(year)", fileManager: fileManager) {
                // TODO: Maybe share with micro feed by adding a method on Article.
                let explicitShortText = $0.microPost?.markdown ?? $0.description?.markdown
                if explicitShortText != nil || ($0.title != nil && $0.characterCount + ($0.title?.plainText.count ?? 0) > 290) {
                    let microPost = (explicitShortText ?? $0.title!.markdown).markdownWithLinksRelativeTo($0.relativeURL, mustBeAbsolute: false)
                    return "\(microPost) <a href=\"\($0.relativeURL)\" title=\"\($0.title?.plainText ?? "")\">Read more »</a>"
                } else {
                    var partialHTML = $0.partialHTML.htmlWithLinksRelativeTo($0.relativeURL, mustBeAbsolute: false)
                    if let title = $0.title {
                        partialHTML = "\(title.markdown.markdownWithLinksRelativeTo($0.relativeURL, mustBeAbsolute: false))\n\n\(partialHTML)"
                    }
                    let endingsWithInlinePermalinks = ["</p>\n", "</li>\n</ul>\n", "</li>\n</ol>\n", "</p>\n</blockquote>\n"]
                    for ending in endingsWithInlinePermalinks {
                        // Hacky way to not put the permalink inline after a video (which would make it not be visible).
                        if partialHTML.hasSuffix(ending) && partialHTML.hasSuffix("controls preload=\"none\" /></p>\n") == false {
                            partialHTML = String(partialHTML.dropLast(ending.count))
                            // The newline before the a was to minimise the diff when adding this. It’s not needed.
                            return """
      \(partialHTML)
      <a href="\($0.relativeURL)" title="Permanent link to this post">»</a>\(ending)
      """
                        }
                    }
                    return """
    \(partialHTML)
    <p><a href="\($0.relativeURL)" title="Permanent link to this post">»</a></p>
    """
                }
            }
            outputFiles.insert(outputFileURL)
        }
    }

	// Generate the JSON feeds.
	// TODO: Increase the number of items in the feeds as I add more, especially the articles feed.

	// Micro feed
	try! outputFiles.insert(writeFeed(fromSortedArticles: articlesWithDates.prefix(20), isMicro: true, toDestinationDirectory: destinationDirectory, filename: "micro-feed.json"))
	// Full feed
	try! outputFiles.insert(writeFeed(fromSortedArticles: articlesWithDates.prefix(12), isMicro: false, toDestinationDirectory: destinationDirectory, filename: "full-feed.json"))
	// Articles-only feed
    try! outputFiles.insert(writeFeed(fromSortedArticles: articlesWithDates.filter { $0.type == .long }.prefix(3), isMicro: false, toDestinationDirectory: destinationDirectory, filename: "feed.json"))

#if ENABLE_PERFORMANCE_LOGGING
	print("Wrote files after \(CFAbsoluteTimeGetCurrent() - startTime)s.")
#endif

	let outputEnumerator = fileManager.enumerator(at: destinationDirectory, includingPropertiesForKeys: [.isDirectoryKey], options: []) { fileURL, error -> Bool in
		fatalError("Enumerator had trouble with \(fileURL): \(error)")
	}

	// Delete files that are no longer generated.
	for untypedFileURL in outputEnumerator! {
		let fileURL = untypedFileURL as! URL
		let value = try! fileURL.resourceValues(forKeys: [URLResourceKey.isDirectoryKey])
		if value.isDirectory! || outputFiles.contains(fileURL) {
			continue
		}
		try! fileManager.removeItem(at: fileURL)
		print("Deleted item at \(fileURL)")
	}

#if ENABLE_PERFORMANCE_LOGGING
	print("Finished after \(CFAbsoluteTimeGetCurrent() - startTime)s.")
#endif
}

func writeFeed(fromSortedArticles articles: ArraySlice<Article>, isMicro isMicroFeed: Bool, toDestinationDirectory destinationDirectory: URL, filename: String) throws -> URL {
	let feedItems: [[String: String]] = articles.map { article -> [String: String] in
		var item = [
			"id": article.publishedURLString,
			"url": article.publishedURLString,
			"date_published": article.rawDate! + "T\(article.rawTime ?? "12:00:00+00:00")",
		]

		// TODO: Support link posts in feeds. That is, where the title contains a Markdown link. It might be better to have a separate field for the link.

		if isMicroFeed {
			// let characterLimit = 260 // Limit is 280 for Twitter, which is only plain text, but links are special. Limit is 300 visible characters for Micro.blog.
			if let microPost = article.microPost?.markdown ?? article.description?.markdown ?? article.title?.markdown {
				let url = article.publishedURLString

				// precondition(microPost.count + 1 + url.count <= characterLimit, "Micro post is longer than \(characterLimit) characters: \(microPost) \(url)")

				let displayURL = url[url.range(of: "://")!.upperBound...].trimmingCharacters(in: .init(charactersIn: "/"))
				item["content_html"] = Document(parsing: "\(microPost) [\(displayURL)](\(url))", options: [.disableSmartOpts]).html
			} else {
				// TODO: I think this needs to count the plain characters after processing into HTML.
				// precondition(article.markdownLength <= characterLimit, "Article without microPost or title is longer than \(characterLimit) characters. HTML is: \(article.partialHTML)")
				// Micro.blog doesn’t work with relative image URLs, so make them absolute.
				item["content_html"] = article.partialHTML.htmlWithLinksRelativeTo(article.publishedURLString, mustBeAbsolute: true)
			}
		} else {
			// TODO: Include a `summary` from the `description` if one is set on the article.
			if let externalURL = article.externalURL {
				item["content_html"] = Document(parsing: "\(article.microPost?.markdown ?? article.description!.markdown) [Read more »](\(externalURL))", options: [.disableSmartOpts]).html
			} else {
				item["content_html"] = article.partialHTML
			}
			item["title"] = article.title?.plainText
		}

		return item
	}

	let feedAuthor: [String: String] = [
		"name": author,
		"url": publishedSiteRoot,
	]

	let feedDictionary: [String: Any] = [
		"version": "https://jsonfeed.org/version/1",
		"title": author,
		"home_page_url": publishedSiteRoot,
		"feed_url": "\(publishedSiteRoot)\(filename)",
		"author": feedAuthor,
		"items": feedItems,
	]

	let feedData = try JSONSerialization.data(withJSONObject: feedDictionary as NSDictionary, options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
	let outputFileURL = destinationDirectory.appendingPathComponent(filename, isDirectory: false)
	let oldData = try? Data(contentsOf: outputFileURL)
	if feedData != oldData {
		print("Writing to \(outputFileURL.path)")
		try feedData.write(to: outputFileURL)
	} else {
		logDebug("Unchanged so skipping writing to \(outputFileURL.path)")
	}
	return outputFileURL
}

func writeArchive(fromSortedArticles articles: [Article], title: String, toDestinationDirectory destinationDirectory: URL, filename: String, fileManager: FileManager, articleFormatter: (Article) -> String) throws -> URL {
	var archiveBody = """
	title: \(title)
	skipByline: true
	%%%
	"""

    // Lazy to avoid crash if there are no articles.
	lazy var sectionYear = articles.first!.dateComponents!.year! + 1

	for article in articles {
		let yearForThisArticle = article.dateComponents!.year!

		while sectionYear != yearForThisArticle {
			sectionYear -= 1
			archiveBody.append("\n\n## [\(sectionYear)](/\(sectionYear)/)")
		}

		archiveBody.append("\n\n\(articleFormatter(article))")
	}

	let archiveArticle = Article(relativePath: filename, fileContents: archiveBody)
	return try archiveArticle.writeAsIndexFile(inDirectory: destinationDirectory.appendingPathComponent(filename, isDirectory: true), fileManager: fileManager)
}

func writeMicroArchive(fromSortedArticles articles: [Article], sectionGranularity: Set<Calendar.Component>, title: String, toDestinationDirectory destinationDirectory: URL, filename: String, fileManager: FileManager, articleFormatter: (Article) -> String) throws -> URL {
	var archiveBody = """
	title: \(title)
	skipByline: true
	%%%
	"""

	var sectionDate: DateComponents?

	for article in articles {
		var dateForThisArticle = DateComponents()
		if sectionGranularity.contains(.year) {
			dateForThisArticle.year = article.dateComponents!.year!
		}
		if sectionGranularity.contains(.month) {
			dateForThisArticle.month = article.dateComponents!.month!
		}
		if sectionGranularity.contains(.day) {
			dateForThisArticle.day = article.dateComponents!.day!
		}

		if dateForThisArticle != sectionDate {
			sectionDate = dateForThisArticle
			archiveBody.append("\n\n## \(sectionDate!.formattedHowILike)")
		}

		archiveBody.append("\n\n\(articleFormatter(article))")
	}

	let archiveArticle = Article(relativePath: filename, fileContents: archiveBody)
	return try archiveArticle.writeAsIndexFile(inDirectory: destinationDirectory.appendingPathComponent(filename, isDirectory: true), fileManager: fileManager)
}

extension String {
	private func prefixForLinksRelativeToRoot(mustBeAbsolute: Bool) -> String {
		mustBeAbsolute ? publishedSiteRoot : "/"
	}

	func htmlWithLinksRelativeTo(_ path: String, mustBeAbsolute: Bool) -> String {
		// This is really silly (inefficient) way to not change external URLs and URLs relative to root already. (Replace them then replace them back.)
		// Limitation: This requires no spaces around the `=` which is not required by HTML.
		replacing("src=\"", with: "src=\"\(path)")
		.replacing("href=\"", with: "href=\"\(path)")
		.replacing("src=\"\(path)http", with: "src=\"http")
		.replacing("href=\"\(path)http", with: "href=\"http")
		.replacing("src=\"\(path)/", with: "src=\"\(prefixForLinksRelativeToRoot(mustBeAbsolute: mustBeAbsolute))")
		.replacing("href=\"\(path)/", with: "href=\"\(prefixForLinksRelativeToRoot(mustBeAbsolute: mustBeAbsolute))")
	}

	func markdownWithLinksRelativeTo(_ path: String, mustBeAbsolute: Bool) -> String {
		replacing("](", with: "](\(path)")
		.replacing("](\(path)http", with: "](http")
		.replacing("](\(path)/", with: "](\(prefixForLinksRelativeToRoot(mustBeAbsolute: mustBeAbsolute))")
		.htmlWithLinksRelativeTo(path, mustBeAbsolute: mustBeAbsolute)
	}
}

struct Article {

	struct Title {
		let plainText: String
		let markdown: String
		let html: String

		init?(title: MarkdownText?, subtitle: MarkdownText?) {
			guard let title else {
				precondition(subtitle == nil, "Article has a subtitle but not a title.")
				return nil
			}
			if let subtitle {
				markdown = "\(title.markdown): \(subtitle.markdown)"
				plainText = "\(title.plainText): \(subtitle.plainText)"
				html = Document(parsing: """
				# \(title.markdown)

				## \(subtitle.markdown)
				""", options: [.disableSmartOpts]).html
			} else {
				markdown = title.markdown
				plainText = title.plainText
				html = Document(parsing: "# \(title.markdown)", options: [.disableSmartOpts]).html
			}
		}
	}

	struct MarkdownText {
		let plainText: String
		let markdown: String

		init?(_ markdown: String?) {
			guard let markdown else {
				return nil
			}
			self.markdown = markdown
			plainText = Document(parsing: markdown, options: [.disableSmartOpts]).plainText
		}
	}

    enum ArticleType {
        case short
        case long
        case external
    }

	let relativePath: String
	let title: Title?
	let description: MarkdownText?
	let microPost: MarkdownText?
	let rawDate: String?
	let rawTime: String?
	let skipByline: Bool
	let externalURL: String?
	let partialHTML: String
	let characterCount: Int
	let tweetIDs: [String]?
	let tumblrIDs: [String]?
    let type: ArticleType

	init(relativePath: String, fileContents: String) {
		let components = fileContents.components(separatedBy: "%%%")
		precondition(components.count == 2)

		var info: [String: String] = [:]
		for line in components[0].components(separatedBy: .newlines) {
			if line.trimmingCharacters(in: .whitespaces).isEmpty {
				continue
			}

			guard let separatorRange = line.range(of: ":") else {
				preconditionFailure("Separator “:” not found in \(line)")
			}
			let key = line[..<separatorRange.lowerBound]
			let value = line[separatorRange.upperBound...]

			info[key.trimmingCharacters(in: .whitespaces)] = value.trimmingCharacters(in: .whitespaces)
		}

		let markdownString = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
		let markdownDocument = Markdown.Document(parsing: markdownString, options: [.disableSmartOpts])

		self.relativePath = relativePath
		title = Title(title: MarkdownText(info["title"]), subtitle: MarkdownText(info["subtitle"]))
		description = MarkdownText(info["description"])
		microPost = MarkdownText(info["micro"])
		rawDate = info["date"]
		rawTime = info["time"]
		skipByline = info["skipByline"] == "true"
		externalURL = info["externalURL"]
		partialHTML = markdownDocument.html.appending("\n")
		// TODO: Skip calculating this if not needed (archive page articles and ones without dates).
		characterCount = numberOfTextCharactersInHTMLString(partialHTML)
		tweetIDs = info["tweet"]?.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
		tumblrIDs = info["tumblr"]?.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }

        if externalURL != nil {
            if title != nil {
                type = .external
            } else {
                fatalError("External article has no title.")
            }
        } else if title != nil {
            if characterCount > 2480 {
                type = .long
            } else {
                type = .short
            }
        } else {
            type = .short
        }
	}

	var relativeURL: String {
		externalURL ?? (relativePath.isEmpty ? "/" : "/\(relativePath)/")
	}

	var publishedURLString: String {
		externalURL ?? (relativePath.isEmpty ? publishedSiteRoot : "\(publishedSiteRoot)\(relativePath)/")
	}

	var dateComponents: DateComponents? {
		guard let rawDate = rawDate else {
			return nil
		}

		let dateComponentsArray = rawDate.components(separatedBy: "-")
		precondition(dateComponentsArray.count == 3, "Bad date format \(rawDate)")

		var dateComponents = DateComponents()
		dateComponents.year = Int(dateComponentsArray[0])
		dateComponents.month = Int(dateComponentsArray[1])
		dateComponents.day = Int(dateComponentsArray[2])

		return dateComponents
	}

	private var formattedDate: String? {
		dateComponents?.formattedHowILike
	}

	private var dateHTML: String {
		// Avoid using a span here because if there is a span in the byline then Safari Reader adds a bullet after this span.
		formattedDate == nil ? "" : """
		 • <time datetime="\(rawDate!)">\(formattedDate!)</time>
		"""
	}

	private var bylineHTML: String {
		skipByline ? "" : """
		<p class="byline"><a href="/">\(author)</a>\(dateHTML)</p>
		"""
	}

	// TODO: Use a nicer title for short posts that don’t have their own title.

	var standaloneHTML: String {
		return """
		<!DOCTYPE html>
		<html lang="en">
		<head>
			<meta charset="utf-8"/>
			<title>\(title?.plainText ?? author)</title>

		"""
		+ (description == nil ? "" : """
			<meta name="description" content="\(description!.plainText)" />

		""")
		+ """
			<meta name="twitter:creator" content="@qdoug" />
			<meta name="author" content="\(author)">
			<meta property="og:site_name" content="\(author)" />
			<meta name="viewport" content="width=device-width, maximum-scale=1.0" />
			<link href="https://micro.blog/douglas" rel="me" />
			<link rel="stylesheet" type="text/css" href="/post-style.css" />
			<link rel="alternate" type="application/json" href="/feed.json" />
			<link rel="canonical" href="\(publishedURLString)">
		</head>
		<body>
			<article>
				<header>

		"""
		+ (title == nil ? "" : """
							\(title!.html)

				""")
				+ """
					\(bylineHTML)
				</header>

		\(partialHTML)
			</article>

		"""
		+ """
		</body>
		</html>

		"""
	}

	func writeAsIndexFile(inDirectory dir: URL, fileManager: FileManager) throws -> URL {
		try writeIndexHTML(standaloneHTML, inDirectory: dir, fileManager: fileManager)
	}

	func writeRedirectFile(inDirectory dir: URL, fileManager: FileManager) throws -> URL {
		let redirectHTMLContents = """
		<!DOCTYPE html>
		<html lang="en">
		<head>
			<meta charset="utf-8">
			<title>Redirecting…</title>
			<meta http-equiv="refresh" content="0; URL=\(relativeURL)">
			<link rel="canonical" href="\(publishedURLString)">
		</head>
		<body>
			<p>Redirecting to <a href="\(relativeURL)">\(externalURL ?? relativePath)</a></p>
		</body>
		</html>

		"""
		return try writeIndexHTML(redirectHTMLContents, inDirectory: dir, fileManager: fileManager)
	}
}

private func writeIndexHTML(_ htmlString: String, inDirectory dir: URL, fileManager: FileManager) throws -> URL {
	try fileManager.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
	let indexFileURL = dir.appendingPathComponent("index.html", isDirectory: false)

	let oldData = try? Data(contentsOf: indexFileURL)
	let newData = htmlString.data(using: .utf8)!

	if newData != oldData {
		print("Writing to \(indexFileURL.path)")
		try newData.write(to: indexFileURL)
	} else {
		logDebug("Unchanged so skipping writing to \(indexFileURL.path)")
	}

	return indexFileURL
}

/// Basic count of user-facing text. HTML collapses whitespace into a single space except in pre tags. That’s not implemented.
private func numberOfTextCharactersInHTMLString(_ htmlString: String) -> Int {
	var count = 0

    let scanner = Scanner(string: htmlString)
    scanner.charactersToBeSkipped = CharacterSet()

    while true {
        if var newText = scanner.scanUpToString("<") {
			// Just replace all entities with a single character.
			let regex = try! Regex("&\\w+;")
    		newText.replace(regex) { match in
        		"x"
    		}

			count += newText.count
        }

        if scanner.scanPastString(">") == nil {
            break
        }
    }

    logDebug("Number of text characters is \(count).")
    return count
}

private extension Scanner {
    func scanPastString(_ substring: String) -> String? {
        if let result = scanUpToString(substring) {
            let scanned = scanString(substring)
            precondition(scanned == substring)
            return result + scanned!
        } else {
            return nil
        }
    }
}

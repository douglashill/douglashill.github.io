// Douglas Hill, January 2018

import CoreFoundation
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
		return components.joined(separator: " ")
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

let publishedSiteDomain = "https://douglashill.co"
let publishedSiteRoot = "\(publishedSiteDomain)/"
let author = "Douglas Hill"
let iso8601DateFormatter = ISO8601DateFormatter()

// Creating this Regex once instead of every time we need it cut the time spent creating and using it from 900 ms to 300 ms.
let htmlEntityRegex = try! Regex("&\\w+;")
// First find [. Then capture at least one of any characters except ] so the matching is not greedy. Then find ]().
let selfLinkRegex = try! Regex("\\[([^\\]]+)\\]\\(\\)")

func autocompletion() {
	let startTime = CFAbsoluteTimeGetCurrent()

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

	var allTweetIDs: Set<String> = []

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

			if let tweetIDs = article.tweetIDs {
				for tweetID in tweetIDs {
					precondition(allTweetIDs.contains(tweetID) == false, "Duplicate tweet ID: \(tweetID)")
					allTweetIDs.insert(tweetID)
				}
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

	print("Enumerated files in \(CFAbsoluteTimeGetCurrent() - startTime)s.")

	articlesWithDates.sort {
		if $0.date! == $1.date! {
			fatalError("Articles have same date/time: \($0.relativePath) and \($1.relativePath)")
		} else {
			return $0.date! > $1.date!
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

	if let firstYear = articlesWithDates.last?.dateComponents!.year!, let lastYear = articlesWithDates.first?.dateComponents!.year! {
		let allYears = firstYear...lastYear

		// Generate long articles archive page.
		let archiveOutputFileURL = try! writeArchive(fromSortedArticles: articlesWithDates.filter { $0.type != .short }, years: allYears, title: "[\(author)](/)’s archive", toDestinationDirectory: destinationDirectory, filename: "archive", fileManager: fileManager) {
			// This will break if the title Markdown has a link in it, but long articles should not be link posts.
			var string = "[\($0.title!.markdown)](\($0.relativeURL))"

			if let description = $0.description {
				if CharacterSet.punctuationCharacters.contains($0.title!.plainText.unicodeScalars.last!) == false {
					string.append(":")
				}

				// Remove self links (which are used for the micro archive and feed) because the title will already be a link to this article.
				let descriptionMarkdown = description.markdown.replacing(selfLinkRegex) { match in
					match.output[1].substring!
				}

				string.append(" \(descriptionMarkdown.markdownWithLinksRelativeTo($0.relativeURL, mustBeAbsolute: false))")
			}

			// This is mostly included because the Nutrient website doesn’t show publication dates.
			// TODO: Make these dates look better. Maybe hang in the margin.
			var dateComponents = $0.dateComponents!
			dateComponents.year = nil
			string.append(" <time class=\"tertiary\" datetime=\"\($0.rawDateWithoutTime!)\">\(dateComponents.formattedHowILike)</time>")

			return string
		}
		outputFiles.insert(archiveOutputFileURL)

		let microArticleFormatter: (Article) -> String = {
			// TODO: Maybe share with micro feed by adding a method on Article.
			let explicitShortText = $0.microPost?.markdown ?? $0.description?.markdown
			if explicitShortText != nil || ($0.title != nil && $0.characterCount + ($0.title?.plainText.count ?? 0) > 290) {
				let microPost: String
				if let explicitShortText {
					// Add a link to self at the end, but if there is already one somewhere in the text then just make it » without the Read more.
					let maybeReadMore = explicitShortText.contains("]()") ? "" : "Read more "
					microPost = "\(explicitShortText) <a href=\"\" title=\"\($0.title?.plainText ?? "")\">\(maybeReadMore)»</a>"
				} else {
					// Just a title. Make the whole thing a link to self.
					// If the title contains a link. Fall back to the plain text of the title.
					// Technically Markdown allows whitespace between the ] and ( but just don’t do that.
					let title = $0.title!
					let titleMarkdown = title.markdown.contains("](") ? title.plainText : title.markdown
					microPost = "[\(titleMarkdown) »]()"
				}
				return microPost.markdownWithLinksRelativeTo($0.relativeURL, mustBeAbsolute: false)
			} else {
				var partialHTML = $0.partialHTML.htmlWithLinksRelativeTo($0.relativeURL, mustBeAbsolute: false)
				if let title = $0.title {
					partialHTML = "\(title.markdown.markdownWithLinksRelativeTo($0.relativeURL, mustBeAbsolute: false))\n\n\(partialHTML)"
				}
				let endingsWithInlinePermalinks = ["</p>\n", "</li>\n</ul>\n", "</li>\n</ol>\n", "</p>\n</blockquote>\n"]
				for ending in endingsWithInlinePermalinks {
					// Hacky way to not put the permalink inline after a video (which would make it not be visible).
					if partialHTML.hasSuffix(ending) && partialHTML.hasSuffix("controls preload=\"none\" /></p>\n") == false && partialHTML.hasSuffix("controls width=\"100%\" /></p>\n") == false {
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

		let followHTML = "<a href=\"/follow/\">Follow/subscribe</a> for updates"

		// Generate micro archive page for recent posts.
		let recentOutputFileURL = try! writeMicroArchive(fromSortedArticles: articlesWithDates.prefix(20), sectionGranularity: [.year, .month, .day], title: "[\(author)](/)’s recent posts", toDestinationDirectory: destinationDirectory, filename: "recent", htmlPrefix: followHTML, htmlSuffix: "More in the <a href=\"/archive/\">archive</a>", fileManager: fileManager, articleFormatter: microArticleFormatter)
		outputFiles.insert(recentOutputFileURL)

		// Generate micro archive pages for each year.
		var articlesByYear: [Int: [Article]] = [:]
		for article in articlesWithDates {
			let year = article.dateComponents!.year!
			var articlesForThisYear = articlesByYear[year] ?? []
			articlesForThisYear.append(article)
			articlesByYear[year] = articlesForThisYear
		}
		for year in allYears {
			logDebug("Number of posts in \(year): \(articlesByYear[year]!.count)")

			let previousYear = year - 1
			let followingYear = year + 1
			let prefix = allYears.contains(previousYear) ? "<a href=\"/\(previousYear)/\">↑ \(previousYear)</a>" : ""
			let suffix = allYears.contains(followingYear) ? "<a href=\"/\(followingYear)/\">↓ \(followingYear)</a>" : followHTML

			let outputFileURL = try! writeMicroArchive(fromSortedArticles: articlesByYear[year]!.reversed(), sectionGranularity: [.year, .month, .day], title: "[\(author)](/)’s posts in \(year)", toDestinationDirectory: destinationDirectory, filename: "\(year)", htmlPrefix: prefix, htmlSuffix: suffix, fileManager: fileManager, articleFormatter: microArticleFormatter)
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

	print("Wrote files after \(CFAbsoluteTimeGetCurrent() - startTime)s.")

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

	print("Finished after \(CFAbsoluteTimeGetCurrent() - startTime)s.")
}

func writeFeed(fromSortedArticles articles: ArraySlice<Article>, isMicro isMicroFeed: Bool, toDestinationDirectory destinationDirectory: URL, filename: String) throws -> URL {
	let feedItems: [[String: String]] = articles.map { article -> [String: String] in
		var item = [
			"id": article.publishedURLString,
			"url": article.publishedURLString,
			"date_published": article.rawDate!,
		]

		// TODO: Support link posts in feeds. That is, where the title contains a Markdown link. It might be better to have a separate field for the link.

		if isMicroFeed {
			let contentHTML: String
			if let microPost = article.microPost?.markdown ?? article.description?.markdown {
				if microPost.contains("]()") {
					// Already has a link to self.
					contentHTML = Document(parsing: microPost, options: [.disableSmartOpts]).html
				} else {
					// No link to self. Add one at the end.
					contentHTML = Document(parsing: "\(microPost) [Read more »]()", options: [.disableSmartOpts]).html
				}
			} else if let title = article.title {
				// Just a title. Make the whole thing a link to self.
				// If the title contains a link. Fall back to the plain text of the title.
				// Technically Markdown allows whitespace between the ] and ( but just don’t do that.
				let titleMarkdown = title.markdown.contains("](") ? title.plainText : title.markdown
				contentHTML = Document(parsing: "[\(titleMarkdown)]()", options: [.disableSmartOpts]).html
			} else {
				contentHTML = article.partialHTML
			}
			// Micro.blog doesn’t work with relative URLs, so make them absolute.
			item["content_html"] = contentHTML.htmlWithLinksRelativeTo(article.relativeURL, mustBeAbsolute: true)
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

func writeArchive(fromSortedArticles articles: [Article], years: ClosedRange<Int>, title: String, toDestinationDirectory destinationDirectory: URL, filename: String, fileManager: FileManager, articleFormatter: (Article) -> String) throws -> URL {
	var articlesByYear: [Int: [Article]] = [:]
	for article in articles {
		let year = article.dateComponents!.year!
		var articlesForThisYear = articlesByYear[year] ?? []
		articlesForThisYear.append(article)
		articlesByYear[year] = articlesForThisYear
	}

	var archiveBody = """
	title: \(title)
	%%%

	This page lists longer, more considered articles. You can also see [recent posts](/recent/) or use the year heading links to see all posts in each year. [Follow/subscribe](/follow/) for updates.
	"""

	for year in years.reversed() {
		archiveBody.append("\n\n## [\(year)](/\(year)/)")

		for article in articlesByYear[year] ?? [] {
			archiveBody.append("\n\n\(articleFormatter(article))")
		}
	}

	let archiveArticle = Article(relativePath: filename, fileContents: archiveBody)
	return try archiveArticle.writeAsIndexFile(inDirectory: destinationDirectory.appendingPathComponent(filename, isDirectory: true), fileManager: fileManager)
}

func writeMicroArchive(fromSortedArticles articles: any RandomAccessCollection<Article>, sectionGranularity: Set<Calendar.Component>, title: String, toDestinationDirectory destinationDirectory: URL, filename: String, htmlPrefix: String, htmlSuffix: String, fileManager: FileManager, articleFormatter: (Article) -> String) throws -> URL {
	var archiveBody = """
	title: \(title)
	%%%

	<p class="centred">\(htmlPrefix)</p>
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

	archiveBody.append("""


<p class="centred">\(htmlSuffix)</p>
""")

	let archiveArticle = Article(relativePath: filename, fileContents: archiveBody)
	return try archiveArticle.writeAsIndexFile(inDirectory: destinationDirectory.appendingPathComponent(filename, isDirectory: true), fileManager: fileManager)
}

extension String {
	private func prefixForLinksRelativeToRoot(mustBeAbsolute: Bool) -> String {
		mustBeAbsolute ? publishedSiteRoot : "/"
	}

	private static let shpCharacterSet = CharacterSet(["s", "h", "p"])

	func htmlWithLinksRelativeTo(_ path: String, mustBeAbsolute: Bool) -> String {
		var output = ""

		let scanner = Scanner(string: self)
		scanner.charactersToBeSkipped = nil

		// TODO: Only match src or href that are actual attributes. E.g. not text in a pre or code element. Need to scan < etc.
		// This would be a lot nicer with a proper HTML parser like HTML Tidy.

		while true {
			if let scanned = scanner.scanUpToCharacters(from: Self.shpCharacterSet) {
				output.append(scanned)
			}

			if scanner.isAtEnd {
				break
			}

			if let scanned = scanner.scanString("src") ?? scanner.scanString("href") ??  scanner.scanString("poster") {
				output.append(scanned)
				if let scanned = scanner.scanString("=") {
					output.append(scanned)
					if let scanned = scanner.scanString("\"") {
						output.append(scanned)
						// Fallback to empty string if the URL is empty (so we get nil). That means this is a link to ‘self’.
						// TODO: Handle escaped quotation marks, which would be treated as quotation marks as part of the URL.
						let url = scanner.scanUpToString("\"") ?? ""
						if scanner.isAtEnd {
							fatalError("Found end of string in middle of URL.")
						}
						if url.hasPrefix("/") {
							if mustBeAbsolute {
								output.append("\(publishedSiteDomain)\(url)")
							} else {
								output.append(url)
							}
						} else if url.hasPrefix("http") {
							// TODO: This will break if a path component starts with http so it’s really a relative URL.
							output.append(url)
						} else {
							if mustBeAbsolute {
								output.append(publishedSiteDomain)
							}
							output.append(path)
							output.append(url)
						}
						output.append(scanner.scanString("\"")!)
					}
				}
			} else if scanner.scanString("s") != nil {
				// An s that’s not the start of src. Just continue.
				output.append("s")
			} else if scanner.scanString("h") != nil {
				// An h that’s not the start of href. Just continue.
				output.append("h")
			} else if scanner.scanString("p") != nil {
				// A p that’s not the start of poster. Just continue.
				output.append("p")
			} else {
				fatalError("Scanned up to an s, h or p but then couldn’t scan either an s, h or p.")
			}
		}

		return output
	}

	func markdownWithLinksRelativeTo(_ path: String, mustBeAbsolute: Bool) -> String {
		// Replacing then replace back is an inefficient way to not change external URLs and URLs relative to root already.
		// This would be faster using `Scanner` like the method for HTML above, but this function is under 4% of the execution time, so this wouldn’t be a big saving.
		// It’s OK for this to only handle inline links, not Markdown reference links, because this is only used for the title, description and micro properties, not for post bodies.
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
		// ‘auto’ should only be left here in local builds, not for publishing, but nothing is checking that currently.
		rawDate = info["date"] == "auto" ? iso8601DateFormatter.string(from: Date()) : info["date"]
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

		if let rawDate {
			date = iso8601DateFormatter.date(from: rawDate)!
			rawDateWithoutTime = rawDate[..<rawDate.firstIndex(of: "T")!]
		} else {
			date = nil
			rawDateWithoutTime = nil
		}
	}

	var relativeURL: String {
		externalURL ?? (relativePath.isEmpty ? "/" : "/\(relativePath)/")
	}

	var publishedURLString: String {
		externalURL ?? (relativePath.isEmpty ? publishedSiteRoot : "\(publishedSiteRoot)\(relativePath)/")
	}

	var date: Date?
	var rawDateWithoutTime: Substring?

	var dateComponents: DateComponents? {
		guard let rawDateWithoutTime else {
			return nil
		}

		let dateComponentsArray = rawDateWithoutTime.components(separatedBy: "-")
		precondition(dateComponentsArray.count == 3, "Bad date format \(rawDateWithoutTime)")

		var dateComponents = DateComponents()
		dateComponents.year = Int(dateComponentsArray[0])
		dateComponents.month = Int(dateComponentsArray[1])
		dateComponents.day = Int(dateComponentsArray[2])

		return dateComponents
	}

	private var bylineHTML: String {
		if let formattedDate = dateComponents?.formattedHowILike {
			// Avoid using a span here because if there is a span in the byline then Safari Reader adds a bullet after this span.
			"""
			<p class="byline"><a href="/">\(author)</a> • <time datetime="\(rawDateWithoutTime!)">\(formattedDate)</time></p>
			"""
		} else {
			""
		}
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
			<meta name="fediverse:creator" content="@douglas@pub.douglashill.co" />
			<meta name="twitter:creator" content="@qdoug" />
			<meta name="author" content="\(author)">
			<meta property="og:site_name" content="\(author)" />
			<meta name="viewport" content="width=device-width, maximum-scale=1.0" />
			<link rel="me" href="https://micro.blog/douglas" />
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
			newText.replace(htmlEntityRegex) { match in
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

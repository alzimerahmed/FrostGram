import Foundation
@testable import Models
import Testing

@Test
func uRLInit() {
  let simpleUrl = URL(string: "https://www.google.com", encodePath: true)
  #expect(simpleUrl?.absoluteString == "https://www.google.com")

  let urlWithTrailingSlash = URL(string: "https://www.google.com/", encodePath: true)
  #expect(urlWithTrailingSlash?.absoluteString == "https://www.google.com/")

  let extendedCharPath = URL(
    string: "https://en.wikipedia.org/wiki/Elbbrücken_station", encodePath: true
  )
  #expect(
    extendedCharPath?.absoluteString == "https://en.wikipedia.org/wiki/Elbbr%C3%BCcken_station"
  )

  let extendedCharQuery = URL(string: "http://test.com/blah/city?name=京都市", encodePath: true)
  #expect(
    "http://test.com/blah/city?name=%E4%BA%AC%E9%83%BD%E5%B8%82"
      == extendedCharQuery?.absoluteString
  )

  // Double encoding will happen if you ask to encodePath on an already encoded string
  let alreadyEncodedPath = URL(
    string: "https://en.wikipedia.org/wiki/Elbbr%C3%BCcken_station", encodePath: true
  )
  #expect(
    "https://en.wikipedia.org/wiki/Elbbr%25C3%25BCcken_station"
      == alreadyEncodedPath?.absoluteString
  )
}

@Test
func hTMLStringInit() throws {
  let decoder = JSONDecoder()

  let basicContent = "\"<p>This is a test</p>\""
  var htmlString = try decoder.decode(HTMLString.self, from: Data(basicContent.utf8))
  #expect(htmlString.asRawText == "This is a test")
  #expect(htmlString.htmlValue == "<p>This is a test</p>")
  #expect(htmlString.asMarkdown == "This is a test")
  #expect(htmlString.statusesURLs.count == 0)
  #expect(htmlString.links.count == 0)

  let basicLink = "\"<p>This is a <a href=\\\"https://test.com\\\">test</a></p>\""
  htmlString = try decoder.decode(HTMLString.self, from: Data(basicLink.utf8))
  #expect(htmlString.asRawText == "This is a test")
  #expect(htmlString.htmlValue == "<p>This is a <a href=\"https://test.com\">test</a></p>")
  #expect(htmlString.asMarkdown == "This is a [test](https://test.com)")
  #expect(htmlString.statusesURLs.count == 0)
  #expect(htmlString.links.count == 1)
  #expect(htmlString.links[0].url.absoluteString == "https://test.com")
  #expect(htmlString.links[0].displayString == "test")

  let extendedCharLink = "\"<p>This is a <a href=\\\"https://test.com/goßëña\\\">test</a></p>\""
  htmlString = try decoder.decode(HTMLString.self, from: Data(extendedCharLink.utf8))
  #expect(htmlString.asRawText == "This is a test")
  #expect(htmlString.htmlValue == "<p>This is a <a href=\"https://test.com/goßëña\">test</a></p>")
  #expect(htmlString.asMarkdown == "This is a [test](https://test.com/go%C3%9F%C3%AB%C3%B1a)")
  #expect(htmlString.statusesURLs.count == 0)
  #expect(htmlString.links.count == 1)
  #expect(htmlString.links[0].url.absoluteString == "https://test.com/go%C3%9F%C3%AB%C3%B1a")
  #expect(htmlString.links[0].displayString == "test")

  let alreadyEncodedLink =
    "\"<p>This is a <a href=\\\"https://test.com/go%C3%9F%C3%AB%C3%B1a\\\">test</a></p>\""
  htmlString = try decoder.decode(HTMLString.self, from: Data(alreadyEncodedLink.utf8))
  #expect(htmlString.asRawText == "This is a test")
  #expect(
    "<p>This is a <a href=\"https://test.com/go%C3%9F%C3%AB%C3%B1a\">test</a></p>"
      == htmlString.htmlValue
  )
  #expect(htmlString.asMarkdown == "This is a [test](https://test.com/go%C3%9F%C3%AB%C3%B1a)")
  #expect(htmlString.statusesURLs.count == 0)
  #expect(htmlString.links.count == 1)
  #expect(htmlString.links[0].url.absoluteString == "https://test.com/go%C3%9F%C3%AB%C3%B1a")
  #expect(htmlString.links[0].displayString == "test")
}

@Test
func hTMLStringInit_markdownEscaping() throws {
  let decoder = JSONDecoder()

  let stdMarkdownContent = "\"<p>This [*is*] `a`\\n**test**</p>\""
  var htmlString = try decoder.decode(HTMLString.self, from: Data(stdMarkdownContent.utf8))
  #expect(htmlString.asRawText == "This [*is*] `a`\n**test**")
  #expect(htmlString.htmlValue == "<p>This [*is*] `a`\n**test**</p>")
  #expect(htmlString.asMarkdown == "This \\[\\*is\\*] \\`a\\` \\*\\*test\\*\\*")

  let underscoreContent = "\"<p>This _is_ an :emoji_maybe:</p>\""
  htmlString = try decoder.decode(HTMLString.self, from: Data(underscoreContent.utf8))
  #expect(htmlString.asRawText == "This _is_ an :emoji_maybe:")
  #expect(htmlString.htmlValue == "<p>This _is_ an :emoji_maybe:</p>")
  #expect(htmlString.asMarkdown == "This \\_is\\_ an :emoji_maybe:")

  let strikeContent = "\"<p>This ~is~ a\\n`test`</p>\""
  htmlString = try decoder.decode(HTMLString.self, from: Data(strikeContent.utf8))
  #expect(htmlString.asRawText == "This ~is~ a\n`test`")
  #expect(htmlString.htmlValue == "<p>This ~is~ a\n`test`</p>")
  #expect(htmlString.asMarkdown == "This \\~is\\~ a \\`test\\`")
}

@Test
func hTMLStringInit_lineStartListMarkers() throws {
  let decoder = JSONDecoder()

  let listLikeContent = "\"<p>2025 year review:<br />- 11 accepted and merged pull requests</p>\""
  let htmlString = try decoder.decode(HTMLString.self, from: Data(listLikeContent.utf8))
  #expect(htmlString.asRawText == "2025 year review:\n- 11 accepted and merged pull requests")
  #expect(
    htmlString.asMarkdown == "2025 year review:\n\\- 11 accepted and merged pull requests"
  )
}

@Test
func hTMLStringInit_quoteInlineRemoval() throws {
  let decoder = JSONDecoder()

  // Test that quote-inline paragraphs are removed
  let quoteContent = "\"<p>Normal text</p><p class=\\\"quote-inline\\\">RE: <a href=\\\"https://example.com\\\">quoted post</a></p><p>More text</p>\""
  let htmlString = try decoder.decode(HTMLString.self, from: Data(quoteContent.utf8))
  #expect(htmlString.asRawText == "Normal text\n\nMore text")
  #expect(htmlString.htmlValue == "<p>Normal text</p><p class=\"quote-inline\">RE: <a href=\"https://example.com\">quoted post</a></p><p>More text</p>")
  #expect(htmlString.asMarkdown == "Normal text\n\nMore text")
  #expect(htmlString.links.count == 0) // The link in quote-inline should not be counted
}

@Test
func hTMLStringInit_trailingHashtags() throws {
  let decoder = JSONDecoder()

  // Test that trailing hashtags are detected and removed
  let hashtagContent = "\"<p>This is a test post</p><p><a href=\\\"https://mastodon.social/tags/swift\\\" class=\\\"mention hashtag\\\" rel=\\\"tag\\\">#<span>swift</span></a> <a href=\\\"https://mastodon.social/tags/ios\\\" class=\\\"mention hashtag\\\" rel=\\\"tag\\\">#<span>ios</span></a></p>\""
  let htmlString = try decoder.decode(HTMLString.self, from: Data(hashtagContent.utf8))
  #expect(htmlString.asRawText == "This is a test post")
  #expect(htmlString.hadTrailingTags == true)
  #expect(htmlString.asMarkdown == "This is a test post")
  #expect(htmlString.links.count == 2) // Links are still tracked even though hashtags are removed

  // Test that inline hashtags are NOT removed
  let inlineHashtagContent = "\"<p>This is a <a href=\\\"https://mastodon.social/tags/swift\\\" class=\\\"mention hashtag\\\" rel=\\\"tag\\\">#<span>swift</span></a> test post</p>\""
  let htmlString2 = try decoder.decode(HTMLString.self, from: Data(inlineHashtagContent.utf8))
  #expect(htmlString2.asRawText == "This is a #swift test post")
  #expect(htmlString2.hadTrailingTags == false)
  #expect(htmlString2.asMarkdown == "This is a [#swift](https://mastodon.social/tags/swift) test post")
  #expect(htmlString2.links.count == 1)

  // Test multiple hashtags at the end (like the real example from Mastodon)
  let multipleHashtagsContent = "\"<p>An illustration by Pulitzer-winning political cartoonist Ann Telnaes.</p><p>PS: Fuck Washington Post for forcing her out to appease Trump.</p><p><a href=\\\"https://sfba.social/tags/cartoon\\\" class=\\\"mention hashtag\\\" rel=\\\"nofollow noopener\\\" target=\\\"_blank\\\">#<span>cartoon</span></a> <a href=\\\"https://sfba.social/tags/politicalCartoon\\\" class=\\\"mention hashtag\\\" rel=\\\"nofollow noopener\\\" target=\\\"_blank\\\">#<span>politicalCartoon</span></a> <a href=\\\"https://sfba.social/tags/kakistocracy\\\" class=\\\"mention hashtag\\\" rel=\\\"nofollow noopener\\\" target=\\\"_blank\\\">#<span>kakistocracy</span></a> <a href=\\\"https://sfba.social/tags/Trump\\\" class=\\\"mention hashtag\\\" rel=\\\"nofollow noopener\\\" target=\\\"_blank\\\">#<span>Trump</span></a> <a href=\\\"https://sfba.social/tags/TrumpEpstein\\\" class=\\\"mention hashtag\\\" rel=\\\"nofollow noopener\\\" target=\\\"_blank\\\">#<span>TrumpEpstein</span></a></p>\""
  let htmlString3 = try decoder.decode(HTMLString.self, from: Data(multipleHashtagsContent.utf8))
  #expect(htmlString3.asRawText == "An illustration by Pulitzer-winning political cartoonist Ann Telnaes.\n\nPS: Fuck Washington Post for forcing her out to appease Trump.")
  #expect(htmlString3.hadTrailingTags == true)
  #expect(htmlString3.asMarkdown == "An illustration by Pulitzer-winning political cartoonist Ann Telnaes.\n\nPS: Fuck Washington Post for forcing her out to appease Trump.")
  #expect(htmlString3.links.count == 5) // All hashtag links should still be tracked

  // Test that mixed content in last paragraph is NOT removed
  let mixedContent = "\"<p>This is a test</p><p>Check out <a href=\\\"https://example.com\\\">this link</a> and <a href=\\\"https://mastodon.social/tags/swift\\\" class=\\\"mention hashtag\\\" rel=\\\"tag\\\">#<span>swift</span></a></p>\""
  let htmlString4 = try decoder.decode(HTMLString.self, from: Data(mixedContent.utf8))
  #expect(htmlString4.asRawText == "This is a test\n\nCheck out this link and #swift")
  #expect(htmlString4.hadTrailingTags == false) // Mixed content, so tags are not removed
  #expect(htmlString4.asMarkdown == "This is a test\n\nCheck out [this link](https://example.com) and [#swift](https://mastodon.social/tags/swift)")
  #expect(htmlString4.links.count == 2)
}

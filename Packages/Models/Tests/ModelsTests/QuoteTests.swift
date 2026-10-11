import Foundation
@testable import Models
import Testing

@Test
func quoteDecodingIgnoresInvalidQuotedStatus() throws {
  let decoder = JSONDecoder()
  decoder.keyDecodingStrategy = .convertFromSnakeCase

  let json = """
  {
    "state": "accepted",
    "quoted_status_id": "123",
    "quoted_status": "invalid"
  }
  """

  let quote = try decoder.decode(Quote.self, from: Data(json.utf8))
  #expect(quote.state == .accepted)
  #expect(quote.quotedStatusId == "123")
  #expect(quote.quotedStatus == nil)
}

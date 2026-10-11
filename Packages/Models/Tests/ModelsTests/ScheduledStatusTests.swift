import Foundation
import Models
import XCTest

final class ScheduledStatusTests: XCTestCase {
  private let fixture = """
  {
    "id": "3495",
    "scheduled_at": "2026-03-01T09:00:00.000Z",
    "params": {
      "text": "Test scheduled post",
      "media_ids": null,
      "sensitive": false,
      "visibility": "public",
      "in_reply_to_id": null,
      "language": "en",
      "scheduled_at": "2026-03-01T09:00:00.000Z",
      "idempotency": "abc123",
      "with_rating": false
    },
    "media_attachments": []
  }
  """

  func testDecodeScheduledStatus() throws {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    let status = try decoder.decode(ScheduledStatus.self, from: Data(fixture.utf8))

    XCTAssertEqual(status.id, "3495")
    XCTAssertEqual(status.params?.text, "Test scheduled post")
    XCTAssertEqual(status.params?.visibility, .pub)
    XCTAssertEqual(status.params?.language, "en")
    XCTAssertEqual(status.mediaAttachments?.count, 0)
    // ServerDate parses the ISO 8601 string
    XCTAssertEqual(
      Calendar.current.dateComponents(
        [.year, .month, .day, .hour], from: status.scheduledAt.asDate
      ).hour, 9
    )
  }

  func testDecodeScheduledStatusWithoutParams() throws {
    let json = """
    {"id": "1", "scheduled_at": "2026-03-01T09:00:00.000Z"}
    """
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    let status = try decoder.decode(ScheduledStatus.self, from: Data(json.utf8))
    XCTAssertNil(status.params)
    XCTAssertNil(status.mediaAttachments)
  }
}

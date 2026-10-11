import Foundation
import Models
import NetworkClient
import XCTest

final class ScheduledStatusesTests: XCTestCase {
  func testStatusDataEncodesScheduledAt() throws {
    let date = Date(timeIntervalSince1970: 1_760_000_000)
    let data = StatusData(
      status: "Hello",
      visibility: .pub,
      scheduledAt: MastodonClient.iso8601String(from: date))

    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    let json = try XCTUnwrap(String(data: try encoder.encode(data), encoding: .utf8))
    XCTAssertTrue(json.contains("\"scheduled_at\""), "expected scheduled_at key in \(json)")
    XCTAssertTrue(json.contains("Z"), "expected ISO 8601 date in \(json)")
  }

  func testStatusDataOmitsScheduledAtByDefault() throws {
    let data = StatusData(status: "Hello", visibility: .pub)
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    let json = try XCTUnwrap(String(data: try encoder.encode(data), encoding: .utf8))
    XCTAssertFalse(json.contains("scheduled_at"))
  }

  func testScheduledStatusesEndpointPaths() {
    XCTAssertEqual(ScheduledStatuses.scheduledStatuses.path(), "scheduled_statuses")
    XCTAssertEqual(ScheduledStatuses.scheduledStatus(id: "42").path(), "scheduled_statuses/42")
    XCTAssertEqual(ScheduledStatuses.deleteScheduledStatus(id: "42").path(), "scheduled_statuses/42")
    XCTAssertEqual(
      ScheduledStatuses.updateScheduledStatus(
        id: "42", json: ScheduledStatusUpdateData(scheduledAt: "2026-01-01T00:00:00.000Z")
      ).path(),
      "scheduled_statuses/42")
  }

  func testUpdateEndpointCarriesJSON() {
    let endpoint = ScheduledStatuses.updateScheduledStatus(
      id: "42", json: ScheduledStatusUpdateData(scheduledAt: "2026-01-01T00:00:00.000Z"))
    XCTAssertNotNil(endpoint.jsonValue)
    XCTAssertNil(ScheduledStatuses.scheduledStatuses.jsonValue)
  }

  func testISO8601StringIsFractionalAndUTC() {
    let date = Date(timeIntervalSince1970: 0)
    let string = MastodonClient.iso8601String(from: date)
    XCTAssertTrue(string.hasPrefix("1970-01-01T00:00:00"))
    XCTAssertTrue(string.hasSuffix("Z"))
  }
}

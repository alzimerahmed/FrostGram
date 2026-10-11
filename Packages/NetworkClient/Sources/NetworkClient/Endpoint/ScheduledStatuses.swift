import Foundation
import Models

public enum ScheduledStatuses: Endpoint {
  case scheduledStatuses
  case scheduledStatus(id: String)
  case updateScheduledStatus(id: String, json: ScheduledStatusUpdateData)
  case deleteScheduledStatus(id: String)

  public func path() -> String {
    switch self {
    case .scheduledStatuses:
      "scheduled_statuses"
    case let .scheduledStatus(id):
      "scheduled_statuses/\(id)"
    case let .updateScheduledStatus(id, _):
      "scheduled_statuses/\(id)"
    case let .deleteScheduledStatus(id):
      "scheduled_statuses/\(id)"
    }
  }

  public func queryItems() -> [URLQueryItem]? {
    nil
  }

  public var jsonValue: Encodable? {
    switch self {
    case let .updateScheduledStatus(_, json):
      json
    default:
      nil
    }
  }
}

public struct ScheduledStatusUpdateData: Encodable, Sendable {
  public let scheduledAt: String

  public init(scheduledAt: String) {
    self.scheduledAt = scheduledAt
  }
}

public extension MastodonClient {
  func scheduledStatuses() async throws -> [ScheduledStatus] {
    try await get(endpoint: ScheduledStatuses.scheduledStatuses)
  }

  func updateScheduledStatus(id: String, scheduledAt: Date) async throws -> ScheduledStatus {
    try await put(
      endpoint: ScheduledStatuses.updateScheduledStatus(
        id: id,
        json: ScheduledStatusUpdateData(scheduledAt: Self.iso8601String(from: scheduledAt))
      )
    )
  }

  func deleteScheduledStatus(id: String) async throws -> HTTPURLResponse? {
    try await delete(endpoint: ScheduledStatuses.deleteScheduledStatus(id: id))
  }

  static func iso8601String(from date: Date) -> String {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter.string(from: date)
  }
}

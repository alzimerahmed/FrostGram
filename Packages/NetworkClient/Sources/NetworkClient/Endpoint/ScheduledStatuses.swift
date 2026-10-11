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
    case .scheduledStatus(let id):
      "scheduled_statuses/\(id)"
    case .updateScheduledStatus(let id, _):
      "scheduled_statuses/\(id)"
    case .deleteScheduledStatus(let id):
      "scheduled_statuses/\(id)"
    }
  }

  public func queryItems() -> [URLQueryItem]? {
    nil
  }

  public var jsonValue: Encodable? {
    switch self {
    case .updateScheduledStatus(_, let json):
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

extension MastodonClient {
  public func scheduledStatuses() async throws -> [ScheduledStatus] {
    try await get(endpoint: ScheduledStatuses.scheduledStatuses)
  }

  public func updateScheduledStatus(id: String, scheduledAt: Date) async throws -> ScheduledStatus {
    try await put(
      endpoint: ScheduledStatuses.updateScheduledStatus(
        id: id,
        json: ScheduledStatusUpdateData(scheduledAt: Self.iso8601String(from: scheduledAt))))
  }

  public func deleteScheduledStatus(id: String) async throws -> HTTPURLResponse? {
    try await delete(endpoint: ScheduledStatuses.deleteScheduledStatus(id: id))
  }

  public static func iso8601String(from date: Date) -> String {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter.string(from: date)
  }
}

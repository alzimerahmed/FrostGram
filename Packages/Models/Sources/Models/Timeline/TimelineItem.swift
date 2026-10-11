import Foundation

public enum TimelineItem: Identifiable, Equatable, Sendable {
  case status(Status)
  case gap(TimelineGap)

  public var status: Status? {
    switch self {
    case let .status(status):
      return status
    default:
      return nil
    }
  }

  public var id: String {
    switch self {
    case let .status(status):
      return status.id
    case let .gap(gap):
      return gap.id
    }
  }
}

public struct TimelineGap: Identifiable, Equatable, Sendable {
  public let id: String
  public let sinceId: String
  public let maxId: String
  public var isLoading: Bool = false

  public init(sinceId: String?, maxId: String) {
    let sinceIdStr = sinceId ?? "start"
    id = "gap-\(sinceIdStr)-\(maxId)"
    self.sinceId = sinceId ?? ""
    self.maxId = maxId
  }
}

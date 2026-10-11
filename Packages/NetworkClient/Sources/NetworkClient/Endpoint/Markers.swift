import Foundation

public enum Markers: Endpoint {
  case markers
  case markNotifications(lastReadId: String)
  case markHome(lastReadId: String)

  public func path() -> String {
    "markers"
  }

  public func queryItems() -> [URLQueryItem]? {
    switch self {
    case .markers:
      [
        URLQueryItem(name: "timeline[]", value: "home"),
        URLQueryItem(name: "timeline[]", value: "notifications"),
      ]
    case .markNotifications, .markHome:
      nil
    }
  }

  public var jsonValue: Encodable? {
    switch self {
    case .markers:
      nil
    case let .markNotifications(lastReadId):
      MarkerPayload(notifications: MarkerPayload.Marker(lastReadId: lastReadId), home: nil)
    case let .markHome(lastReadId):
      MarkerPayload(notifications: nil, home: MarkerPayload.Marker(lastReadId: lastReadId))
    }
  }
}

private struct MarkerPayload: Encodable {
  struct Marker: Encodable {
    let lastReadId: String
  }

  let notifications: Marker?
  let home: Marker?
}

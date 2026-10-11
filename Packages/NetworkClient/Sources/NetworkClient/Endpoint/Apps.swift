import Foundation
import Models

private struct InstanceAppRequest: Codable, Sendable {
  let clientName: String
  let redirectUris: String
  let scopes: String
  let website: String
}

public enum Apps: Endpoint {
  case registerApp

  public func path() -> String {
    switch self {
    case .registerApp:
      "apps"
    }
  }

  public func queryItems() -> [URLQueryItem]? {
    nil
  }

  public var jsonValue: Encodable? {
    switch self {
    case .registerApp:
      InstanceAppRequest(
        clientName: AppInfo.clientName, redirectUris: AppInfo.scheme, scopes: AppInfo.scopes,
        website: AppInfo.weblink
      )
    }
  }
}

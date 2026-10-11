import Foundation
import Models

public enum Collections: Endpoint {
  case accountCollections(id: String)
  case collection(id: String)
  case accountInCollections(id: String)

  public func path() -> String {
    switch self {
    case let .accountCollections(id):
      "accounts/\(id)/collections"
    case let .collection(id):
      "collections/\(id)"
    case let .accountInCollections(id):
      "accounts/\(id)/in_collections"
    }
  }

  public func queryItems() -> [URLQueryItem]? {
    nil
  }
}

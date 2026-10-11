import Foundation
import SwiftData
import SwiftUI

@Model public class RecentTag: Equatable {
  public var title: String = ""
  public var lastUse: Date = Date()

  public init(title: String) {
    self.title = title
    lastUse = Date()
  }
}

public extension RecentTag {
  var formattedDate: String {
    DateFormatterCache.shared.createdAtRelativeFormatter.localizedString(
      for: lastUse, relativeTo: Date()
    )
  }
}

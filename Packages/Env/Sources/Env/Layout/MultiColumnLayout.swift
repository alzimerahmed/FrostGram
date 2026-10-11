import SwiftUI

/// Pure decision logic for the iPad/macOS multi-column timeline layout (Gap #2).
public enum MultiColumnLayoutPolicy {
  /// Multi-column is only offered on iPad and macOS (Catalyst) at regular width,
  /// for signed-in users. iPhone and guest mode always stay single-column.
  public static func isAvailable(
    idiom: UIUserInterfaceIdiom,
    horizontalSizeClass: UIUserInterfaceSizeClass,
    isAuth: Bool
  ) -> Bool {
    (idiom == .pad || idiom == .mac)
      && horizontalSizeClass == .regular
      && isAuth
  }
}

/// Which timeline is displayed in the secondary (multi-column) column.
/// Stored as a raw string in `UserDefaults`; mapped to a `TimelineFilter` in the app target.
public enum SecondaryColumnTimeline: String, CaseIterable, Sendable {
  case home
  case local
  case federated
  case trending

  public var title: LocalizedStringKey {
    switch self {
    case .home:
      "timeline.home"
    case .local:
      "timeline.local"
    case .federated:
      "timeline.federated"
    case .trending:
      "timeline.trending"
    }
  }
}

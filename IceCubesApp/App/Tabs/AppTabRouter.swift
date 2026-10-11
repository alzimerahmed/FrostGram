import AppAccount
import Env
import Models
import SwiftUI

/// Decides which tabs/sections the app exposes for the current account state.
/// In guest mode (no authenticated account) the app only offers public,
/// account-free browsing: timeline, explore and settings.
@MainActor
@Observable
final class AppTabRouter {
  private let appAccountsManager: AppAccountsManager

  init(appAccountsManager: AppAccountsManager) {
    self.appAccountsManager = appAccountsManager
  }

  /// True when the current client talks to a server without an auth token.
  var isGuestMode: Bool {
    !appAccountsManager.currentClient.isAuth
  }

  func availableSections(
    horizontalSizeClass: UserSizeClass?,
    localTimelines: [LocalTimeline],
    tagGroups: [TagGroup]
  ) -> [SidebarSections] {
    guard !isGuestMode else {
      return [.loggedOutTabs]
    }
    if horizontalSizeClass == .compact {
      return [.iosTabs]
    } else if UIDevice.current.userInterfaceIdiom == .vision {
      return [.visionOSTabs]
    }
    var sections = SidebarSections.macOrIpadOSSections
    if !localTimelines.isEmpty {
      sections.append(.localTimeline)
    }
    if !tagGroups.isEmpty {
      sections.append(.tagGroup)
    }
    sections.append(.app)
    return sections
  }
}

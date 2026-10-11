import Foundation
import SwiftUI

public extension EnvironmentValues {
  @Entry var isSecondaryColumn: Bool = false
  @Entry var extraLeadingInset: CGFloat = 0
  @Entry var isCompact: Bool = false
  @Entry var isMediaCompact: Bool = false
  @Entry var isCatalystWindow: Bool = false
  @Entry var isModal: Bool = false
  @Entry var isInCaptureMode: Bool = false
  @Entry var isSupporter: Bool = false
  @Entry var isStatusFocused: Bool = false
  @Entry var isHomeTimeline: Bool = false
  @Entry var indentationLevel: UInt = 0
  @Entry var selectedTabScrollToTop: Int = -1
  /// Set to true when rendering inside the Notifications tab
  @Entry var isNotificationsTab: Bool = false
}

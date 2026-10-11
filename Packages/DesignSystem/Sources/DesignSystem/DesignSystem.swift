import Foundation

@MainActor
public extension CGFloat {
  static var layoutPadding: CGFloat {
    Theme.shared.compactLayoutPadding ? 20 : 8
  }

  static let dividerPadding: CGFloat = 2
  static let scrollToViewHeight: CGFloat = 1
  static let statusColumnsSpacing: CGFloat = 8
  static let statusComponentSpacing: CGFloat = 6
  static let secondaryColumnWidth: CGFloat = 400
  static let pollBarHeight: CGFloat = 30
}

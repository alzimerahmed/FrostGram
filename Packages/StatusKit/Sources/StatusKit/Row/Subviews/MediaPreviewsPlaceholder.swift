import DesignSystem
import SwiftUI

/// Placeholder shown in place of a media preview when the image-off /
/// low-data mode is enabled (`UserPreferences.isMediaPreviewsEnabled == false`).
///
/// No network request is made and no video player is created; the attachment
/// can still be opened in the media viewer via the row's context menu.
struct MediaPreviewsPlaceholder: View {
  @Environment(Theme.self) private var theme

  let systemImage: String

  var body: some View {
    Rectangle()
      .fill(theme.secondaryBackgroundColor)
      .overlay {
        Image(systemName: systemImage)
          .foregroundStyle(theme.labelColor.opacity(0.4))
          .font(.title2)
      }
      .overlay(
        RoundedRectangle(cornerRadius: 10)
          .stroke(.gray.opacity(0.35), lineWidth: 1)
      )
  }
}

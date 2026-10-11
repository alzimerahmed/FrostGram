import DesignSystem
import SwiftUI

extension StatusEditor {
  /// Dismissible reminder shown in the composer when attached media lacks alt text.
  @MainActor
  struct AltTextReminderBanner: View {
    @Environment(Theme.self) private var theme

    let onAddAltText: () -> Void
    let onDismiss: () -> Void

    var body: some View {
      HStack(alignment: .top, spacing: 8) {
        Image(systemName: "accessibility")
          .font(.scaledBody)
          .foregroundStyle(theme.tintColor)
          .accessibilityHidden(true)

        VStack(alignment: .leading, spacing: 6) {
          Text("status.editor.alt-text-reminder.message")
            .font(.scaledFootnote)
            .fixedSize(horizontal: false, vertical: true)

          Button(action: onAddAltText) {
            Text("status.editor.alt-text-reminder.add")
              .font(.scaledFootnote.weight(.semibold))
          }
          .buttonStyle(.borderless)
          .tint(theme.tintColor)
        }

        Spacer(minLength: 0)

        Button(action: onDismiss) {
          Image(systemName: "xmark")
            .font(.scaledFootnote)
            .foregroundStyle(.secondary)
        }
        .buttonStyle(.borderless)
        .accessibilityLabel("accessibility.editor.button.alt-text-reminder.dismiss")
      }
      .padding(.horizontal, .layoutPadding)
      .padding(.vertical, 8)
      .background(theme.secondaryBackgroundColor)
      .overlay(alignment: .top) { Divider() }
      .overlay(alignment: .bottom) { Divider() }
    }
  }
}

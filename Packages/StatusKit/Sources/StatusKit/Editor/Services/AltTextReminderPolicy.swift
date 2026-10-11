import Foundation

public extension StatusEditor {
  /// What the composer should do about missing alt text on attached media.
  nonisolated enum AltTextReminderAction: Equatable {
    /// Nothing to remind about (no media, all media described, or reminders off).
    case none
    /// Show a dismissible reminder banner while composing.
    case banner
  }

  /// Pure decision logic for alt-text reminders (Gap #9).
  /// Local-only check: no network calls, no telemetry — the reminder is computed
  /// from the composer state and the user's own preferences.
  nonisolated enum AltTextReminderPolicy {
    /// Reminder to show while composing: a banner when media is attached but
    /// at least one attachment lacks a description and the reminder setting is on.
    /// When `requiresAltText` is on, the hard block in `PostingService` already
    /// prevents posting, so the soft reminder stays out of the way.
    public static func action(
      hasMedia: Bool,
      allMediaHasDescription: Bool,
      isReminderEnabled: Bool,
      requiresAltText: Bool
    ) -> AltTextReminderAction {
      guard hasMedia, !allMediaHasDescription, isReminderEnabled, !requiresAltText else {
        return .none
      }
      return .banner
    }

    /// Pre-post confirmation: when the reminder setting is on and media lacks
    /// descriptions, ask before posting (unless alt text is already required,
    /// in which case posting fails with a hard error anyway).
    public static func shouldConfirmBeforePosting(
      hasMedia: Bool,
      allMediaHasDescription: Bool,
      isReminderEnabled: Bool,
      requiresAltText: Bool
    ) -> Bool {
      guard hasMedia, !allMediaHasDescription, isReminderEnabled, !requiresAltText else {
        return false
      }
      return true
    }
  }
}

import Combine
import Foundation
import Models
import NetworkClient
import SwiftUI

@MainActor
@Observable public class UserPreferences {
  class Storage {
    @AppStorage("preferred_browser") var preferredBrowser: PreferredBrowser = .inAppSafari
    @AppStorage("show_translate_button_inline") var showTranslateButton: Bool = true
    @AppStorage("show_pending_at_bottom") var pendingShownAtBottom: Bool = false
    @AppStorage("show_pending_left") var pendingShownLeft: Bool = false

    @AppStorage("recently_used_languages") var recentlyUsedLanguages: [String] = []
    @AppStorage("social_keyboard_composer") var isSocialKeyboardEnabled: Bool = false

    @AppStorage("use_instance_content_settings") var useInstanceContentSettings: Bool = true
    @AppStorage("app_auto_expand_spoilers") var appAutoExpandSpoilers = false
    @AppStorage("app_auto_expand_media") var appAutoExpandMedia:
      ServerPreferences.AutoExpandMedia = .hideSensitive
    @AppStorage("app_default_post_visibility") var appDefaultPostVisibility:
      Models.Visibility = .pub
    @AppStorage("app_default_reply_visibility") var appDefaultReplyVisibility:
      Models.Visibility = .pub
    @AppStorage("app_default_posts_sensitive") var appDefaultPostsSensitive = false
    @AppStorage("app_require_alt_text") var appRequireAltText = false
    @AppStorage("alt-text-reminder-enabled") var isAltTextReminderEnabled = true
    @AppStorage("autoplay_video") var autoPlayVideo = true
    @AppStorage("media-previews-enabled") var isMediaPreviewsEnabled = true
    @AppStorage("animate_emojis") var animateEmojis = true
    @AppStorage("mute_video") var muteVideo = true
    @AppStorage("preferred_translation_type") var preferredTranslationType = TranslationType
      .useServerIfPossible
    @AppStorage("user_deepl_api_free") var userDeeplAPIFree = true
    @AppStorage("auto_detect_post_language") var autoDetectPostLanguage = true

    @AppStorage("inAppBrowserReaderView") var inAppBrowserReaderView = false

    @AppStorage("haptic_tab") var hapticTabSelectionEnabled = true
    @AppStorage("haptic_timeline") var hapticTimelineEnabled = true
    @AppStorage("haptic_button_press") var hapticButtonPressEnabled = true
    @AppStorage("sound_effect_enabled") var soundEffectEnabled = true

    @AppStorage("show_alt_text_for_media") var showAltTextForMedia = true

    @AppStorage("show_second_column_ipad") var showiPadSecondaryColumn = true

    @AppStorage("multi-column-layout") var isMultiColumnLayoutEnabled = false

    @AppStorage("swipeactions-status-trailing-right") var swipeActionsStatusTrailingRight =
      StatusAction.favorite
    @AppStorage("swipeactions-status-trailing-left") var swipeActionsStatusTrailingLeft =
      StatusAction.boost
    @AppStorage("swipeactions-status-leading-left") var swipeActionsStatusLeadingLeft =
      StatusAction.reply
    @AppStorage("swipeactions-status-leading-right") var swipeActionsStatusLeadingRight =
      StatusAction.none
    @AppStorage("swipeactions-use-theme-color") var swipeActionsUseThemeColor = false
    @AppStorage("swipeactions-icon-style") var swipeActionsIconStyle: SwipeActionsIconStyle =
      .iconWithText

    @AppStorage("requested_review") var requestedReview = false

    @AppStorage("collapse-long-posts") var collapseLongPosts = true

    @AppStorage("share-button-behavior") var shareButtonBehavior:
      PreferredShareButtonBehavior = .linkOnly

    @AppStorage("boost-button-behavior") var boostButtonBehavior:
      PreferredBoostButtonBehavior = .both

    @AppStorage("max_reply_indentation") var maxReplyIndentation: UInt = 7
    @AppStorage("show_reply_indentation") var showReplyIndentation: Bool = true

    @AppStorage("show_account_popover") var showAccountPopover: Bool = true

    @AppStorage("sidebar_expanded") var isSidebarExpanded: Bool = false

    @AppStorage("stream_home_timeline") var streamHomeTimeline: Bool = false
    @AppStorage("full_timeline_fetch") var fullTimelineFetch: Bool = false

    /// Notifications
    @AppStorage("notifications-truncate-status-content")
    var notificationsTruncateStatusContent: Bool = true

    init() {
      prepareTranslationType()
    }

    private func prepareTranslationType() {
      let sharedDefault = UserDefaults.standard
      if let alwaysUseDeepl = (sharedDefault.object(forKey: "always_use_deepl") as? Bool) {
        if alwaysUseDeepl {
          preferredTranslationType = .useDeepl
        }
        sharedDefault.removeObject(forKey: "always_use_deepl")
      }
      #if canImport(_Translation_SwiftUI)
        if #unavailable(iOS 17.4),
           preferredTranslationType == .useApple
        {
          preferredTranslationType = .useServerIfPossible
        }
      #else
        if preferredTranslationType == .useApple {
          preferredTranslationType = .useServerIfPossible
        }
      #endif
    }
  }

  public static let sharedDefault = UserDefaults(suiteName: "group.com.alzimerahmed.FrostGram")
  public static let shared = UserPreferences()
  private let storage = Storage()

  private var client: MastodonClient?

  public var preferredBrowser: PreferredBrowser {
    didSet {
      storage.preferredBrowser = preferredBrowser
    }
  }

  public var showTranslateButton: Bool {
    didSet {
      storage.showTranslateButton = showTranslateButton
    }
  }

  public var pendingShownAtBottom: Bool {
    didSet {
      storage.pendingShownAtBottom = pendingShownAtBottom
    }
  }

  public var pendingShownLeft: Bool {
    didSet {
      storage.pendingShownLeft = pendingShownLeft
    }
  }

  public var pendingLocation: Alignment {
    let fromLeft =
      Locale.current.language.characterDirection == .leftToRight
        ? pendingShownLeft : !pendingShownLeft
    if pendingShownAtBottom {
      if fromLeft {
        return .bottomLeading
      } else {
        return .bottomTrailing
      }
    } else {
      if fromLeft {
        return .topLeading
      } else {
        return .topTrailing
      }
    }
  }

  public var recentlyUsedLanguages: [String] {
    didSet {
      storage.recentlyUsedLanguages = recentlyUsedLanguages
    }
  }

  public var isSocialKeyboardEnabled: Bool {
    didSet {
      storage.isSocialKeyboardEnabled = isSocialKeyboardEnabled
    }
  }

  public var useInstanceContentSettings: Bool {
    didSet {
      storage.useInstanceContentSettings = useInstanceContentSettings
    }
  }

  public var appAutoExpandSpoilers: Bool {
    didSet {
      storage.appAutoExpandSpoilers = appAutoExpandSpoilers
    }
  }

  public var appAutoExpandMedia: ServerPreferences.AutoExpandMedia {
    didSet {
      storage.appAutoExpandMedia = appAutoExpandMedia
    }
  }

  public var appDefaultPostVisibility: Models.Visibility {
    didSet {
      storage.appDefaultPostVisibility = appDefaultPostVisibility
    }
  }

  public var appDefaultReplyVisibility: Models.Visibility {
    didSet {
      storage.appDefaultReplyVisibility = appDefaultReplyVisibility
    }
  }

  public var appDefaultPostsSensitive: Bool {
    didSet {
      storage.appDefaultPostsSensitive = appDefaultPostsSensitive
    }
  }

  public var appRequireAltText: Bool {
    didSet {
      storage.appRequireAltText = appRequireAltText
    }
  }

  /// Remind me to add alt text to media before posting (local-only check, default on).
  public var isAltTextReminderEnabled: Bool {
    didSet {
      storage.isAltTextReminderEnabled = isAltTextReminderEnabled
    }
  }

  public var autoPlayVideo: Bool {
    didSet {
      storage.autoPlayVideo = autoPlayVideo
    }
  }

  /// Image-off / low-data mode: when `false`, timelines show media placeholders
  /// instead of loading remote images and videos.
  public var isMediaPreviewsEnabled: Bool {
    didSet {
      storage.isMediaPreviewsEnabled = isMediaPreviewsEnabled
    }
  }

  public var animateEmojis: Bool {
    didSet {
      storage.animateEmojis = animateEmojis
    }
  }

  public var muteVideo: Bool {
    didSet {
      storage.muteVideo = muteVideo
    }
  }

  public var preferredTranslationType: TranslationType {
    didSet {
      storage.preferredTranslationType = preferredTranslationType
    }
  }

  public var userDeeplAPIFree: Bool {
    didSet {
      storage.userDeeplAPIFree = userDeeplAPIFree
    }
  }

  public var autoDetectPostLanguage: Bool {
    didSet {
      storage.autoDetectPostLanguage = autoDetectPostLanguage
    }
  }

  public var inAppBrowserReaderView: Bool {
    didSet {
      storage.inAppBrowserReaderView = inAppBrowserReaderView
    }
  }

  public var hapticTabSelectionEnabled: Bool {
    didSet {
      storage.hapticTabSelectionEnabled = hapticTabSelectionEnabled
    }
  }

  public var hapticTimelineEnabled: Bool {
    didSet {
      storage.hapticTimelineEnabled = hapticTimelineEnabled
    }
  }

  public var hapticButtonPressEnabled: Bool {
    didSet {
      storage.hapticButtonPressEnabled = hapticButtonPressEnabled
    }
  }

  public var soundEffectEnabled: Bool {
    didSet {
      storage.soundEffectEnabled = soundEffectEnabled
    }
  }

  public var showAltTextForMedia: Bool {
    didSet {
      storage.showAltTextForMedia = showAltTextForMedia
    }
  }

  public var showiPadSecondaryColumn: Bool {
    didSet {
      storage.showiPadSecondaryColumn = showiPadSecondaryColumn
    }
  }

  /// Multi-column timeline layout on iPad/macOS Catalyst instead of a single-column tab stack.
  public var isMultiColumnLayoutEnabled: Bool {
    didSet {
      storage.isMultiColumnLayoutEnabled = isMultiColumnLayoutEnabled
    }
  }

  public var swipeActionsStatusTrailingRight: StatusAction {
    didSet {
      storage.swipeActionsStatusTrailingRight = swipeActionsStatusTrailingRight
    }
  }

  public var swipeActionsStatusTrailingLeft: StatusAction {
    didSet {
      storage.swipeActionsStatusTrailingLeft = swipeActionsStatusTrailingLeft
    }
  }

  public var swipeActionsStatusLeadingLeft: StatusAction {
    didSet {
      storage.swipeActionsStatusLeadingLeft = swipeActionsStatusLeadingLeft
    }
  }

  public var swipeActionsStatusLeadingRight: StatusAction {
    didSet {
      storage.swipeActionsStatusLeadingRight = swipeActionsStatusLeadingRight
    }
  }

  public var swipeActionsUseThemeColor: Bool {
    didSet {
      storage.swipeActionsUseThemeColor = swipeActionsUseThemeColor
    }
  }

  public var swipeActionsIconStyle: SwipeActionsIconStyle {
    didSet {
      storage.swipeActionsIconStyle = swipeActionsIconStyle
    }
  }

  public var requestedReview: Bool {
    didSet {
      storage.requestedReview = requestedReview
    }
  }

  public var collapseLongPosts: Bool {
    didSet {
      storage.collapseLongPosts = collapseLongPosts
    }
  }

  public var shareButtonBehavior: PreferredShareButtonBehavior {
    didSet {
      storage.shareButtonBehavior = shareButtonBehavior
    }
  }

  public var boostButtonBehavior: PreferredBoostButtonBehavior {
    didSet {
      storage.boostButtonBehavior = boostButtonBehavior
    }
  }

  public var maxReplyIndentation: UInt {
    didSet {
      storage.maxReplyIndentation = maxReplyIndentation
    }
  }

  public var showReplyIndentation: Bool {
    didSet {
      storage.showReplyIndentation = showReplyIndentation
    }
  }

  public var showAccountPopover: Bool {
    didSet {
      storage.showAccountPopover = showAccountPopover
    }
  }

  public var isSidebarExpanded: Bool {
    didSet {
      storage.isSidebarExpanded = isSidebarExpanded
    }
  }

  public var streamHomeTimeline: Bool {
    didSet {
      storage.streamHomeTimeline = streamHomeTimeline
    }
  }

  public var fullTimelineFetch: Bool {
    didSet {
      storage.fullTimelineFetch = fullTimelineFetch
    }
  }

  /// Notifications
  public var notificationsTruncateStatusContent: Bool {
    didSet {
      storage.notificationsTruncateStatusContent = notificationsTruncateStatusContent
    }
  }

  public func getRealMaxIndent() -> UInt {
    showReplyIndentation ? maxReplyIndentation : 0
  }

  public enum SwipeActionsIconStyle: String, CaseIterable {
    case iconWithText, iconOnly

    public var description: LocalizedStringKey {
      switch self {
      case .iconWithText:
        "enum.swipeactions.icon-with-text"
      case .iconOnly:
        "enum.swipeactions.icon-only"
      }
    }

    /// Have to implement this manually here due to compiler not implicitly
    /// inserting `nonisolated`, which leads to a warning:
    ///
    ///     Main actor-isolated static property 'allCases' cannot be used to
    ///     satisfy nonisolated protocol requirement
    ///
    public nonisolated static var allCases: [Self] {
      [.iconWithText, .iconOnly]
    }
  }

  public var postVisibility: Models.Visibility {
    if useInstanceContentSettings {
      serverPreferences?.postVisibility ?? .pub
    } else {
      appDefaultPostVisibility
    }
  }

  public func conformReplyVisibilityConstraints() {
    appDefaultReplyVisibility = getReplyVisibility()
  }

  private func getReplyVisibility() -> Models.Visibility {
    getMinVisibility(postVisibility, appDefaultReplyVisibility)
  }

  public func getReplyVisibility(of status: Status) -> Models.Visibility {
    getMinVisibility(getReplyVisibility(), status.visibility)
  }

  private func getMinVisibility(_ vis1: Models.Visibility, _ vis2: Models.Visibility)
    -> Models.Visibility
  {
    let no1 = Self.getIntOfVisibility(vis1)
    let no2 = Self.getIntOfVisibility(vis2)

    return no1 < no2 ? vis1 : vis2
  }

  public var postIsSensitive: Bool {
    if useInstanceContentSettings {
      serverPreferences?.postIsSensitive ?? false
    } else {
      appDefaultPostsSensitive
    }
  }

  public var autoExpandSpoilers: Bool {
    if useInstanceContentSettings {
      serverPreferences?.autoExpandSpoilers ?? true
    } else {
      appAutoExpandSpoilers
    }
  }

  public var autoExpandMedia: ServerPreferences.AutoExpandMedia {
    if useInstanceContentSettings {
      serverPreferences?.autoExpandMedia ?? .hideSensitive
    } else {
      appAutoExpandMedia
    }
  }

  public var notificationsCount: [OauthToken: Int] = [:] {
    didSet {
      for (key, value) in notificationsCount {
        Self.sharedDefault?.set(value, forKey: "push_notifications_count_\(key.createdAt)")
      }
    }
  }

  public var totalNotificationsCount: Int {
    notificationsCount.compactMap { $0.value }.reduce(0, +)
  }

  public func reloadNotificationsCount(tokens: [OauthToken]) {
    notificationsCount = [:]
    for token in tokens {
      notificationsCount[token] =
        Self.sharedDefault?.integer(forKey: "push_notifications_count_\(token.createdAt)") ?? 0
    }
  }

  public var serverPreferences: ServerPreferences?

  public func setClient(client: MastodonClient) {
    self.client = client
    Task {
      await refreshServerPreferences()
    }
  }

  public func refreshServerPreferences() async {
    guard let client, client.isAuth else { return }
    serverPreferences = try? await client.get(endpoint: Accounts.preferences)
  }

  public func markLanguageAsSelected(isoCode: String) {
    var copy = recentlyUsedLanguages
    if let index = copy.firstIndex(of: isoCode) {
      copy.remove(at: index)
    }
    copy.insert(isoCode, at: 0)
    recentlyUsedLanguages = Array(copy.prefix(3))
  }

  public static func getIntOfVisibility(_ vis: Models.Visibility) -> Int {
    switch vis {
    case .direct:
      0
    case .priv:
      1
    case .unlisted:
      2
    case .pub:
      3
    }
  }

  private init() {
    preferredBrowser = storage.preferredBrowser
    showTranslateButton = storage.showTranslateButton
    recentlyUsedLanguages = storage.recentlyUsedLanguages
    isSocialKeyboardEnabled = storage.isSocialKeyboardEnabled
    useInstanceContentSettings = storage.useInstanceContentSettings
    appAutoExpandSpoilers = storage.appAutoExpandSpoilers
    appAutoExpandMedia = storage.appAutoExpandMedia
    appDefaultPostVisibility = storage.appDefaultPostVisibility
    appDefaultReplyVisibility = storage.appDefaultReplyVisibility
    appDefaultPostsSensitive = storage.appDefaultPostsSensitive
    appRequireAltText = storage.appRequireAltText
    isAltTextReminderEnabled = storage.isAltTextReminderEnabled
    autoPlayVideo = storage.autoPlayVideo
    isMediaPreviewsEnabled = storage.isMediaPreviewsEnabled
    animateEmojis = storage.animateEmojis
    preferredTranslationType = storage.preferredTranslationType
    userDeeplAPIFree = storage.userDeeplAPIFree
    autoDetectPostLanguage = storage.autoDetectPostLanguage
    inAppBrowserReaderView = storage.inAppBrowserReaderView
    hapticTabSelectionEnabled = storage.hapticTabSelectionEnabled
    hapticTimelineEnabled = storage.hapticTimelineEnabled
    hapticButtonPressEnabled = storage.hapticButtonPressEnabled
    soundEffectEnabled = storage.soundEffectEnabled
    showAltTextForMedia = storage.showAltTextForMedia
    showiPadSecondaryColumn = storage.showiPadSecondaryColumn
    isMultiColumnLayoutEnabled = storage.isMultiColumnLayoutEnabled
    swipeActionsStatusTrailingRight = storage.swipeActionsStatusTrailingRight
    swipeActionsStatusTrailingLeft = storage.swipeActionsStatusTrailingLeft
    swipeActionsStatusLeadingLeft = storage.swipeActionsStatusLeadingLeft
    swipeActionsStatusLeadingRight = storage.swipeActionsStatusLeadingRight
    swipeActionsUseThemeColor = storage.swipeActionsUseThemeColor
    swipeActionsIconStyle = storage.swipeActionsIconStyle
    requestedReview = storage.requestedReview
    collapseLongPosts = storage.collapseLongPosts
    shareButtonBehavior = storage.shareButtonBehavior
    boostButtonBehavior = storage.boostButtonBehavior
    pendingShownAtBottom = storage.pendingShownAtBottom
    pendingShownLeft = storage.pendingShownLeft
    maxReplyIndentation = storage.maxReplyIndentation
    showReplyIndentation = storage.showReplyIndentation
    showAccountPopover = storage.showAccountPopover
    muteVideo = storage.muteVideo
    isSidebarExpanded = storage.isSidebarExpanded
    notificationsTruncateStatusContent = storage.notificationsTruncateStatusContent
    streamHomeTimeline = storage.streamHomeTimeline
    fullTimelineFetch = storage.fullTimelineFetch
  }
}

extension UInt: @retroactive RawRepresentable {
  public var rawValue: Int {
    Int(self)
  }

  public init?(rawValue: Int) {
    if rawValue >= 0 {
      self.init(rawValue)
    } else {
      return nil
    }
  }
}

import AVFoundation
import Account
import AppAccount
import DesignSystem
import Env
import KeychainSwift
import MediaUI
import NetworkClient
import StatusKit
import SwiftUI
import Timeline

@main
struct IceCubesApp: App {
  @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

  @Environment(\.scenePhase) var scenePhase
  @Environment(\.openWindow) var openWindow

  @State var appAccountsManager = AppAccountsManager.shared
  @State var currentInstance = CurrentInstance.shared
  @State var currentAccount = CurrentAccount.shared
  @State var userPreferences = UserPreferences.shared
  @State var pushNotificationsService = PushNotificationsService.shared
  @State var appIntentService = AppIntentService.shared
  @State var watcher = StreamWatcher.shared
  @State var quickLook = QuickLook.shared
  @State var theme = Theme.shared
  @State var toastCenter = ToastCenter.shared
  @State var onboarding = OnboardingStateMachine(
    defaults: UserPreferences.sharedDefault ?? .standard)

  @State var selectedTab: AppTab = .timeline
  @State var appRouterPath = RouterPath()
  @State private var showOnboarding = false

  @State var isSupporter: Bool = false
  
  @Namespace var namespace

  init() {
    #if DEBUG
      UserDefaults.standard.register(defaults: [
        "com.apple.SwiftUI.GraphReuseLogging": true, // Enable "GraphReuseLogging" by default. The log can be found via - subsystem: "com.apple.SwiftUI" category: "GraphReuse"
        "LogForEachSlowPath": true, // Enable "LogForEachSlowPath" by default. The log can be found via - subsystem: "com.apple.SwiftUI" category: "Invalid Configuration"
      ])
    #endif
  }

  var body: some Scene {
    appScene
    otherScenes
  }

  func handleScenePhase(scenePhase: ScenePhase) {
    switch scenePhase {
    case .background:
      watcher.stopWatching()
    case .active:
      watcher.watch(streams: [.user, .direct])
      UNUserNotificationCenter.current().setBadgeCount(0)
      userPreferences.reloadNotificationsCount(
        tokens: appAccountsManager.availableAccounts.compactMap(\.oauthToken))
      Task {
        await userPreferences.refreshServerPreferences()
      }
    default:
      break
    }
  }

  func refreshPushSubs() {
    PushNotificationsService.shared.requestPushNotifications()
  }

  /// Onboarding is shown on first launch, until the user either browses as a
  /// guest or signs in. Users with an existing account never see it again.
  var needsOnboarding: Bool {
    !onboarding.isCompleted
      && !appAccountsManager.availableAccounts.contains { $0.oauthToken != nil }
  }

  /// Restores the server chosen during guest onboarding: with no logged-in
  /// account, the current (token-less) account points at that server.
  func applyGuestServerIfAvailable() {
    guard !appAccountsManager.availableAccounts.contains(where: { $0.oauthToken != nil }),
      let guestServer = onboarding.guestServer,
      appAccountsManager.currentAccount.server != guestServer
    else { return }
    appAccountsManager.currentAccount = AppAccount(
      server: guestServer,
      accountName: nil,
      oauthToken: nil)
  }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
  func application(
    _: UIApplication,
    didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    try? AVAudioSession.sharedInstance().setCategory(.ambient, options: .mixWithOthers)
    try? AVAudioSession.sharedInstance().setActive(true)
    PushNotificationsService.shared.setAccounts(accounts: AppAccountsManager.shared.pushAccounts)
    Telemetry.setup()
    Telemetry.signal("app.launched")
    return true
  }

  func application(
    _: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    PushNotificationsService.shared.pushToken = deviceToken
    Task {
      PushNotificationsService.shared.setAccounts(accounts: AppAccountsManager.shared.pushAccounts)
      await PushNotificationsService.shared.updateSubscriptions(forceCreate: false)
    }
  }

  func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError _: Error) {}

  func application(_: UIApplication, didReceiveRemoteNotification _: [AnyHashable: Any]) async
    -> UIBackgroundFetchResult
  {
    return .noData
  }
  

  func application(
    _: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession,
    options _: UIScene.ConnectionOptions
  ) -> UISceneConfiguration {
    let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
    if connectingSceneSession.role == .windowApplication {
      configuration.delegateClass = SceneDelegate.self
    }
    return configuration
  }

  override func buildMenu(with builder: UIMenuBuilder) {
    super.buildMenu(with: builder)
    builder.remove(menu: .document)
    builder.remove(menu: .toolbar)
  }
}

import Foundation
import Observation

/// Drives the first-launch onboarding wizard: server picking, guest browsing
/// and sign-in hand-off. Pure state machine — views send events and render
/// the current step. The completed flag and the guest server choice are
/// persisted in the injected `UserDefaults` (app group in production).
@MainActor
@Observable
public final class OnboardingStateMachine {
  public enum Step: Equatable {
    case welcome
    case serverPicker
    case guestBrowsing(server: String)
    case signingIn(server: String)
    case completed
  }

  public enum Event: Equatable {
    case start
    case chooseServer(server: String)
    case browseAsGuest
    case logIn
    case signInCompleted
    case signInCancelled
    case goBack
  }

  static let completedKey = "onboarding_completed"
  static let guestServerKey = "onboarding_guest_server"

  public private(set) var step: Step = .welcome
  public private(set) var selectedServer: String?

  private let defaults: UserDefaults

  public init(defaults: UserDefaults = .standard) {
    self.defaults = defaults
  }

  public var isCompleted: Bool {
    defaults.bool(forKey: Self.completedKey)
  }

  /// The server the user chose to browse as a guest, if any.
  public var guestServer: String? {
    defaults.string(forKey: Self.guestServerKey)
  }

  /// True when the current step can handle a `goBack` event.
  public var canGoBack: Bool {
    switch step {
    case .serverPicker, .signingIn:
      true
    default:
      false
    }
  }

  public func send(_ event: Event) {
    switch event {
    case .start:
      guard step == .welcome else { return }
      step = .serverPicker
    case let .chooseServer(server):
      switch step {
      case .welcome:
        selectedServer = server
        step = .serverPicker
      case .serverPicker:
        selectedServer = server
      default:
        return
      }
    case .browseAsGuest:
      guard let server = selectedServer else { return }
      defaults.set(server, forKey: Self.guestServerKey)
      markCompleted()
      step = .guestBrowsing(server: server)
    case .logIn:
      guard let server = selectedServer else { return }
      step = .signingIn(server: server)
    case .signInCompleted:
      markCompleted()
      selectedServer = nil
      step = .completed
    case .signInCancelled:
      step = .serverPicker
    case .goBack:
      switch step {
      case .serverPicker:
        step = .welcome
      case .signingIn:
        selectedServer = nil
        step = .serverPicker
      default:
        break
      }
    }
  }

  public func markCompleted() {
    defaults.set(true, forKey: Self.completedKey)
  }

  /// Clears all persisted onboarding state (used by tests and debugging).
  public func reset() {
    defaults.removeObject(forKey: Self.completedKey)
    defaults.removeObject(forKey: Self.guestServerKey)
    selectedServer = nil
    step = .welcome
  }
}

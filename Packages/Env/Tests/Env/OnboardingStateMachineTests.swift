@testable import Env
import XCTest

@MainActor
final class OnboardingStateMachineTests: XCTestCase {
  private func makeStateMachine() -> OnboardingStateMachine {
    OnboardingStateMachine(defaults: UserDefaults(suiteName: "onboarding-tests-\(UUID().uuidString)")!)
  }

  func testStartsAtWelcomeAndNotCompleted() {
    let onboarding = makeStateMachine()
    XCTAssertEqual(onboarding.step, .welcome)
    XCTAssertFalse(onboarding.isCompleted)
    XCTAssertNil(onboarding.selectedServer)
  }

  func testStartMovesToServerPicker() {
    let onboarding = makeStateMachine()
    onboarding.send(.start)
    XCTAssertEqual(onboarding.step, .serverPicker)
  }

  func testStartIsIgnoredAfterWelcome() {
    let onboarding = makeStateMachine()
    onboarding.send(.start)
    onboarding.send(.start)
    XCTAssertEqual(onboarding.step, .serverPicker)
  }

  func testChooseServerRecordsSelection() {
    let onboarding = makeStateMachine()
    onboarding.send(.chooseServer(server: "mastodon.social"))
    XCTAssertEqual(onboarding.selectedServer, "mastodon.social")
    XCTAssertEqual(onboarding.step, .serverPicker)
  }

  func testBrowseAsGuestWithoutServerIsIgnored() {
    let onboarding = makeStateMachine()
    onboarding.send(.browseAsGuest)
    XCTAssertEqual(onboarding.step, .welcome)
    XCTAssertFalse(onboarding.isCompleted)
  }

  func testGuestFlowCompletesAndPersistsGuestServer() {
    let onboarding = makeStateMachine()
    onboarding.send(.chooseServer(server: "mas.to"))
    onboarding.send(.browseAsGuest)
    XCTAssertEqual(onboarding.step, .guestBrowsing(server: "mas.to"))
    XCTAssertTrue(onboarding.isCompleted)
    XCTAssertEqual(onboarding.guestServer, "mas.to")
  }

  func testLogInWithoutServerIsIgnored() {
    let onboarding = makeStateMachine()
    onboarding.send(.logIn)
    XCTAssertEqual(onboarding.step, .welcome)
    XCTAssertFalse(onboarding.isCompleted)
  }

  func testLogInMovesToSigningIn() {
    let onboarding = makeStateMachine()
    onboarding.send(.chooseServer(server: "mstdn.social"))
    onboarding.send(.logIn)
    XCTAssertEqual(onboarding.step, .signingIn(server: "mstdn.social"))
    XCTAssertFalse(onboarding.isCompleted)
  }

  func testSignInCancelledReturnsToServerPicker() {
    let onboarding = makeStateMachine()
    onboarding.send(.chooseServer(server: "mstdn.social"))
    onboarding.send(.logIn)
    onboarding.send(.signInCancelled)
    XCTAssertEqual(onboarding.step, .serverPicker)
    XCTAssertFalse(onboarding.isCompleted)
  }

  func testSignInCompletedMarksOnboardingDone() {
    let onboarding = makeStateMachine()
    onboarding.send(.chooseServer(server: "mstdn.social"))
    onboarding.send(.logIn)
    onboarding.send(.signInCompleted)
    XCTAssertEqual(onboarding.step, .completed)
    XCTAssertTrue(onboarding.isCompleted)
    XCTAssertNil(onboarding.selectedServer)
  }

  func testGoBackFromServerPickerReturnsToWelcome() {
    let onboarding = makeStateMachine()
    onboarding.send(.start)
    onboarding.send(.goBack)
    XCTAssertEqual(onboarding.step, .welcome)
  }

  func testGoBackFromSigningInReturnsToServerPicker() {
    let onboarding = makeStateMachine()
    onboarding.send(.chooseServer(server: "mstdn.social"))
    onboarding.send(.logIn)
    onboarding.send(.goBack)
    XCTAssertEqual(onboarding.step, .serverPicker)
    XCTAssertNil(onboarding.selectedServer)
  }

  func testResetClearsPersistedState() {
    let onboarding = makeStateMachine()
    onboarding.send(.chooseServer(server: "mas.to"))
    onboarding.send(.browseAsGuest)
    onboarding.reset()
    XCTAssertEqual(onboarding.step, .welcome)
    XCTAssertFalse(onboarding.isCompleted)
    XCTAssertNil(onboarding.guestServer)
  }
}

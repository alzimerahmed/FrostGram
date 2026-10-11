import Models
@testable import StatusKit
import XCTest

final class AltTextReminderPolicyTests: XCTestCase {
  private func action(
    hasMedia: Bool,
    allMediaHasDescription: Bool,
    isReminderEnabled: Bool = true,
    requiresAltText: Bool = false
  ) -> StatusEditor.AltTextReminderAction {
    StatusEditor.AltTextReminderPolicy.action(
      hasMedia: hasMedia,
      allMediaHasDescription: allMediaHasDescription,
      isReminderEnabled: isReminderEnabled,
      requiresAltText: requiresAltText
    )
  }

  func testNoMediaMeansNoReminder() {
    XCTAssertEqual(
      action(hasMedia: false, allMediaHasDescription: true),
      .none
    )
    XCTAssertEqual(
      action(hasMedia: false, allMediaHasDescription: false),
      .none
    )
  }

  func testAllMediaDescribedMeansNoReminder() {
    XCTAssertEqual(
      action(hasMedia: true, allMediaHasDescription: true),
      .none
    )
  }

  func testMissingDescriptionWithReminderOnShowsBanner() {
    XCTAssertEqual(
      action(hasMedia: true, allMediaHasDescription: false),
      .banner
    )
  }

  func testReminderDisabledMeansNoReminder() {
    XCTAssertEqual(
      action(hasMedia: true, allMediaHasDescription: false, isReminderEnabled: false),
      .none
    )
  }

  func testRequireAltTextSuppressesSoftReminder() {
    // The hard block in PostingService already prevents posting; the soft
    // reminder stays out of the way.
    XCTAssertEqual(
      action(hasMedia: true, allMediaHasDescription: false, requiresAltText: true),
      .none
    )
  }

  func testConfirmBeforePostingWhenReminderOnAndDescriptionMissing() {
    XCTAssertTrue(
      StatusEditor.AltTextReminderPolicy.shouldConfirmBeforePosting(
        hasMedia: true,
        allMediaHasDescription: false,
        isReminderEnabled: true,
        requiresAltText: false
      )
    )
  }

  func testNoConfirmWhenReminderOffOrAllDescribedOrNoMedia() {
    XCTAssertFalse(
      StatusEditor.AltTextReminderPolicy.shouldConfirmBeforePosting(
        hasMedia: true,
        allMediaHasDescription: false,
        isReminderEnabled: false,
        requiresAltText: false
      )
    )
    XCTAssertFalse(
      StatusEditor.AltTextReminderPolicy.shouldConfirmBeforePosting(
        hasMedia: true,
        allMediaHasDescription: true,
        isReminderEnabled: true,
        requiresAltText: false
      )
    )
    XCTAssertFalse(
      StatusEditor.AltTextReminderPolicy.shouldConfirmBeforePosting(
        hasMedia: false,
        allMediaHasDescription: false,
        isReminderEnabled: true,
        requiresAltText: false
      )
    )
  }

  func testNoConfirmWhenAltTextIsRequired() {
    // Hard requirement path throws PostError.missingAltText instead.
    XCTAssertFalse(
      StatusEditor.AltTextReminderPolicy.shouldConfirmBeforePosting(
        hasMedia: true,
        allMediaHasDescription: false,
        isReminderEnabled: true,
        requiresAltText: true
      )
    )
  }
}

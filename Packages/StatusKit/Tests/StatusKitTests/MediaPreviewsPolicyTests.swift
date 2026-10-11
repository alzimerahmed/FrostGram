import StatusKit
import XCTest

@MainActor
final class MediaPreviewsPolicyTests: XCTestCase {
  func testPreviewsLoadWhenEnabled() {
    XCTAssertTrue(MediaPreviewsPolicy.shouldLoadPreviews(isEnabled: true))
  }

  func testPreviewsDoNotLoadInImageOffMode() {
    XCTAssertFalse(MediaPreviewsPolicy.shouldLoadPreviews(isEnabled: false))
  }

  func testVideoAutoplaysWhenBothEnabled() {
    XCTAssertTrue(MediaPreviewsPolicy.shouldAutoPlayVideo(autoPlayEnabled: true, previewsEnabled: true))
  }

  func testVideoDoesNotAutoplayInImageOffMode() {
    XCTAssertFalse(MediaPreviewsPolicy.shouldAutoPlayVideo(autoPlayEnabled: true, previewsEnabled: false))
  }

  func testVideoDoesNotAutoplayWhenAutoplayDisabled() {
    XCTAssertFalse(MediaPreviewsPolicy.shouldAutoPlayVideo(autoPlayEnabled: false, previewsEnabled: true))
  }

  func testPlaceholderSymbolPerAttachmentType() {
    XCTAssertEqual(
      MediaPreviewsPolicy.placeholderSystemImage(for: .image), "photo")
    XCTAssertEqual(
      MediaPreviewsPolicy.placeholderSystemImage(for: .video), "video")
    XCTAssertEqual(
      MediaPreviewsPolicy.placeholderSystemImage(for: .gifv), "video")
    XCTAssertEqual(
      MediaPreviewsPolicy.placeholderSystemImage(for: .audio), "waveform")
    XCTAssertEqual(
      MediaPreviewsPolicy.placeholderSystemImage(for: nil), "photo")
  }
}

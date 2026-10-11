import Env
import XCTest

final class MultiColumnLayoutPolicyTests: XCTestCase {
  func testAvailableOnIpadRegularAuth() {
    XCTAssertTrue(
      MultiColumnLayoutPolicy.isAvailable(
        idiom: .pad, horizontalSizeClass: .regular, isAuth: true
      )
    )
  }

  func testAvailableOnMacRegularAuth() {
    XCTAssertTrue(
      MultiColumnLayoutPolicy.isAvailable(
        idiom: .mac, horizontalSizeClass: .regular, isAuth: true
      )
    )
  }

  func testNotAvailableOnPhone() {
    XCTAssertFalse(
      MultiColumnLayoutPolicy.isAvailable(
        idiom: .phone, horizontalSizeClass: .regular, isAuth: true
      )
    )
    XCTAssertFalse(
      MultiColumnLayoutPolicy.isAvailable(
        idiom: .phone, horizontalSizeClass: .compact, isAuth: true
      )
    )
  }

  func testNotAvailableInCompactWidth() {
    XCTAssertFalse(
      MultiColumnLayoutPolicy.isAvailable(
        idiom: .pad, horizontalSizeClass: .compact, isAuth: true
      )
    )
  }

  func testNotAvailableWhenLoggedOut() {
    XCTAssertFalse(
      MultiColumnLayoutPolicy.isAvailable(
        idiom: .pad, horizontalSizeClass: .regular, isAuth: false
      )
    )
  }

  func testSecondaryColumnTimelineCases() {
    XCTAssertEqual(SecondaryColumnTimeline.allCases.count, 4)
    XCTAssertEqual(SecondaryColumnTimeline(rawValue: "home"), .home)
    XCTAssertNil(SecondaryColumnTimeline(rawValue: "unknown"))
  }
}

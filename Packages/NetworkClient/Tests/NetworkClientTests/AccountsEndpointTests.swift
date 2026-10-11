import NetworkClient
import XCTest

final class AccountsEndpointTests: XCTestCase {
  func testRemoveFollowerPath() {
    XCTAssertEqual(
      Accounts.removeFollower(id: "42").path(),
      "accounts/42/remove_from_followers"
    )
  }

  func testFollowRequestsPaths() {
    XCTAssertEqual(FollowRequests.list.path(), "follow_requests")
    XCTAssertEqual(FollowRequests.accept(id: "7").path(), "follow_requests/7/authorize")
    XCTAssertEqual(FollowRequests.reject(id: "7").path(), "follow_requests/7/reject")
  }
}

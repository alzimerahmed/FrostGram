@testable import Env
import NetworkClient
import SwiftUI
import Testing
import XCTest

@Test
@MainActor
func routerThreadsURL() {
  let router = RouterPath()
  let url = URL(string: "https://www.threads.net/@dimillian")!
  _ = router.handle(url: url)
  #expect(router.path.isEmpty)
}

@Test
@MainActor
func routerLocalStatusURL() {
  let router = RouterPath()
  let client = MastodonClient(
    server: "mastodon.social",
    oauthToken: .init(accessToken: "", tokenType: "", scope: "", createdAt: 0)
  )
  client.addConnections(["mastodon.social"])
  router.client = client
  let url = URL(string: "https://mastodon.social/status/1010384")!
  _ = router.handle(url: url)
  #expect(router.path.first == .statusDetail(id: "1010384"))
}

@Test
@MainActor
func routerRemoteStatusURL() {
  let router = RouterPath()
  let client = MastodonClient(
    server: "mastodon.social",
    oauthToken: .init(accessToken: "", tokenType: "", scope: "", createdAt: 0)
  )
  client.addConnections(["mastodon.social", "mastodon.online"])
  router.client = client
  let url = URL(string: "https://mastodon.online/status/1010384")!
  _ = router.handle(url: url)
  #expect(router.path.first == .remoteStatusDetail(url: url))
}

@Test
@MainActor
func routeRandomURL() {
  let router = RouterPath()
  let url = URL(string: "https://theweb.com/test/test/one")!
  _ = router.handle(url: url)
  #expect(router.path.isEmpty)
}

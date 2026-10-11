import Models
import NetworkClient
@testable import Timeline

actor MockTimelineStatusFetcher: TimelineStatusFetching {
  private let firstPage: [Status]
  private let nextPages: [[Status]]
  private var nextPageCalls: Int = 0

  init(firstPage: [Status], nextPages: [[Status]]) {
    self.firstPage = firstPage
    self.nextPages = nextPages
  }

  func fetchFirstPage(client _: MastodonClient?, timeline _: TimelineFilter) async throws -> [Status] {
    firstPage
  }

  func fetchNewPages(
    client _: MastodonClient?,
    timeline _: TimelineFilter,
    minId _: String,
    maxPages _: Int
  ) async throws -> [Status] {
    []
  }

  func fetchNextPage(
    client _: MastodonClient?,
    timeline _: TimelineFilter,
    lastId _: String,
    offset _: Int
  ) async throws -> [Status] {
    defer { nextPageCalls += 1 }
    guard nextPageCalls < nextPages.count else { return [] }
    return nextPages[nextPageCalls]
  }

  func nextPageCallCount() -> Int {
    nextPageCalls
  }
}

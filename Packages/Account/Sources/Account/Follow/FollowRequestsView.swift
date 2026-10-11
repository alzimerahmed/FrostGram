import DesignSystem
import Env
import Models
import SwiftUI

/// Follow-request audit screen (Gap #8): review pending follow requests and
/// accept or reject them. Reuses `AccountsListRow` with `isFollowRequest: true`
/// so each row gets the accept/reject buttons.
@MainActor
public struct FollowRequestsView: View {
  @Environment(Theme.self) private var theme
  @Environment(CurrentAccount.self) private var currentAccount

  @State private var isInitialLoadDone: Bool = false

  public init() {}

  public var body: some View {
    List {
      if currentAccount.followRequests.isEmpty {
        Text("account.follow-requests.empty")
          .font(.scaledBody)
          .foregroundStyle(.secondary)
          .frame(maxWidth: .infinity, alignment: .center)
          .padding(.vertical, 16)
          #if !os(visionOS)
            .listRowBackground(theme.primaryBackgroundColor)
          #endif
      } else {
        ForEach(currentAccount.followRequests) { account in
          AccountsListRow(viewModel: .init(account: account), isFollowRequest: true)
            #if !os(visionOS)
              .listRowBackground(theme.primaryBackgroundColor)
            #endif
        }
      }
    }
    .listStyle(.plain)
    #if !os(visionOS)
      .scrollContentBackground(.hidden)
      .background(theme.primaryBackgroundColor)
    #endif
    .navigationTitle("account.follow-requests.title")
    .navigationBarTitleDisplayMode(.inline)
    .refreshable {
      await currentAccount.fetchFollowerRequests()
    }
    .task {
      guard !isInitialLoadDone else { return }
      isInitialLoadDone = true
      await currentAccount.fetchFollowerRequests()
    }
  }
}

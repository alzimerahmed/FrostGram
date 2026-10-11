import AppAccount
import DesignSystem
import Env
import Models
import NetworkClient
import SwiftUI

/// First-launch onboarding wizard: pick a Mastodon server, then either browse
/// it as a guest (public API, no account) or hand off to the existing
/// add-account OAuth flow. State is driven by `OnboardingStateMachine` (Env).
@MainActor
struct OnboardingView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(AppAccountsManager.self) private var appAccountsManager
  @Environment(Theme.self) private var theme

  let onboarding: OnboardingStateMachine

  /// Well-known, general-purpose Mastodon servers offered before search.
  private static let curatedServers = [
    "mastodon.social",
    "mas.to",
    "mstdn.social",
    "mastodon.online",
    "mastodon.world",
    "hachyderm.io",
    "fosstodon.org",
    "infosec.exchange",
  ]

  @State private var instances: [InstanceSocial] = []
  @State private var instanceSocialClient = InstanceSocialClient()
  @State private var instance: Instance?
  @State private var isLoadingInstance = false
  @State private var showAddAccount = false
  @State private var searchQuery = ""
  @State private var searchTask: Task<Void, Never>?

  private var selectedServer: String? {
    onboarding.selectedServer
  }

  var body: some View {
    NavigationStack {
      Group {
        switch onboarding.step {
        case .welcome:
          welcomeView
        case .serverPicker, .signingIn:
          if let selectedServer {
            serverDetailView(server: selectedServer)
          } else {
            serverPickerView
          }
        case .guestBrowsing, .completed:
          welcomeView
        }
      }
      #if !os(visionOS)
        .scrollContentBackground(.hidden)
        .background(theme.secondaryBackgroundColor)
      #endif
      .toolbar {
        if onboarding.canGoBack {
          ToolbarItem(placement: .navigationBarLeading) {
            Button {
              withAnimation {
                onboarding.send(.goBack)
                instance = nil
              }
            } label: {
              Label("onboarding.back", systemImage: "chevron.left")
            }
          }
        }
      }
    }
    .sheet(isPresented: $showAddAccount) {
      AddAccountView(initialServer: selectedServer ?? "")
        .withEnvironments()
    }
    .onChange(of: showAddAccount) { _, isShown in
      if !isShown, hasLoggedInAccount {
        onboarding.send(.signInCompleted)
        dismiss()
      }
    }
  }

  private var hasLoggedInAccount: Bool {
    appAccountsManager.availableAccounts.contains { $0.oauthToken != nil }
  }

  // MARK: - Welcome

  private var welcomeView: some View {
    ScrollView {
      VStack(spacing: 24) {
        Image(systemName: "bird")
          .font(.system(size: 64))
          .foregroundStyle(theme.tintColor)
          .padding(.top, 48)
        Text("onboarding.welcome.title")
          .font(.scaledTitle)
          .fontWeight(.bold)
          .multilineTextAlignment(.center)
        Text("onboarding.welcome.message")
          .font(.scaledBody)
          .foregroundStyle(.secondary)
          .multilineTextAlignment(.center)
        Button {
          withAnimation {
            onboarding.send(.start)
          }
        } label: {
          Text("onboarding.welcome.get-started")
            .font(.scaledHeadline)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
        }
        .buttonStyle(.borderedProminent)
        .tint(theme.tintColor)
        .padding(.horizontal, 24)
        Text("onboarding.welcome.guest-hint")
          .font(.scaledFootnote)
          .foregroundStyle(.secondary)
          .multilineTextAlignment(.center)
      }
      .padding(.horizontal, 24)
    }
  }

  // MARK: - Server picker

  private var serverPickerView: some View {
    Form {
      Section("onboarding.server-picker.section.curated") {
        ForEach(Self.curatedServers, id: \.self) { server in
          serverRow(server: server)
        }
      }
      if !instances.isEmpty {
        Section("onboarding.server-picker.section.results") {
          ForEach(instances) { instance in
            serverRow(server: instance.name)
          }
        }
      }
    }
    .formStyle(.grouped)
    .navigationTitle("onboarding.server-picker.title")
    .navigationBarTitleDisplayMode(.inline)
    .searchable(
      text: $searchQuery,
      placement: .navigationBarDrawer(displayMode: .always),
      prompt: Text("onboarding.server-picker.search-placeholder"))
    .onChange(of: searchQuery) {
      searchTask?.cancel()
      let query = searchQuery
      searchTask = Task {
        try? await Task.sleep(for: .milliseconds(250))
        guard !Task.isCancelled else { return }
        let instances = await instanceSocialClient.fetchInstances(keyword: query)
        guard !Task.isCancelled else { return }
        withAnimation {
          self.instances = instances
        }
      }
    }
  }

  // MARK: - Server rows

  private func serverRow(server: String) -> some View {
    Button {
      withAnimation {
        selectServer(server)
      }
    } label: {
      HStack {
        Text(server)
          .font(.scaledBody)
          .foregroundColor(.primary)
        Spacer()
        Image(systemName: "chevron.right")
          .foregroundStyle(.secondary)
      }
    }
    #if !os(visionOS)
      .listRowBackground(theme.primaryBackgroundColor)
    #endif
  }

  // MARK: - Server detail

  private func serverDetailView(server: String) -> some View {
    Form {
      Section {
        Text(server)
          .font(.scaledHeadline)
      }
      #if !os(visionOS)
        .listRowBackground(theme.primaryBackgroundColor)
      #endif
      if let instance {
        InstanceInfoSection(instance: instance)
      } else if isLoadingInstance {
        HStack {
          Spacer()
          ProgressView()
          Spacer()
        }
        #if !os(visionOS)
          .listRowBackground(theme.primaryBackgroundColor)
        #endif
      }
      Section {
        VStack(spacing: 12) {
          Button {
            browseAsGuest()
          } label: {
            Text("onboarding.server-detail.guest-button")
              .font(.scaledHeadline)
              .frame(maxWidth: .infinity)
              .frame(height: 44)
          }
          .buttonStyle(.borderedProminent)
          .tint(theme.tintColor)

          Button {
            onboarding.send(.logIn)
            showAddAccount = true
          } label: {
            Text("onboarding.server-detail.login-button")
              .font(.scaledHeadline)
              .frame(maxWidth: .infinity)
              .frame(height: 44)
          }
          .buttonStyle(.bordered)
          .tint(theme.tintColor)
        }
        .listRowInsets(.init())
        .listRowBackground(Color.clear)
      }
    }
    .formStyle(.grouped)
    .navigationTitle("onboarding.server-detail.title")
    .navigationBarTitleDisplayMode(.inline)
  }

  // MARK: - Actions

  private func selectServer(_ server: String) {
    onboarding.send(.chooseServer(server: server))
    instance = nil
    isLoadingInstance = true
    Task {
      let client = MastodonClient(server: server)
      let fetchedInstance = try? await client.get(endpoint: Instances.instance)
      withAnimation {
        instance = fetchedInstance
        isLoadingInstance = false
      }
    }
  }

  private func browseAsGuest() {
    guard let server = selectedServer else { return }
    onboarding.send(.browseAsGuest)
    appAccountsManager.currentAccount = AppAccount(
      server: server,
      accountName: nil,
      oauthToken: nil)
    dismiss()
  }
}

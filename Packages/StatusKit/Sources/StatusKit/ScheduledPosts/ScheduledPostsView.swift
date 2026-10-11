import DesignSystem
import Env
import Models
import NetworkClient
import SwiftUI

/// Lists the account's scheduled statuses (server-side) and allows rescheduling or deleting them.
public struct ScheduledPostsView: View {
  @Environment(MastodonClient.self) private var client
  @Environment(Theme.self) private var theme
  @Environment(\.scenePhase) private var scenePhase

  @State private var scheduledStatuses: [ScheduledStatus] = []
  @State private var isLoading = false
  @State private var error: String?
  @State private var rescheduling: ScheduledStatus?
  @State private var newScheduleDate = Date()

  public init() {}

  public var body: some View {
    List {
      if let error {
        Text(error)
          .foregroundStyle(.red)
      }
      if isLoading, scheduledStatuses.isEmpty {
        HStack {
          Spacer()
          ProgressView()
          Spacer()
        }
      }
      ForEach(scheduledStatuses) { scheduledStatus in
        scheduledPostRow(scheduledStatus)
      }
    }
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          Task { await fetchScheduledStatuses() }
        } label: {
          Image(systemName: "arrow.clockwise")
            .accessibilityLabel("accessibility.scheduled-posts.refresh")
        }
      }
    }
    .navigationTitle("status.scheduled-posts.navigation-title")
    .navigationBarTitleDisplayMode(.inline)
    .listStyle(.insetGrouped)
    .scrollContentBackground(.hidden)
    .background(theme.primaryBackgroundColor)
    .task {
      await fetchScheduledStatuses()
    }
    .onChange(of: scenePhase) { _, newValue in
      if newValue == .active {
        Task { await fetchScheduledStatuses() }
      }
    }
    .sheet(item: $rescheduling) { scheduledStatus in
      rescheduleSheet(for: scheduledStatus)
    }
  }

  private func scheduledPostRow(_ scheduledStatus: ScheduledStatus) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(scheduledStatus.params?.text ?? "")
        .font(.body)
        .lineLimit(6)
      HStack {
        Label(
          scheduledStatus.scheduledAt.relativeFormatted,
          systemImage: "clock")
          .font(.footnote)
          .foregroundStyle(theme.tintColor)
        Spacer()
        Menu {
          Button("status.scheduled-posts.reschedule") {
            newScheduleDate = scheduledStatus.scheduledAt.asDate
            rescheduling = scheduledStatus
          }
          Button("status.scheduled-posts.delete", role: .destructive) {
            Task {
              await delete(scheduledStatus)
            }
          }
        } label: {
          Image(systemName: "ellipsis.circle")
            .accessibilityLabel("accessibility.scheduled-posts.more")
        }
      }
    }
  }

  private func rescheduleSheet(for scheduledStatus: ScheduledStatus) -> some View {
    NavigationStack {
      Form {
        Section("status.editor.schedule.section") {
          DatePicker("status.editor.schedule.date", selection: $newScheduleDate)
        }
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("action.cancel") {
            rescheduling = nil
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("status.scheduled-posts.reschedule.save") {
            Task {
              await reschedule(scheduledStatus, to: newScheduleDate)
            }
          }
        }
      }
      .navigationTitle("status.scheduled-posts.reschedule.navigation-title")
      .navigationBarTitleDisplayMode(.inline)
      .presentationDetents([.medium, .large])
    }
  }

  private func fetchScheduledStatuses() async {
    guard client.isAuth else { return }
    isLoading = true
    error = nil
    do {
      scheduledStatuses = try await client.scheduledStatuses()
    } catch {
      self.error = error.localizedDescription
    }
    isLoading = false
  }

  private func delete(_ scheduledStatus: ScheduledStatus) async {
    _ = try? await client.deleteScheduledStatus(id: scheduledStatus.id)
    scheduledStatuses.removeAll { $0.id == scheduledStatus.id }
  }

  private func reschedule(_ scheduledStatus: ScheduledStatus, to date: Date) async {
    if let updated = try? await client.updateScheduledStatus(id: scheduledStatus.id, scheduledAt: date) {
      if let index = scheduledStatuses.firstIndex(where: { $0.id == scheduledStatus.id }) {
        scheduledStatuses[index] = updated
      }
    }
    rescheduling = nil
  }
}

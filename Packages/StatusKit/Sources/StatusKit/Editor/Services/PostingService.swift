import Env
import Models
import NetworkClient
import Foundation

extension StatusEditor {
  @MainActor
  struct PostingService {
    @MainActor
    protocol Client {
      func postStatus(data: StatusData) async throws -> Status
      func editStatus(id: String, data: StatusData) async throws -> Status
      func scheduleStatus(data: StatusData, scheduledAt: Date) async throws -> ScheduledStatus
    }

    struct Input {
      var mode: StatusEditor.EditorStore.Mode
      var statusText: String
      var visibility: Models.Visibility
      var spoilerOn: Bool
      var spoilerText: String
      var mediaAttachments: [MediaAttachment]
      var pollOptions: [String]?
      var pollVotingFrequency: PollVotingFrequency
      var pollDuration: Duration
      var selectedLanguage: String?
      var pendingMediaAttributes: [StatusData.MediaAttribute]
      var embeddedStatusId: String?
      var allMediaHasDescription: Bool
      var requiresAltText: Bool
      var scheduledAt: Date? = nil
    }

    func buildStatusData(from input: Input) throws -> StatusData {
      if input.requiresAltText, !input.allMediaHasDescription {
        throw PostError.missingAltText
      }

      var pollData: StatusData.PollData?
      if let pollOptions = input.pollOptions {
        pollData = .init(
          options: pollOptions,
          multiple: input.pollVotingFrequency.canVoteMultipleTimes,
          expires_in: input.pollDuration.rawValue
        )
      }

      return StatusData(
        status: input.statusText,
        visibility: input.visibility,
        inReplyToId: input.mode.replyToStatus?.id,
        spoilerText: input.spoilerOn ? input.spoilerText : nil,
        mediaIds: input.mediaAttachments.map(\.id),
        poll: pollData,
        language: input.selectedLanguage,
        mediaAttributes: input.pendingMediaAttributes,
        quotedStatusId: input.embeddedStatusId
      )
    }

    func submit(
      input: Input,
      client: Client
    ) async throws -> Status {
      let data = try buildStatusData(from: input)
      switch input.mode {
      case .new, .replyTo, .quote, .mention, .shareExtension, .quoteLink, .imageURL:
        let status = try await client.postStatus(data: data)
        StreamWatcher.shared.emmitPostEvent(for: status)
        return status
      case .edit(let status):
        let updated = try await client.editStatus(id: status.id, data: data)
        StreamWatcher.shared.emmitEditEvent(for: updated)
        return updated
      }
    }

    func schedule(
      input: Input,
      client: Client
    ) async throws -> ScheduledStatus {
      guard let scheduledAt = input.scheduledAt else {
        throw PostError.missingScheduleDate
      }
      let data = try buildStatusData(from: input)
      return try await client.scheduleStatus(data: data, scheduledAt: scheduledAt)
    }
  }
}

@MainActor
extension MastodonClient: StatusEditor.PostingService.Client {
  public func postStatus(data: StatusData) async throws -> Status {
    try await post(endpoint: Statuses.postStatus(json: data))
  }

  public func editStatus(id: String, data: StatusData) async throws -> Status {
    try await put(endpoint: Statuses.editStatus(id: id, json: data))
  }

  public func scheduleStatus(data: StatusData, scheduledAt: Date) async throws -> ScheduledStatus {
    let scheduledData = StatusData(
      status: data.status,
      visibility: data.visibility,
      inReplyToId: data.inReplyToId,
      spoilerText: data.spoilerText,
      mediaIds: data.mediaIds,
      poll: data.poll,
      language: data.language,
      mediaAttributes: data.mediaAttributes,
      quotedStatusId: data.quotedStatusId,
      scheduledAt: MastodonClient.iso8601String(from: scheduledAt))
    return try await post(endpoint: Statuses.postStatus(json: scheduledData))
  }
}

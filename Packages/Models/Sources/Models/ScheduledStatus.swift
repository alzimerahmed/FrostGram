import Foundation

/// A status scheduled for a future publication time (Mastodon `ScheduledStatus`).
public struct ScheduledStatus: Codable, Identifiable, Hashable, Sendable {
  public let id: String
  public let scheduledAt: ServerDate
  public let params: Params?
  public let mediaAttachments: [MediaAttachment]?

  public init(id: String, scheduledAt: ServerDate, params: Params?, mediaAttachments: [MediaAttachment]?) {
    self.id = id
    self.scheduledAt = scheduledAt
    self.params = params
    self.mediaAttachments = mediaAttachments
  }

  public struct Params: Codable, Hashable, Sendable {
    public let text: String?
    public let mediaIds: [String]?
    public let sensitive: Bool?
    public let visibility: Visibility?
    public let inReplyToId: String?
    public let language: String?
    public let scheduledAt: ServerDate?
    public let idempotency: String?
    public let withRating: Bool?

    public init(
      text: String?,
      mediaIds: [String]?,
      sensitive: Bool?,
      visibility: Visibility?,
      inReplyToId: String?,
      language: String?,
      scheduledAt: ServerDate?,
      idempotency: String?,
      withRating: Bool?
    ) {
      self.text = text
      self.mediaIds = mediaIds
      self.sensitive = sensitive
      self.visibility = visibility
      self.inReplyToId = inReplyToId
      self.language = language
      self.scheduledAt = scheduledAt
      self.idempotency = idempotency
      self.withRating = withRating
    }
  }
}

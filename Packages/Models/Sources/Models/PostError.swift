import Foundation

public enum PostError: Error {
  /// Throw when any attached media is missing media description (alt text)
  case missingAltText
  /// Throw when scheduling a post without a scheduled date
  case missingScheduleDate
}

extension PostError: CustomStringConvertible {
  public var description: String {
    switch self {
    case .missingAltText:
      return NSLocalizedString(
        "status.error.no-alt-text", comment: "media does not have media description"
      )
    case .missingScheduleDate:
      return NSLocalizedString(
        "status.error.missing-schedule-date", comment: "scheduling a post without a date"
      )
    }
  }
}

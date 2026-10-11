import Foundation
import Models
import PhotosUI
import SwiftUI
import UIKit

extension StatusEditor {
  struct MediaContainer: Identifiable, Sendable {
    let id: String
    let state: MediaState

    enum MediaState: Sendable {
      case pending(content: MediaContent)
      case uploading(content: MediaContent, progress: Double)
      case uploaded(attachment: MediaAttachment, originalImage: UIImage?)
      case failed(content: MediaContent, error: MediaError)
    }

    enum MediaContent: Sendable {
      case image(UIImage)
      case video(MovieFileTranseferable, previewImage: UIImage?)
      case gif(GifFileTranseferable, previewImage: UIImage?)

      var previewImage: UIImage? {
        switch self {
        case let .image(image):
          return image
        case let .video(_, preview):
          return preview
        case let .gif(_, preview):
          return preview
        }
      }
    }

    enum MediaError: Error, LocalizedError, Sendable {
      case compressionFailed
      case uploadFailed(ServerError)
      case invalidFormat
      case sizeLimitExceeded
      case missingAltText
      case cancelled

      var errorDescription: String? {
        switch self {
        case .compressionFailed:
          return "Failed to compress media"
        case let .uploadFailed(error):
          return error.localizedDescription
        case .invalidFormat:
          return "Invalid media format"
        case .sizeLimitExceeded:
          return "Media size exceeds limit"
        case .missingAltText:
          return "Media description is required"
        case .cancelled:
          return "Upload cancelled"
        }
      }
    }

    /// Convenience accessors for backwards compatibility
    var image: UIImage? {
      switch state {
      case let .pending(content), let .uploading(content, _), let .failed(content, _):
        return content.previewImage
      case let .uploaded(_, originalImage):
        return originalImage
      }
    }

    var movieTransferable: MovieFileTranseferable? {
      switch state {
      case let .pending(content), let .uploading(content, _), let .failed(content, _):
        if case let .video(transferable, _) = content {
          return transferable
        }
      case .uploaded:
        break
      }
      return nil
    }

    var gifTransferable: GifFileTranseferable? {
      switch state {
      case let .pending(content), let .uploading(content, _), let .failed(content, _):
        if case let .gif(transferable, _) = content {
          return transferable
        }
      case .uploaded:
        break
      }
      return nil
    }

    var mediaAttachment: MediaAttachment? {
      if case let .uploaded(attachment, _) = state {
        return attachment
      }
      return nil
    }

    var error: Error? {
      if case let .failed(_, error) = state {
        return error
      }
      return nil
    }

    /// Direct initializer for new state-based approach
    init(id: String, state: MediaState) {
      self.id = id
      self.state = state
    }

    /// Factory methods for creating containers
    static func pending(id: String, image: UIImage) -> MediaContainer {
      MediaContainer(id: id, state: .pending(content: .image(image)))
    }

    static func pending(id: String, video: MovieFileTranseferable, preview: UIImage?) -> MediaContainer {
      MediaContainer(id: id, state: .pending(content: .video(video, previewImage: preview)))
    }

    static func pending(id: String, gif: GifFileTranseferable, preview: UIImage?) -> MediaContainer {
      MediaContainer(id: id, state: .pending(content: .gif(gif, previewImage: preview)))
    }

    static func uploading(id: String, content: MediaContent, progress: Double) -> MediaContainer {
      MediaContainer(id: id, state: .uploading(content: content, progress: progress))
    }

    static func uploaded(id: String, attachment: MediaAttachment, originalImage: UIImage?) -> MediaContainer {
      MediaContainer(id: id, state: .uploaded(attachment: attachment, originalImage: originalImage))
    }

    static func failed(id: String, content: MediaContent, error: MediaError) -> MediaContainer {
      MediaContainer(id: id, state: .failed(content: content, error: error))
    }
  }
}

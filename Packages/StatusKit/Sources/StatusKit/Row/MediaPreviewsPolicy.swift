import Foundation
import Models

/// Pure decision logic for the timeline image-off / low-data mode (Phase 4).
///
/// Kept free of SwiftUI and environment state so it can be unit tested.
public enum MediaPreviewsPolicy {
  /// Whether remote media previews should be loaded at all.
  ///
  /// When the user disables media previews (image-off / low-data mode),
  /// timelines render placeholders instead of fetching images or videos.
  public static func shouldLoadPreviews(isEnabled: Bool) -> Bool {
    isEnabled
  }

  /// Whether a video attachment should start playing automatically.
  ///
  /// Autoplay is also suppressed in image-off mode, since a playing video
  /// defeats the purpose of the low-data mode.
  public static func shouldAutoPlayVideo(autoPlayEnabled: Bool, previewsEnabled: Bool) -> Bool {
    autoPlayEnabled && previewsEnabled
  }

  /// SF Symbol used on the placeholder shown when a preview is not loaded.
  public static func placeholderSystemImage(for type: MediaAttachment.SupportedType?) -> String {
    switch type {
    case .gifv, .video:
      "video"
    case .audio:
      "waveform"
    case .image, nil:
      "photo"
    }
  }
}

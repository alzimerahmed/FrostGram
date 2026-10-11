import SwiftUI
import TelemetryDeck

@MainActor
public class Telemetry {
  // Privacy-first: telemetry is disabled until FrostGram has its own
  // TelemetryDeck app ID. Signals are dropped instead of sent upstream.
  private static let appID = ""

  public static func setup() {
    guard !appID.isEmpty else { return }
    let config = TelemetryDeck.Config(appID: appID)
    TelemetryDeck.initialize(config: config)
  }

  public static func signal(_ event: String, parameters: [String: String] = [:]) {
    guard !appID.isEmpty else { return }
    TelemetryDeck.signal(event, parameters: parameters)
  }
}

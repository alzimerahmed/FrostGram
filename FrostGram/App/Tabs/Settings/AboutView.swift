import DesignSystem
import Env
import SwiftUI

@MainActor
struct AboutView: View {
  @Environment(RouterPath.self) private var routerPath
  @Environment(Theme.self) private var theme

  let versionNumber: String

  init() {
    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
      versionNumber = version + " "
    } else {
      versionNumber = ""
    }
  }

  var body: some View {
    List {
      Section {
        #if !targetEnvironment(macCatalyst) && !os(visionOS)
          HStack {
            Spacer()
            Image(uiImage: .init(named: "AppIconAlternate0-image") ?? .init())
              .resizable()
              .frame(width: 50, height: 50)
              .cornerRadius(4)
            Image(uiImage: .init(named: "AppIconAlternate1-image") ?? .init())
              .resizable()
              .frame(width: 50, height: 50)
              .cornerRadius(4)
            Image(uiImage: .init(named: "AppIconAlternate2-image") ?? .init())
              .resizable()
              .frame(width: 50, height: 50)
              .cornerRadius(4)
            Image(uiImage: .init(named: "AppIconAlternate3-image") ?? .init())
              .resizable()
              .frame(width: 50, height: 50)
              .cornerRadius(4)
            Spacer()
          }
        #endif
        Link(
          destination: URL(string: "https://github.com/alzimerahmed/FrostGram/blob/main/PRIVACY.MD")!
        ) {
          Label("settings.support.privacy-policy", systemImage: "lock")
        }

        Link(
          destination: URL(string: "https://github.com/alzimerahmed/FrostGram/blob/main/TERMS.MD")!
        ) {
          Label("settings.support.terms-of-use", systemImage: "checkmark.shield")
        }
      } footer: {
        Text("\(versionNumber)© 2026 Alzimer Ahmed")
      }
      #if !os(visionOS)
        .listRowBackground(theme.primaryBackgroundColor)
      #endif

      Section("Telemetry") {
        Link(destination: .init(string: "https://telemetrydeck.com")!) {
          Label("Telemetry by TelemetryDeck", systemImage: "link")
        }
        Link(destination: .init(string: "https://telemetrydeck.com/privacy/")!) {
          Label("Privacy Policy", systemImage: "checkmark.shield")
        }
      }
      #if !os(visionOS)
        .listRowBackground(theme.primaryBackgroundColor)
      #endif

      Section {
        Text(
          """
          • [EmojiText](https://github.com/divadretlaw/EmojiText)

          • [HTML2Markdown](https://gitlab.com/mflint/HTML2Markdown)

          • [KeychainSwift](https://github.com/evgenyneu/keychain-swift)

          • [LRUCache](https://github.com/nicklockwood/LRUCache)

          • [Bodega](https://github.com/mergesort/Bodega)

          • [Nuke](https://github.com/kean/Nuke)

          • [SwiftSoup](https://github.com/scinfu/SwiftSoup.git)

          • [Atkinson Hyperlegible](https://github.com/googlefonts/atkinson-hyperlegible)

          • [OpenDyslexic](http://opendyslexic.org)

          • [SwiftUI-Introspect](https://github.com/siteline/SwiftUI-Introspect)

          • [SFSafeSymbols](https://github.com/SFSafeSymbols/SFSafeSymbols)
          """
        )
        .multilineTextAlignment(.leading)
        .font(.scaledSubheadline)
        .foregroundStyle(.secondary)
      } header: {
        Text("settings.about.built-with")
          .textCase(nil)
      }
      #if !os(visionOS)
        .listRowBackground(theme.primaryBackgroundColor)
      #endif
    }
    .listStyle(.insetGrouped)
    #if !os(visionOS)
      .scrollContentBackground(.hidden)
      .background(theme.secondaryBackgroundColor)
    #endif
    .navigationTitle(Text("settings.about.title"))
    .navigationBarTitleDisplayMode(.large)
    .environment(
      \.openURL,
      OpenURLAction { url in
        routerPath.handle(url: url)
      })
  }

}

struct AboutView_Previews: PreviewProvider {
  static var previews: some View {
    AboutView()
      .environment(Theme.shared)
  }
}

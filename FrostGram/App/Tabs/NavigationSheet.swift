import AppAccount
import DesignSystem
import Env
import SwiftUI

@MainActor
struct NavigationSheet<Content: View>: View {
  @Environment(\.dismiss) private var dismiss

  @ViewBuilder var content: () -> Content

  var body: some View {
    NavigationStack {
      content()
        .toolbar {
          CloseToolbarItem()
        }
    }
  }
}

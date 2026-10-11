import Env
import SwiftUI

extension IceCubesApp {
  @CommandsBuilder
  var appMenu: some Commands {
    CommandGroup(replacing: .appSettings) {
      Button("menu.settings") {
        appRouterPath.presentedSheet = .settings
      }
      .keyboardShortcut(",", modifiers: .command)
    }
    CommandGroup(replacing: .newItem) {
      Button("menu.new-window") {
        openWindow(id: "MainWindow")
      }
      .keyboardShortcut("n", modifiers: .shift)
      Button("menu.new-post") {
        #if targetEnvironment(macCatalyst)
          openWindow(
            value: WindowDestinationEditor.newStatusEditor(
              visibility: userPreferences.postVisibility))
        #else
          appRouterPath.presentedSheet = .newStatusEditor(
            visibility: userPreferences.postVisibility)
        #endif
      }
      .keyboardShortcut("n", modifiers: .command)
    }
    CommandGroup(replacing: .textFormatting) {
      Menu("menu.font") {
        Button("menu.font.bigger") {
          if theme.fontSizeScale < 1.5 {
            theme.fontSizeScale += 0.1
          }
        }
        Button("menu.font.smaller") {
          if theme.fontSizeScale > 0.5 {
            theme.fontSizeScale -= 0.1
          }
        }
      }
    }
    CommandMenu("tab.timeline") {
      Button("timeline.latest") {
        NotificationCenter.default.post(name: .refreshTimeline, object: nil)
      }
      .keyboardShortcut("r", modifiers: .command)
      Button("timeline.home") {
        NotificationCenter.default.post(name: .homeTimeline, object: nil)
      }
      .keyboardShortcut("h", modifiers: .shift)
      Button("timeline.trending") {
        NotificationCenter.default.post(name: .trendingTimeline, object: nil)
      }
      .keyboardShortcut("t", modifiers: .shift)
      Button("timeline.federated") {
        NotificationCenter.default.post(name: .federatedTimeline, object: nil)
      }
      .keyboardShortcut("f", modifiers: .shift)
      Button("timeline.local") {
        NotificationCenter.default.post(name: .localTimeline, object: nil)
      }
      .keyboardShortcut("l", modifiers: .shift)
    }
    CommandMenu("menu.go") {
      Button("tab.timeline") {
        selectedTab = .timeline
      }
      .keyboardShortcut("1", modifiers: .command)
      Button("tab.notifications") {
        selectedTab = .notifications
      }
      .keyboardShortcut("2", modifiers: .command)
      Button("tab.explore") {
        selectedTab = .explore
      }
      .keyboardShortcut("3", modifiers: .command)
      Button("tab.messages") {
        selectedTab = .messages
      }
      .keyboardShortcut("4", modifiers: .command)
      Button("tab.profile") {
        selectedTab = .profile
      }
      .keyboardShortcut("5", modifiers: .command)
      Divider()
      Button("accessibility.tabs.profile.picker.bookmarks") {
        selectedTab = .bookmarks
      }
      .keyboardShortcut("b", modifiers: [.command, .shift])
      Button("accessibility.tabs.profile.picker.favorites") {
        selectedTab = .favorites
      }
      .keyboardShortcut("v", modifiers: [.command, .shift])
      Divider()
      Button("menu.go.scheduled-posts") {
        appRouterPath.navigate(to: .scheduledPosts)
      }
      .keyboardShortcut("s", modifiers: [.command, .shift])
    }
    CommandGroup(replacing: .help) {
      Button("menu.help.github") {
        let url = URL(string: "https://github.com/alzimerahmed/FrostGram/issues")!
        UIApplication.shared.open(url)
      }
    }
  }
}

import SwiftUI
import WidgetKit

@main
struct FrostGramWidgetsExtensionBundle: WidgetBundle {
  var body: some Widget {
    LatestPostsWidget()
    HashtagPostsWidget()
    ListsPostWidget()
    MentionsWidget()
    AccountWidget()
  }
}

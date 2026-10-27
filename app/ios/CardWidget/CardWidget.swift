import SwiftUI
import WidgetKit

/// Shared with the app (lib/core/widget_bridge.dart writes these keys).
private let appGroup = "group.com.shentech.shentarot"

struct CardEntry: TimelineEntry {
  let date: Date
  let drawn: Bool
  let name: String
  let theme: String
  let streak: Int
  let prompt: String
  let streakLabel: String
  let imagePath: String?
}

private func todayKey(_ d: Date = Date()) -> String {
  let c = Calendar.current.dateComponents([.year, .month, .day], from: d)
  return "\(c.year!)-\(c.month!)-\(c.day!)"
}

private func loadEntry(_ date: Date = Date()) -> CardEntry {
  let d = UserDefaults(suiteName: appGroup)
  let drawn = d?.string(forKey: "day") == todayKey(date)
  let path = d?.string(forKey: "image")
  return CardEntry(
    date: date,
    drawn: drawn,
    name: d?.string(forKey: "name") ?? "",
    theme: d?.string(forKey: "theme") ?? "",
    streak: d?.integer(forKey: "streak") ?? 0,
    prompt: d?.string(forKey: "prompt") ?? "Tap to draw today's card",
    streakLabel: d?.string(forKey: "streakLabel") ?? "",
    imagePath: drawn && path != nil && FileManager.default.fileExists(atPath: path!) ? path : nil
  )
}

struct Provider: TimelineProvider {
  func placeholder(in context: Context) -> CardEntry {
    CardEntry(date: Date(), drawn: false, name: "", theme: "", streak: 0,
              prompt: "Tap to draw today's card", streakLabel: "", imagePath: nil)
  }

  func getSnapshot(in context: Context, completion: @escaping (CardEntry) -> Void) {
    completion(loadEntry())
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<CardEntry>) -> Void) {
    // Turn face down again at midnight; the app reloads it after each draw.
    let midnight = Calendar.current.startOfDay(for: Date().addingTimeInterval(86_400))
    completion(Timeline(entries: [loadEntry(), loadEntry(midnight)], policy: .after(midnight)))
  }
}

private let gold = Color(red: 0.91, green: 0.82, blue: 0.55)

struct CardWidgetView: View {
  @Environment(\.widgetFamily) var family
  let entry: CardEntry

  var body: some View {
    switch family {
    case .accessoryCircular:
      ZStack {
        AccessoryWidgetBackground()
        VStack(spacing: 0) {
          Image(systemName: entry.drawn ? "sparkle" : "eye")
          if entry.streak > 0 { Text("\(entry.streak)").font(.headline) }
        }
      }
    case .accessoryRectangular:
      VStack(alignment: .leading, spacing: 2) {
        Text(entry.drawn ? entry.name : entry.prompt).font(.headline).lineLimit(2)
        if entry.drawn && !entry.theme.isEmpty { Text(entry.theme).font(.caption).lineLimit(1) }
        if !entry.streakLabel.isEmpty { Text(entry.streakLabel).font(.caption2) }
      }
    default:
      small
    }
  }

  private var small: some View {
    ZStack {
      if let path = entry.imagePath, let ui = UIImage(contentsOfFile: path) {
        VStack(spacing: 4) {
          Image(uiImage: ui)
            .resizable()
            .scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: 4))
          Text(entry.name)
            .font(.system(.caption2, design: .serif)).bold()
            .foregroundColor(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
          if !entry.streakLabel.isEmpty {
            Text(entry.streakLabel).font(.system(size: 9)).foregroundColor(gold)
          }
        }
        .padding(6)
      } else {
        VStack(spacing: 8) {
          RoundedRectangle(cornerRadius: 6)
            .stroke(gold, lineWidth: 1.5)
            .frame(width: 46, height: 72)
            .overlay(Image(systemName: "eye").foregroundColor(gold))
          Text(entry.drawn ? entry.name : entry.prompt)
            .font(.system(.caption, design: .serif))
            .multilineTextAlignment(.center)
            .foregroundColor(.white)
          if !entry.streakLabel.isEmpty {
            Text(entry.streakLabel).font(.caption2).foregroundColor(gold)
          }
        }
        .padding(8)
      }
    }
  }
}

private extension View {
  @ViewBuilder func widgetBackground() -> some View {
    if #available(iOS 17.0, *) {
      containerBackground(for: .widget) { Color(red: 0.04, green: 0.04, blue: 0.04) }
    } else {
      background(Color(red: 0.04, green: 0.04, blue: 0.04))
    }
  }
}

@main
struct CardWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "CardWidget", provider: Provider()) { entry in
      CardWidgetView(entry: entry)
        .widgetBackground()
    }
    .configurationDisplayName("Card of the Day")
    .description("Today's card and your streak.")
    .supportedFamilies([.systemSmall, .accessoryRectangular, .accessoryCircular])
  }
}

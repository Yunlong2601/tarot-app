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
  var deckTheme: String = "classic"
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
    imagePath: drawn && path != nil && FileManager.default.fileExists(atPath: path!) ? path : nil,
    deckTheme: d?.string(forKey: "deckTheme") ?? "classic"
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

/// The card-back accent for the user's deck theme (lib/app/deck_theme.dart).
private func accent(_ theme: String) -> Color {
  switch theme {
  case "midnight": return Color(red: 0.62, green: 0.71, blue: 0.88)
  case "rose": return Color(red: 0.89, green: 0.64, blue: 0.66)
  case "moonlight": return Color(red: 0.85, green: 0.83, blue: 0.93)
  case "sun": return Color(red: 0.94, green: 0.69, blue: 0.29)
  default: return gold
  }
}

private func backSymbol(_ theme: String) -> String {
  switch theme {
  case "midnight": return "sparkles"
  case "rose": return "camera.macro"
  case "moonlight": return "moon.stars"
  case "sun": return "sun.max"
  default: return "eye"
  }
}

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
            .stroke(accent(entry.deckTheme), lineWidth: 1.5)
            .frame(width: 46, height: 72)
            .overlay(Image(systemName: backSymbol(entry.deckTheme)).foregroundColor(accent(entry.deckTheme)))
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

// MARK: - Premium widgets: streak and moon, question of the day.

struct DayEntry: TimelineEntry {
  let date: Date
  let premium: Bool
  let locked: String
  let streak: Int
  let streakTitle: String
  let streakStart: String
  let moonPhase: Int
  let moonName: String
  let qotdTitle: String
  let question: String
  let deckTheme: String
}

private func loadDay(_ date: Date = Date()) -> DayEntry {
  let d = UserDefaults(suiteName: appGroup)
  let key = todayKey(date)
  let streak = d?.integer(forKey: "streak") ?? 0
  return DayEntry(
    date: date,
    premium: d?.bool(forKey: "premium") ?? false,
    locked: d?.string(forKey: "locked") ?? "Unlock with Premium in ShenTarot",
    streak: streak,
    streakTitle: d?.string(forKey: "streakTitle") ?? "",
    streakStart: d?.string(forKey: "streakStart") ?? "Start your streak today",
    moonPhase: d?.object(forKey: "moon_\(key)") as? Int ?? -1,
    moonName: d?.string(forKey: "moonName_\(key)") ?? "",
    qotdTitle: d?.string(forKey: "qotdTitle") ?? "Question of the day",
    question: d?.string(forKey: "qotd_\(key)") ?? "",
    deckTheme: d?.string(forKey: "deckTheme") ?? "classic"
  )
}

struct DayProvider: TimelineProvider {
  func placeholder(in context: Context) -> DayEntry {
    DayEntry(date: Date(), premium: true, locked: "", streak: 3, streakTitle: "3 days in a row",
             streakStart: "", moonPhase: 2, moonName: "First Quarter", qotdTitle: "Question of the day",
             question: "What am I ready to let go of?", deckTheme: "classic")
  }

  func getSnapshot(in context: Context, completion: @escaping (DayEntry) -> Void) {
    completion(context.isPreview ? placeholder(in: context) : loadDay())
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<DayEntry>) -> Void) {
    // One entry per midnight for the week the app has written ahead.
    let cal = Calendar.current
    let start = cal.startOfDay(for: Date())
    var entries = [loadDay()]
    for i in 1...7 {
      if let day = cal.date(byAdding: .day, value: i, to: start) { entries.append(loadDay(day)) }
    }
    completion(Timeline(entries: entries, policy: .atEnd))
  }
}

private let moonSymbols = [
  "moonphase.new.moon", "moonphase.waxing.crescent", "moonphase.first.quarter",
  "moonphase.waxing.gibbous", "moonphase.full.moon", "moonphase.waning.gibbous",
  "moonphase.last.quarter", "moonphase.waning.crescent",
]

private struct LockedView: View {
  let text: String
  let tint: Color
  var body: some View {
    VStack(spacing: 6) {
      Image(systemName: "lock.fill").foregroundColor(tint)
      Text(text)
        .font(.system(.caption, design: .serif))
        .multilineTextAlignment(.center)
        .foregroundColor(.white)
    }
    .padding(8)
  }
}

struct StreakMoonView: View {
  @Environment(\.widgetFamily) var family
  let entry: DayEntry

  var body: some View {
    let tint = accent(entry.deckTheme)
    let moon = entry.moonPhase >= 0 ? moonSymbols[entry.moonPhase % 8] : "moon"
    if !entry.premium {
      if family == .accessoryCircular {
        ZStack { AccessoryWidgetBackground(); Image(systemName: "lock.fill") }
      } else {
        LockedView(text: entry.locked, tint: tint)
      }
    } else {
      switch family {
      case .accessoryCircular:
        ZStack {
          AccessoryWidgetBackground()
          VStack(spacing: 0) {
            Image(systemName: moon)
            Text("\(entry.streak)").font(.headline)
          }
        }
      default:
        VStack(spacing: 6) {
          Image(systemName: moon)
            .font(.system(size: 34))
            .foregroundColor(tint)
          Text(entry.moonName)
            .font(.system(.caption2, design: .serif))
            .foregroundColor(.white.opacity(0.8))
            .lineLimit(1).minimumScaleFactor(0.7)
          Divider().background(tint.opacity(0.5))
          HStack(spacing: 4) {
            Image(systemName: "flame.fill").foregroundColor(tint)
            Text(entry.streak > 0 ? entry.streakTitle : entry.streakStart)
              .font(.system(.caption, design: .serif)).bold()
              .foregroundColor(.white)
              .lineLimit(2).minimumScaleFactor(0.7)
          }
        }
        .padding(8)
      }
    }
  }
}

struct QuestionView: View {
  @Environment(\.widgetFamily) var family
  let entry: DayEntry

  var body: some View {
    let tint = accent(entry.deckTheme)
    if !entry.premium {
      if family == .accessoryRectangular {
        Label(entry.locked, systemImage: "lock.fill").font(.caption)
      } else {
        LockedView(text: entry.locked, tint: tint)
      }
    } else if family == .accessoryRectangular {
      VStack(alignment: .leading, spacing: 2) {
        Text(entry.qotdTitle).font(.caption2)
        Text(entry.question).font(.headline).lineLimit(3)
      }
    } else {
      VStack(alignment: .leading, spacing: 8) {
        HStack(spacing: 4) {
          Image(systemName: "sparkle").foregroundColor(tint)
          Text(entry.qotdTitle.uppercased())
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(tint)
            .lineLimit(1)
        }
        Text(entry.question)
          .font(.system(family == .systemSmall ? .callout : .title3, design: .serif))
          .foregroundColor(.white)
          .minimumScaleFactor(0.6)
        Spacer(minLength: 0)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(12)
    }
  }
}

struct StreakMoonWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "StreakMoonWidget", provider: DayProvider()) { entry in
      StreakMoonView(entry: entry).widgetBackground()
    }
    .configurationDisplayName("Streak & Moon")
    .description("Tonight's moon and your reading streak. Premium.")
    .supportedFamilies([.systemSmall, .accessoryCircular])
  }
}

struct QuestionWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "QuestionWidget", provider: DayProvider()) { entry in
      QuestionView(entry: entry).widgetBackground()
    }
    .configurationDisplayName("Question of the Day")
    .description("A question to sit with today. Premium.")
    .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
  }
}

@main
struct ShenTarotWidgets: WidgetBundle {
  var body: some Widget {
    CardWidget()
    StreakMoonWidget()
    QuestionWidget()
  }
}

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

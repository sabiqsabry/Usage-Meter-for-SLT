import WidgetKit
import SwiftUI

// MARK: - Shared Storage Keys
private let appGroup = "group.com.sabiqsabry.sltUsageMeter"
private let defaults = UserDefaults(suiteName: appGroup)

// MARK: - Data Helpers

struct UsageRow: Identifiable {
    let id = UUID()
    let name: String
    let used: String
    let limit: String?
    let unit: String
    let percentage: Int
}

private func readUsageRows(key: String) -> [UsageRow] {
    guard let json = defaults?.string(forKey: key),
          let data = json.data(using: .utf8),
          let arr = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]]
    else { return [] }
    return arr.compactMap { d in
        guard let name = d["name"] as? String,
              let used = d["used"] as? String
        else { return nil }
        return UsageRow(
            name: name,
            used: used,
            limit: d["limit"] as? String,
            unit: d["volume_unit"] as? String ?? "GB",
            percentage: d["percentage"] as? Int ?? 0
        )
    }
}

private func readSummary(key: String) -> UsageRow? {
    guard let json = defaults?.string(forKey: key),
          let data = json.data(using: .utf8),
          let d = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
          let used = d["used"] as? String
    else { return nil }
    return UsageRow(
        name: key == "bonus_data" ? "Bonus Data" : "Extra GB",
        used: used,
        limit: d["limit"] as? String,
        unit: d["volume_unit"] as? String ?? "GB",
        percentage: 0
    )
}

// MARK: - Timeline Entry

struct WidgetEntry: TimelineEntry {
    let date: Date
    let subscriberId: String
    let status: String
    let mainRows: [UsageRow]
    let bonusRow: UsageRow?
    let extraRow: UsageRow?
    let vasRows: [UsageRow]
    let isLoggedIn: Bool
}

// MARK: - Provider

struct SLTWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> WidgetEntry {
        WidgetEntry(
            date: Date(),
            subscriberId: "0112345678",
            status: "Normal",
            mainRows: [UsageRow(name: "Standard", used: "12.5", limit: "20", unit: "GB", percentage: 62)],
            bonusRow: nil, extraRow: nil, vasRows: [],
            isLoggedIn: true
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> Void) {
        completion(buildEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetEntry>) -> Void) {
        let entry = buildEntry()
        let refresh = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(refresh)))
    }

    private func buildEntry() -> WidgetEntry {
        let subId = defaults?.string(forKey: "subscriber_id") ?? ""
        let loggedIn = !subId.isEmpty
        return WidgetEntry(
            date: Date(),
            subscriberId: subId,
            status: defaults?.string(forKey: "status") ?? "Unknown",
            mainRows: readUsageRows(key: "main_usage"),
            bonusRow: readSummary(key: "bonus_data"),
            extraRow: readSummary(key: "extra_gb"),
            vasRows: readUsageRows(key: "vas_bundles"),
            isLoggedIn: loggedIn
        )
    }
}

// MARK: - Progress Bar View

struct WProgressBar: View {
    let row: UsageRow
    let barColor: Color

    private var progress: Double {
        guard let lim = row.limit, let l = Double(lim), l > 0,
              let u = Double(row.used) else { return 0 }
        return min(1, u / l)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(row.name)
                    .font(.system(size: 10, weight: .medium))
                    .lineLimit(1)
                Spacer()
                Group {
                    if let lim = row.limit {
                        Text("\(fmt(row.used)) / \(fmt(lim)) \(row.unit)")
                    } else {
                        Text("\(fmt(row.used)) \(row.unit)")
                    }
                }
                .font(.system(size: 9))
                .foregroundColor(.secondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.gray.opacity(0.2))
                    if row.limit != nil {
                        Capsule()
                            .fill(barColor)
                            .frame(width: geo.size.width * progress)
                    } else {
                        Capsule().fill(barColor.opacity(0.4))
                    }
                }
            }
            .frame(height: 4)
        }
    }

    private func fmt(_ s: String) -> String {
        guard let d = Double(s) else { return s }
        return d == d.rounded() ? String(Int(d)) : String(format: "%.1f", d)
    }
}

// MARK: - Widget Entry View

struct SLTWidgetEntryView: View {
    let entry: WidgetEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        if !entry.isLoggedIn {
            loginPrompt
        } else {
            usageView
        }
    }

    private var loginPrompt: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.crop.circle.badge.exclamationmark")
                .font(.largeTitle)
                .foregroundColor(.orange)
            Text("Please Login")
                .font(.headline)
            Text("Open the app to log in.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .widgetBackground(Color(UIColor.systemGroupedBackground))
    }

    private var usageView: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Text(entry.subscriberId)
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
                Spacer()
                Text(entry.status)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(statusColor)
                    .foregroundColor(.white)
                    .cornerRadius(4)
            }

            // Main usage bars (up to 2)
            ForEach(entry.mainRows.prefix(family == .systemSmall ? 1 : 2)) { row in
                WProgressBar(row: row, barColor: .blue)
            }

            // Bonus / Extra
            if let b = entry.bonusRow {
                WProgressBar(row: b, barColor: .purple)
            }
            if let e = entry.extraRow {
                WProgressBar(row: e, barColor: .orange)
            }

            // VAS (medium only, up to 3)
            if family != .systemSmall {
                ForEach(entry.vasRows.prefix(3)) { row in
                    WProgressBar(row: row, barColor: .green)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .widgetBackground(Color(UIColor.systemGroupedBackground))
        .widgetURL(URL(string: "sltusage://account/\(entry.subscriberId)"))
    }

    private var statusColor: Color {
        switch entry.status.uppercased() {
        case "NORMAL", "ACTIVE": return .green
        case "THROTTLED":        return .red
        default:                 return .orange
        }
    }
}

// MARK: - Widget

@main
struct SLTUsageMeterWidget: Widget {
    let kind = "SLTUsageMeterWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SLTWidgetProvider()) { entry in
            SLTWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("SLT Usage")
        .description("View your broadband data usage at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Background helper

extension View {
    func widgetBackground(_ view: some View) -> some View {
        if #available(iOS 17.0, *) {
            return self.containerBackground(for: .widget) { view }
        } else {
            return self.background(view)
        }
    }
}

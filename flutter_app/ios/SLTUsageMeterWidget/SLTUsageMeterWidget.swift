//
//  SLTUsageMeterWidget.swift
//  SLTUsageMeterWidget
//
//  Created by Sabiq Sabry on 18/06/2026.
//

import WidgetKit
import SwiftUI

// MARK: - Shared data

private let kAppGroupId = "group.com.sabiqsabry.sltUsageMeter"

/// One usage line (main package entry, bonus, extra GB, or VAS bundle).
/// Mirrors `WidgetService._detailToMap` on the Flutter side.
struct UsageItem: Decodable {
    let name: String
    let used: String
    let limit: String?
    let volumeUnit: String
    let percentage: Int

    enum CodingKeys: String, CodingKey {
        case name, used, limit, percentage
        case volumeUnit = "volume_unit"
    }

    var usedValue: Double { Double(used) ?? 0 }
    var limitValue: Double? { limit.flatMap(Double.init) }
    var isUnlimited: Bool { limitValue == nil }

    /// Fraction used (0...1). Mirrors `UsageDetail.usedFraction` in the app.
    var usedFraction: Double {
        guard let l = limitValue, l > 0 else { return 0 }
        return min(max(usedValue / l, 0), 1)
    }

    private static func fmt(_ v: Double) -> String {
        v == v.rounded() ? String(Int(v)) : String(format: "%.2f", v)
    }

    var usedDisplay: String { Self.fmt(usedValue) }
    var limitDisplay: String { isUnlimited ? "∞" : Self.fmt(limitValue ?? 0) }
}

// MARK: - Timeline entry

struct SLTEntry: TimelineEntry {
    let date: Date
    let status: String
    let items: [UsageItem]
    let lastUpdated: Date?
    let hasData: Bool

    static let placeholder = SLTEntry(
        date: Date(),
        status: "Normal",
        items: [UsageItem(name: "My Package", used: "45", limit: "100",
                          volumeUnit: "GB", percentage: 55)],
        lastUpdated: Date(),
        hasData: true
    )
}

// MARK: - Provider

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SLTEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (SLTEntry) -> Void) {
        completion(context.isPreview ? .placeholder : load())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SLTEntry>) -> Void) {
        let entry = load()
        // Refresh roughly hourly; the app also pushes updates when it fetches new data.
        let next = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date().addingTimeInterval(3600)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    /// Reads the data written by Flutter's `home_widget` into the shared App Group.
    private func load() -> SLTEntry {
        let defaults = UserDefaults(suiteName: kAppGroupId)
        let status = defaults?.string(forKey: "status") ?? "Unknown"

        var items: [UsageItem] = []
        if let raw = defaults?.string(forKey: "main_usage"),
           let data = raw.data(using: .utf8),
           let decoded = try? JSONDecoder().decode([UsageItem].self, from: data) {
            items = decoded
        }

        // Append bonus / extra-GB so the medium widget shows more, and so there's
        // still something to display for plans that don't populate the main package.
        if let bonus = Self.decodeSummary(defaults?.string(forKey: "bonus_data"), name: "Bonus Data") {
            items.append(bonus)
        }
        if let extra = Self.decodeSummary(defaults?.string(forKey: "extra_gb"), name: "Extra GB") {
            items.append(extra)
        }

        var lastUpdated: Date?
        if let iso = defaults?.string(forKey: "last_updated") {
            let f = ISO8601DateFormatter()
            f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            lastUpdated = f.date(from: iso) ?? ISO8601DateFormatter().date(from: iso)
        }

        return SLTEntry(
            date: Date(),
            status: status,
            items: items,
            lastUpdated: lastUpdated,
            hasData: !items.isEmpty
        )
    }

    /// Decodes a `{used, limit, volume_unit}` summary object (bonus / extra GB)
    /// into a `UsageItem` with the given display name.
    private static func decodeSummary(_ raw: String?, name: String) -> UsageItem? {
        guard let raw, let data = raw.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return nil }

        let used = (obj["used"] as? String) ?? String(describing: obj["used"] ?? "0")
        let limit = obj["limit"] as? String
        let unit = (obj["volume_unit"] as? String) ?? "GB"
        return UsageItem(name: name, used: used, limit: limit, volumeUnit: unit, percentage: 0)
    }
}

// MARK: - Views

private struct UsageRow: View {
    let item: UsageItem

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Text(item.name)
                    .font(.caption).fontWeight(.medium)
                    .lineLimit(1)
                Spacer()
                Text(item.isUnlimited
                     ? "\(item.usedDisplay) \(item.volumeUnit)"
                     : "\(item.usedDisplay)/\(item.limitDisplay) \(item.volumeUnit)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            if item.isUnlimited {
                ProgressBar(fraction: 0, unlimited: true)
            } else {
                ProgressBar(fraction: item.usedFraction, unlimited: false)
            }
        }
    }
}

private struct ProgressBar: View {
    let fraction: Double
    let unlimited: Bool

    private var color: Color {
        if unlimited { return .blue }
        switch fraction {
        case ..<0.7: return .green
        case ..<0.9: return .orange
        default: return .red
        }
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(.quaternary)
                Capsule()
                    .fill(color)
                    .frame(width: unlimited ? geo.size.width : max(4, geo.size.width * fraction))
            }
        }
        .frame(height: 6)
    }
}

struct SLTUsageMeterWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    var entry: Provider.Entry

    private var maxRows: Int { family == .systemSmall ? 1 : 3 }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("SLT Usage")
                    .font(.caption).fontWeight(.semibold)
                Spacer()
                if entry.hasData {
                    Text(entry.status)
                        .font(.caption2).fontWeight(.medium)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(.green.opacity(0.18), in: Capsule())
                        .foregroundStyle(.green)
                }
            }

            if entry.hasData {
                ForEach(Array(entry.items.prefix(maxRows).enumerated()), id: \.offset) { _, item in
                    UsageRow(item: item)
                }
                Spacer(minLength: 0)
                if let updated = entry.lastUpdated {
                    Text("Updated \(updated, style: .relative) ago")
                        .font(.system(size: 9))
                        .foregroundStyle(.tertiary)
                }
            } else {
                Spacer()
                Text("Open the app to load your usage")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
        }
    }
}

// MARK: - Widget

struct SLTUsageMeterWidget: Widget {
    let kind: String = "SLTUsageMeterWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                SLTUsageMeterWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                SLTUsageMeterWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("SLT Usage")
        .description("Your SLT broadband data usage at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Entry point

@main
struct SLTUsageMeterWidgetBundle: WidgetBundle {
    var body: some Widget {
        SLTUsageMeterWidget()
    }
}

#Preview(as: .systemSmall) {
    SLTUsageMeterWidget()
} timeline: {
    SLTEntry.placeholder
}

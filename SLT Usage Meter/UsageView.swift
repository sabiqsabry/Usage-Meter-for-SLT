//
//  UsageView.swift
//  SLT Usage Meter
//
//  Created by Prabhashwara on 2024-01-06.
//

import SwiftUI

struct UsageView: View {
    let usageSummary: UsageSummaryBundle?
    let vasBundles: [UsageDetail]
    let isLoading: Bool
    let errorMessage: String?
    let retryAction: () -> Void
    let refreshAction: () async -> Void
    
    var body: some View {
        Group {
            if isLoading {
                VStack {
                    Spacer()
                    ProgressView("Fetching usage data...")
                    Spacer()
                }
            } else if let error = errorMessage {
                VStack(spacing: 15) {
                    Spacer()
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    Text(error)
                        .multilineTextAlignment(.center)
                        .padding()
                    Button("Retry") {
                        retryAction()
                    }
                    .buttonStyle(.borderedProminent)
                    Spacer()
                }
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // Status Header
                        if let summary = usageSummary {
                            // Status Card
                            UsageSummaryCard(summary: summary)
                                .padding(.top)
                            
                            // Main Usage Bars
                            if let packageInfo = summary.myPackageInfo {
                                VStack(alignment: .leading, spacing: 15) {
                                    Text(packageInfo.packageName)
                                        .font(.headline)
                                        .padding(.horizontal)
                                    
                                    ForEach(packageInfo.usageDetails) { usage in
                                        UsageProgressBar(usage: usage)
                                    }
                                }
                                .padding(.vertical)
                                .background(RoundedRectangle(cornerRadius: 16).fill(Color.primary.opacity(0.03)))
                                .padding(.horizontal)
                            }
                            
                            // Data Packs (Bonus/Extra)
                            UsageBreakdownView(summary: summary)
                        } else {
                            // Fallback if no usage summary
                            Text("No usage data available")
                                .foregroundColor(.secondary)
                                .padding()
                                .padding(.top, 50)
                        }
                        
                        // VAS / Add-on Bundles
                        if !vasBundles.isEmpty {
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Add-on Bundles")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal)
                                
                                ForEach(vasBundles) { bundle in
                                    VASBundleRow(bundle: bundle)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
                #if os(iOS)
                .refreshable {
                    await refreshAction()
                }
                #endif
            }
        }
    }
}

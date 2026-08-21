import SwiftUI
import WRXLogCore

struct LogOverviewView: View {
    let log: EngineLog

    private var summaries: [MeasurementSummary] {
        log.measurementSummaries
    }

    var body: some View {
        Group {
            if summaries.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "list.bullet.rectangle")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)

                    Text("No Measurement Summaries")
                        .font(.headline)

                    Text(
                        "This log does not contain recognized measurements with valid values."
                    )
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                }
                .padding()
            } else {
                List {
                    ForEach(
                        summaries,
                        id: \.column.index
                    ) { summary in
                        Section {
                            LabeledContent(
                                "Minimum",
                                value: formattedValue(
                                    summary.statistics.minimum,
                                    unit: summary.column.unit
                                )
                            )

                            LabeledContent(
                                "Average",
                                value: formattedValue(
                                    summary.statistics.average,
                                    unit: summary.column.unit
                                )
                            )

                            LabeledContent(
                                "Maximum",
                                value: formattedValue(
                                    summary.statistics.maximum,
                                    unit: summary.column.unit
                                )
                            )

                            LabeledContent(
                                "Valid Samples",
                                value: String(
                                    summary.statistics.sampleCount
                                )
                            )
                        } header: {
                            Text(summary.column.originalHeader)
                        }
                    }
                }
            }
        }
        .navigationTitle("Log Overview")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func formattedValue(
        _ value: Double,
        unit: String?
    ) -> String {
        let number = value.formatted(
            .number.precision(
                .fractionLength(0...2)
            )
        )

        if let unit {
            return "\(number) \(unit)"
        }

        return number
    }
}

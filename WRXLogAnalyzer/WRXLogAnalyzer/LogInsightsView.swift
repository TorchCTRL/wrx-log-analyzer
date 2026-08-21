import SwiftUI
import WRXLogCore

struct LogInsightsView: View {
    let result: ROMRaiderParseResult

    var body: some View {
        List {
            Section {
                ForEach(
                    result.insights.indices,
                    id: \.self
                ) { index in
                    insightRow(
                        result.insights[index]
                    )
                }
            } footer: {
                Text(
                    """
                    These insights describe import and data completeness. \
                    They do not diagnose engine health.
                    """
                )
            }
        }
        .navigationTitle("Log Insights")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func insightRow(
        _ insight: LogInsight
    ) -> some View {
        switch insight {
        case let .importQuality(
            parsedRowCount,
            totalDataRowCount,
            skippedRowCount,
            warningCount
        ):
            let isComplete =
                parsedRowCount == totalDataRowCount &&
                skippedRowCount == 0 &&
                warningCount == 0

            insightCard(
                title: "Import Quality",
                message: """
                \(parsedRowCount) of \(totalDataRowCount) rows parsed. \
                \(skippedRowCount) skipped and \(warningCount) warnings.
                """,
                systemImage: isComplete
                    ? "checkmark.circle.fill"
                    : "exclamationmark.triangle.fill",
                color: isComplete ? .green : .orange
            )

        case let .measurementRecognition(
            recognizedColumnCount,
            totalColumnCount
        ):
            let allRecognized =
                totalColumnCount > 0 &&
                recognizedColumnCount == totalColumnCount

            insightCard(
                title: "Measurement Recognition",
                message: """
                \(recognizedColumnCount) of \(totalColumnCount) measurement \
                columns are recognized.
                """,
                systemImage: allRecognized
                    ? "checkmark.circle.fill"
                    : "questionmark.circle.fill",
                color: allRecognized ? .green : .orange
            )

        case let .valueCoverage(
            validValueCount,
            totalValueCount
        ):
            let allValuesValid =
                totalValueCount > 0 &&
                validValueCount == totalValueCount

            insightCard(
                title: "Value Coverage",
                message: """
                \(validValueCount) of \(totalValueCount) recognized \
                measurement values are valid.
                """,
                systemImage: allValuesValid
                    ? "checkmark.circle.fill"
                    : "exclamationmark.triangle.fill",
                color: allValuesValid ? .green : .orange
            )
        }
    }

    private func insightCard(
        title: String,
        message: String,
        systemImage: String,
        color: Color
    ) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

import SwiftUI
import WRXLogCore

struct ImportResultsView: View {
    let fileName: String
    let result: ROMRaiderParseResult

    @State private var analysisProfile = AnalysisProfile(
        modelYear: nil,
        engineFamily: .unknown,
        tuneType: .unknown,
        fuelType: .unknown,
        logCondition: .unknown
    )

    var body: some View {
        List {
            Section("Import Summary") {
                LabeledContent("File", value: fileName)
                LabeledContent(
                    "Parsed Rows",
                    value: String(result.parsedRowCount)
                )
                LabeledContent(
                    "Total Rows",
                    value: String(result.totalDataRowCount)
                )
                LabeledContent(
                    "Skipped Rows",
                    value: String(result.skippedRowCount)
                )
                LabeledContent(
                    "Warnings",
                    value: String(result.warnings.count)
                )
            }

            Section {
                NavigationLink {
                    AnalysisReportView(
                        log: result.log,
                        profile: analysisProfile
                    )
                } label: {
                    Label(
                        "View Analysis Report",
                        systemImage: "doc.text.magnifyingglass"
                    )
                }
                NavigationLink {
                    AnalysisProfileView(
                        profile: $analysisProfile
                    )
                } label: {
                    Label(
                        "Configure Analysis Profile",
                        systemImage: analysisProfile.isComplete
                            ? "checkmark.circle.fill"
                            : "car.fill"
                    )
                }
                NavigationLink {
                    LogInsightsView(
                        result: result
                    )
                } label: {
                    Label(
                        "View Log Insights",
                        systemImage: "lightbulb.fill"
                    )
                }
                NavigationLink {
                    LogOverviewView(
                        log: result.log
                    )
                } label: {
                    Label(
                        "View Log Overview",
                        systemImage: "list.bullet.rectangle"
                    )
                }
                NavigationLink {
                    MeasurementChartView(
                        log: result.log
                    )
                } label: {
                    Label(
                        "View Measurement Chart",
                        systemImage: "chart.xyaxis.line"
                    )
                }
            }

            Section("Measurements") {
                ForEach(
                    result.log.columns.indices,
                    id: \.self
                ) { index in
                    let column = result.log.columns[index]

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(column.originalHeader)
                                .fontWeight(.medium)

                            Spacer()

                            if let unit = column.unit {
                                Text(unit)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Text(
                            measurementName(
                                for: column.measurementType
                            )
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Warnings") {
                if result.warnings.isEmpty {
                    Label(
                        "No parsing warnings",
                        systemImage: "checkmark.circle.fill"
                    )
                    .foregroundStyle(.green)
                } else {
                    ForEach(
                        result.warnings.indices,
                        id: \.self
                    ) { index in
                        Text(
                            warningDescription(
                                result.warnings[index]
                            )
                        )
                    }
                }
            }
        }
        .navigationTitle("Import Results")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func measurementName(
        for measurementType: MeasurementType
    ) -> String {
        switch measurementType {
        case .engineSpeed:
            return "Engine Speed"
        case .airFuelRatio:
            return "Air-Fuel Ratio"
        case .boostPressure:
            return "Boost Pressure"
        case .engineLoad:
            return "Engine Load"
        case .ignitionTiming:
            return "Ignition Timing"
        case .knockSum:
            return "Knock Sum"
        case .feedbackKnock:
            return "Feedback Knock"
        case .fineLearningKnock:
            return "Fine Learning Knock"
        case .wastegateDutyCycle:
            return "Wastegate Duty Cycle"
        case .throttleOpening:
            return "Throttle Opening"
        case .turboDynamicsIntegral:
            return "Turbo Dynamics Integral"
        case .dynamicAdvanceMultiplier:
            return "Dynamic Advance Multiplier"
        case .unknown:
            return "Unknown Measurement"
        }
    }

    private func warningDescription(
        _ warning: ROMRaiderCSVParserWarning
    ) -> String {
        switch warning {
        case let .blankValue(
            sourceLineNumber,
            _,
            header
        ):
            return "Line \(sourceLineNumber): \(header) is blank."

        case let .invalidNumericValue(
            sourceLineNumber,
            _,
            header,
            rawValue
        ):
            return """
            Line \(sourceLineNumber): "\(rawValue)" is not a valid \
            number for \(header).
            """

        case let .rowValueCountMismatch(
            sourceLineNumber,
            expected,
            actual
        ):
            return """
            Line \(sourceLineNumber): expected \(expected) values, \
            but found \(actual).
            """

        case let .malformedRow(sourceLineNumber):
            return "Line \(sourceLineNumber) is malformed."

        case .noRecognizedMeasurements:
            return "No supported ECU measurements were recognized."
        }
    }
}

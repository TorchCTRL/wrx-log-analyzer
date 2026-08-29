import SwiftUI
import WRXLogCore

struct AnalysisReportView: View {
    let log: EngineLog
    let profile: AnalysisProfile

    private var compatibleRules: [MeasurementThresholdRule] {
        WRXRuleCatalog.ej255DAM.rules(
            for: profile
        )
    }

    private var availableRules: [MeasurementThresholdRule] {
        compatibleRules.filter { rule in
            log.series(
                for: rule.measurementType
            ) != nil
        }
    }

    private var unavailableRules: [MeasurementThresholdRule] {
        compatibleRules.filter { rule in
            log.series(
                for: rule.measurementType
            ) == nil
        }
    }

    private var findings: [AnalysisFinding] {
        log.findings(
            for: availableRules
        )
    }

    var body: some View {
        List {
            analysisSections

            Section("Analysis Context") {
                LabeledContent(
                    "Model Year",
                    value: profile.modelYear.map {
                        String($0)
                    } ?? "Not Set"
                )

                LabeledContent(
                    "Engine",
                    value: profile.engineFamily.rawValue
                )

                LabeledContent(
                    "Tune",
                    value: profile.tuneType.rawValue
                )

                LabeledContent(
                    "Fuel",
                    value: profile.fuelType.rawValue
                )

                LabeledContent(
                    "Condition",
                    value: profile.logCondition.rawValue
                )
            }

            Section("Important") {
                Text(
                    """
                    This report performs automated comparisons against \
                    documented rules. It does not diagnose engine damage, \
                    establish vehicle safety, or replace inspection by a \
                    qualified professional.
                    """
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Analysis Report")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var analysisSections: some View {
        if !profile.isComplete {
            Section("Analysis Status") {
                statusRow(
                    title: "Complete the Analysis Profile",
                    message: """
                    Enter the vehicle, tune, fuel, and driving context before \
                    profile-specific rules can be selected.
                    """,
                    systemImage: "exclamationmark.triangle.fill",
                    color: .orange
                )
            }
        } else if compatibleRules.isEmpty {
            Section("Analysis Status") {
                statusRow(
                    title: "No Compatible Rule Set",
                    message: """
                    The current sourced rule catalog does not support this \
                    analysis profile.
                    """,
                    systemImage: "questionmark.circle.fill",
                    color: .orange
                )
            }
        } else if availableRules.isEmpty {
            Section("Required Measurements Missing") {
                statusRow(
                    title: "Analysis Could Not Run",
                    message: """
                    This log does not contain the measurements required by \
                    the compatible analysis rules.
                    """,
                    systemImage: "waveform.badge.exclamationmark",
                    color: .orange
                )

                ForEach(
                    unavailableRules.indices,
                    id: \.self
                ) { index in
                    Label(
                        unavailableRules[index].title,
                        systemImage: "questionmark.circle"
                    )
                    .font(.subheadline)
                }
            }
        } else {
            Section("Rule Findings") {
                if findings.isEmpty {
                    statusRow(
                        title: "No Configured Threshold Violations",
                        message: """
                        The available measurements did not violate any \
                        currently selected sourced rules. This result does \
                        not prove that the engine is healthy.
                        """,
                        systemImage: "checkmark.circle.fill",
                        color: .green
                    )
                } else {
                    ForEach(
                        findings.indices,
                        id: \.self
                    ) { index in
                        findingCard(
                            findings[index]
                        )
                    }
                }
            }

            if !unavailableRules.isEmpty {
                Section("Measurements Not Evaluated") {
                    ForEach(
                        unavailableRules.indices,
                        id: \.self
                    ) { index in
                        Text(
                            unavailableRules[index].title
                        )
                    }
                }
            }
        }
    }

    private func findingCard(
        _ finding: AnalysisFinding
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Label(
                    finding.rule.title,
                    systemImage: "exclamationmark.triangle.fill"
                )
                .font(.headline)
                .foregroundStyle(
                    severityColor(
                        finding.rule.severity
                    )
                )

                Spacer()

                Text(
                    severityName(
                        finding.rule.severity
                    )
                )
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(
                    severityColor(
                        finding.rule.severity
                    )
                )
            }

            LabeledContent(
                "Observed Value",
                value: formattedValue(
                    finding.observedValue,
                    measurementType: finding.rule.measurementType
                )
            )

            LabeledContent(
                "Rule Threshold",
                value: thresholdDescription(
                    finding.rule
                )
            )

            LabeledContent(
                "CSV Source Line",
                value: String(
                    finding.sourceLineNumber
                )
            )

            if !finding.rule.explanation.isEmpty {
                Text(finding.rule.explanation)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if let source = finding.rule.source,
               let sourceURL = URL(
                   string: source.url
               ) {
                Link(
                    destination: sourceURL
                ) {
                    Label(
                        "View Source: \(source.title)",
                        systemImage: "link"
                    )
                }
                .font(.subheadline)
            }
        }
        .padding(.vertical, 6)
    }

    private func statusRow(
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

    private func thresholdDescription(
        _ rule: MeasurementThresholdRule
    ) -> String {
        let threshold = formattedValue(
            rule.threshold,
            measurementType: rule.measurementType
        )

        switch rule.comparison {
        case .greaterThan:
            return "> \(threshold)"
        case .lessThan:
            return "< \(threshold)"
        }
    }

    private func formattedValue(
        _ value: Double,
        measurementType: MeasurementType
    ) -> String {
        let number = value.formatted(
            .number.precision(
                .fractionLength(0...3)
            )
        )

        let unit = log.columns.first {
            $0.measurementType == measurementType
        }?.unit

        if let unit {
            return "\(number) \(unit)"
        }

        return number
    }

    private func severityName(
        _ severity: AnalysisSeverity
    ) -> String {
        switch severity {
        case .information:
            return "Information"
        case .caution:
            return "Caution"
        case .critical:
            return "Critical"
        }
    }

    private func severityColor(
        _ severity: AnalysisSeverity
    ) -> Color {
        switch severity {
        case .information:
            return .blue
        case .caution:
            return .orange
        case .critical:
            return .red
        }
    }
}

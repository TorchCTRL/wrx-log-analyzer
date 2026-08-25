/// Determines which side of a threshold counts as a violation.
public enum ThresholdComparison: Equatable, Sendable {
    case greaterThan
    case lessThan
}

/// Describes the importance assigned to an analysis rule.
public enum AnalysisSeverity: Equatable, Sendable {
    case information
    case caution
    case critical
}

/// A caller-supplied rule for evaluating one measurement.
///
/// This type does not provide built-in vehicle thresholds. Compatible
/// rules will later be selected using an analysis profile.
public struct MeasurementThresholdRule: Equatable, Sendable {
    public let title: String
    public let measurementType: MeasurementType
    public let comparison: ThresholdComparison
    public let threshold: Double
    public let severity: AnalysisSeverity

    /// Context that helps the user interpret the rule safely.
    public let explanation: String

    /// Documentation supporting the rule, when available.
    public let source: AnalysisRuleSource?

    public init(
        title: String,
        measurementType: MeasurementType,
        comparison: ThresholdComparison,
        threshold: Double,
        severity: AnalysisSeverity,
        explanation: String = "",
        source: AnalysisRuleSource? = nil
    ) {
        self.title = title
        self.measurementType = measurementType
        self.comparison = comparison
        self.threshold = threshold
        self.severity = severity
        self.explanation = explanation
        self.source = source
    }
}

/// The most significant sample that violated one supplied rule.
public struct AnalysisFinding: Equatable, Sendable {
    public let rule: MeasurementThresholdRule
    public let observedValue: Double
    public let snapshotIndex: Int
    public let sourceLineNumber: Int

    public init(
        rule: MeasurementThresholdRule,
        observedValue: Double,
        snapshotIndex: Int,
        sourceLineNumber: Int
    ) {
        self.rule = rule
        self.observedValue = observedValue
        self.snapshotIndex = snapshotIndex
        self.sourceLineNumber = sourceLineNumber
    }
}

extension EngineLog {
    /// Evaluates one threshold rule and returns its strongest violation.
    public func finding(
        for rule: MeasurementThresholdRule
    ) -> AnalysisFinding? {
        guard let series = series(
            for: rule.measurementType
        ) else {
            return nil
        }

        let violatingSamples = series.samples.filter { sample in
            switch rule.comparison {
            case .greaterThan:
                return sample.value > rule.threshold

            case .lessThan:
                return sample.value < rule.threshold
            }
        }

        let mostSignificantSample: MeasurementSample?

        switch rule.comparison {
        case .greaterThan:
            mostSignificantSample = violatingSamples.max {
                $0.value < $1.value
            }

        case .lessThan:
            mostSignificantSample = violatingSamples.min {
                $0.value < $1.value
            }
        }

        guard let mostSignificantSample else {
            return nil
        }

        return AnalysisFinding(
            rule: rule,
            observedValue: mostSignificantSample.value,
            snapshotIndex: mostSignificantSample.snapshotIndex,
            sourceLineNumber: mostSignificantSample.sourceLineNumber
        )
    }
}
extension EngineLog {
    /// Evaluates multiple rules in their supplied order.
    ///
    /// Rules without a violating sample are omitted.
    public func findings(
        for rules: [MeasurementThresholdRule]
    ) -> [AnalysisFinding] {
        rules.compactMap { rule in
            finding(for: rule)
        }
    }
}

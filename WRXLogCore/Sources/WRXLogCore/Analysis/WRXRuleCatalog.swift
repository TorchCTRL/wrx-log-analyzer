/// Profile-specific WRX analysis rules backed by cited documentation.
public enum WRXRuleCatalog {
    /// A cautious DAM rule for 2006–2014 WRXs using the EJ255.
    ///
    /// DIT engines are intentionally excluded because their DAM behavior
    /// differs from the earlier EJ engine behavior.
    public static let ej255DAM = ProfileRuleSet(
        name: "2006–2014 WRX EJ255 DAM",
        compatibility: AnalysisProfileCompatibility(
            modelYearRange: 2006...2014,
            engineFamilies: [.ej255],
            tuneTypes: [
                .stock,
                .offTheShelf
            ],
            fuelTypes: [
                .octane91,
                .octane93
            ],
            logConditions: [
                .idle,
                .cruise,
                .acceleration,
                .wideOpenThrottle,
                .mixed
            ]
        ),
        rules: [
            MeasurementThresholdRule(
                title: "Dynamic Advance Multiplier Below Maximum",
                measurementType: .dynamicAdvanceMultiplier,
                comparison: .lessThan,
                threshold: 1.0,
                severity: .caution,
                explanation: """
                DAM below 1.0 means the ECU is not currently applying its \
                maximum learned dynamic advance. A recent ECU reset or \
                reflash may temporarily lower DAM, so review the log context \
                and repeated knock corrections before drawing conclusions.
                """,
                source: AnalysisRuleSource(
                    title: "COBB Subaru Knock Monitoring",
                    url: """
                    https://cobbtuning.atlassian.net/wiki/spaces/PRS/pages/338723039/Subaru+Knock+Monitoring
                    """
                )
            )
        ]
    )
}

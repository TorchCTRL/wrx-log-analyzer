/// Describes the analysis profiles supported by one rule set.
public struct AnalysisProfileCompatibility: Equatable, Sendable {
    public let modelYearRange: ClosedRange<Int>
    public let engineFamilies: Set<EngineFamily>
    public let tuneTypes: Set<TuneType>
    public let fuelTypes: Set<FuelType>
    public let logConditions: Set<LogCondition>

    public init(
        modelYearRange: ClosedRange<Int>,
        engineFamilies: Set<EngineFamily>,
        tuneTypes: Set<TuneType>,
        fuelTypes: Set<FuelType>,
        logConditions: Set<LogCondition>
    ) {
        self.modelYearRange = modelYearRange
        self.engineFamilies = engineFamilies
        self.tuneTypes = tuneTypes
        self.fuelTypes = fuelTypes
        self.logConditions = logConditions
    }

    /// Whether the profile is complete and matches every requirement.
    public func supports(
        _ profile: AnalysisProfile
    ) -> Bool {
        guard profile.isComplete,
              let modelYear = profile.modelYear else {
            return false
        }

        return modelYearRange.contains(modelYear) &&
            engineFamilies.contains(profile.engineFamily) &&
            tuneTypes.contains(profile.tuneType) &&
            fuelTypes.contains(profile.fuelType) &&
            logConditions.contains(profile.logCondition)
    }
}

/// A named collection of rules for one compatible profile group.
public struct ProfileRuleSet: Equatable, Sendable {
    public let name: String
    public let compatibility: AnalysisProfileCompatibility
    public let thresholdRules: [MeasurementThresholdRule]

    public init(
        name: String,
        compatibility: AnalysisProfileCompatibility,
        rules: [MeasurementThresholdRule]
    ) {
        self.name = name
        self.compatibility = compatibility
        self.thresholdRules = rules
    }

    /// Returns the rules only when the profile is compatible.
    public func rules(
        for profile: AnalysisProfile
    ) -> [MeasurementThresholdRule] {
        guard compatibility.supports(profile) else {
            return []
        }

        return thresholdRules
    }
}

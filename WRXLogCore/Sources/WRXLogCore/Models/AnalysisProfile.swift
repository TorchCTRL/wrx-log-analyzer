/// Engine families commonly used by supported Subaru applications.
public enum EngineFamily: String, CaseIterable, Hashable, Sendable {
    case ej205 = "EJ205"
    case ej255 = "EJ255"
    case fa20DIT = "FA20DIT"
    case fa24DIT = "FA24DIT"
    case other = "Other"
    case unknown = "Not Sure"
}

/// Describes how the vehicle's ECU calibration was created.
public enum TuneType: String, CaseIterable, Hashable, Sendable {
    case stock = "Stock"
    case offTheShelf = "Off-the-Shelf"
    case custom = "Custom"
    case unknown = "Not Sure"
}

/// Describes the fuel used while recording the log.
public enum FuelType: String, CaseIterable, Hashable, Sendable {
    case octane91 = "91 Octane"
    case octane93 = "93 Octane"
    case ethanolBlend = "Ethanol Blend"
    case other = "Other"
    case unknown = "Not Sure"
}

/// Describes the driving activity represented by the log.
public enum LogCondition: String, CaseIterable, Hashable, Sendable {
    case idle = "Idle"
    case cruise = "Cruise"
    case acceleration = "Acceleration"
    case wideOpenThrottle = "Wide-Open Throttle"
    case mixed = "Mixed Driving"
    case unknown = "Not Sure"
}

/// Context required before vehicle-specific analysis rules can run.
public struct AnalysisProfile: Equatable, Sendable {
    public var modelYear: Int?
    public var engineFamily: EngineFamily
    public var tuneType: TuneType
    public var fuelType: FuelType
    public var logCondition: LogCondition

    public init(
        modelYear: Int?,
        engineFamily: EngineFamily,
        tuneType: TuneType,
        fuelType: FuelType,
        logCondition: LogCondition
    ) {
        self.modelYear = modelYear
        self.engineFamily = engineFamily
        self.tuneType = tuneType
        self.fuelType = fuelType
        self.logCondition = logCondition
    }

    /// Whether enough context exists to consider health-analysis rules.
    public var isComplete: Bool {
        guard let modelYear, modelYear > 0 else {
            return false
        }

        return engineFamily != .unknown &&
            tuneType != .unknown &&
            fuelType != .unknown &&
            logCondition != .unknown
    }
}

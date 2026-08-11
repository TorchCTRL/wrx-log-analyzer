/// A standardized ECU measurement recognized by WRX Log Analyzer.
///
/// ROMRaider may use different header names for the same measurement.
/// This type gives the application one consistent internal name.
public enum MeasurementType: Equatable, Sendable {
    case engineSpeed
    case airFuelRatio
    case boostPressure
    case feedbackKnock
    case fineLearningKnock
    case dynamicAdvanceMultiplier
    case unknown
}

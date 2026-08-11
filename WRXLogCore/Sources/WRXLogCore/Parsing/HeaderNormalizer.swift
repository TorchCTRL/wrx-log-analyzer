import Foundation

/// Converts raw ROMRaider column headers into standardized measurement types.
///
/// The original header remains unchanged in `LogColumn`. This type only
/// determines whether WRX Log Analyzer recognizes the measurement.
public enum HeaderNormalizer {
    public static func measurementType(
        for rawHeader: String
    ) -> MeasurementType {
        let normalizedHeader = rawHeader
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        switch normalizedHeader {
        case "engine speed (rpm)",
             "engine speed",
             "rpm":
            return .engineSpeed

        case "a/f sensor #1 (afr)",
             "air/fuel ratio",
             "air fuel ratio",
             "afr":
            return .airFuelRatio

        case "manifold relative pressure (psi)",
             "boost pressure",
             "boost":
            return .boostPressure

        case "feedback knock correction",
             "feedback knock correction (degrees)",
             "feedback knock":
            return .feedbackKnock

        case "fine learning knock correction",
             "fine learning knock correction (degrees)",
             "fine learning knock":
            return .fineLearningKnock

        case "dynamic advance multiplier",
             "dynamic advance multiplier (dam)",
             "dam":
            return .dynamicAdvanceMultiplier

        default:
            return .unknown
        }
    }
}

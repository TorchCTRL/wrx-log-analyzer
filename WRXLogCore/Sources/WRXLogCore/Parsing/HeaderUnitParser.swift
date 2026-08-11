import Foundation

/// Identifies known measurement units from ROMRaider column headers.
///
/// Only explicitly supported suffixes are recognized. Parenthetical text
/// such as `(AFR)` or `(DAM)` is not automatically treated as a unit.
public enum HeaderUnitParser {
    private static let knownSuffixes: [
        (suffix: String, unit: String)
    ] = [
        ("(absolute %)", "absolute %"),
        ("(g/rev)", "g/rev"),
        ("(degrees)", "degrees"),
        ("(count)", "count"),
        ("(rpm)", "rpm"),
        ("(psi)", "psi"),
        ("(%)", "%")
    ]

    public static func unit(
        for rawHeader: String
    ) -> String? {
        let normalizedHeader = rawHeader
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        return knownSuffixes.first {
            normalizedHeader.hasSuffix($0.suffix)
        }?.unit
    }
}

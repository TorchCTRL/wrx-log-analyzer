/// Describes a recoverable problem found while parsing a ROMRaider CSV log.
///
/// Warnings preserve context so the application can explain exactly
/// what happened without rejecting the entire file.
public enum ROMRaiderCSVParserWarning: Equatable, Sendable {
    case blankValue(
        sourceLineNumber: Int,
        columnIndex: Int,
        header: String
    )

    case invalidNumericValue(
        sourceLineNumber: Int,
        columnIndex: Int,
        header: String,
        rawValue: String
    )

    case rowValueCountMismatch(
        sourceLineNumber: Int,
        expected: Int,
        actual: Int
    )

    case malformedRow(
        sourceLineNumber: Int
    )
}

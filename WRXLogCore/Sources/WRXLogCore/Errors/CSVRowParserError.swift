/// Describes a structural problem found while separating one CSV row
/// into individual cells.
public enum CSVRowParserError: Error, Equatable, Sendable {
    case unterminatedQuotedField
}

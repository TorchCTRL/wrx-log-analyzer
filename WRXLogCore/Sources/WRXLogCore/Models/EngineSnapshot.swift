/// Represents one successfully parsed row from an ECU log.
///
/// Values remain in the same order as the columns defined by `EngineLog`.
/// A `nil` value represents a blank or invalid measurement cell.
public struct EngineSnapshot: Equatable, Sendable {
    /// The one-based physical line number in the original CSV file.
    public let sourceLineNumber: Int

    /// Measurement values ordered to match the log's columns.
    public let values: [Double?]

    public init(
        sourceLineNumber: Int,
        values: [Double?]
    ) {
        self.sourceLineNumber = sourceLineNumber
        self.values = values
    }
}

/// One valid numeric value extracted from an engine-log snapshot.
public struct MeasurementSample: Equatable, Sendable {
    /// The zero-based position of the snapshot in the engine log.
    public let snapshotIndex: Int

    /// The original line number in the imported CSV file.
    public let sourceLineNumber: Int

    /// The parsed numeric measurement.
    public let value: Double

    public init(
        snapshotIndex: Int,
        sourceLineNumber: Int,
        value: Double
    ) {
        self.snapshotIndex = snapshotIndex
        self.sourceLineNumber = sourceLineNumber
        self.value = value
    }
}

/// A graph-ready sequence of values for one recognized measurement.
public struct MeasurementSeries: Equatable, Sendable {
    public let column: LogColumn
    public let samples: [MeasurementSample]

    public init(
        column: LogColumn,
        samples: [MeasurementSample]
    ) {
        self.column = column
        self.samples = samples
    }
}

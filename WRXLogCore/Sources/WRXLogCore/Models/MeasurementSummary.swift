/// Statistics and column information for one recognized measurement.
public struct MeasurementSummary: Equatable, Sendable {
    public let column: LogColumn
    public let statistics: MeasurementStatistics

    public init(
        column: LogColumn,
        statistics: MeasurementStatistics
    ) {
        self.column = column
        self.statistics = statistics
    }
}

extension EngineLog {
    /// Creates summaries for recognized columns containing valid samples.
    ///
    /// Summaries preserve the original CSV column order.
    public var measurementSummaries: [MeasurementSummary] {
        columns.enumerated().compactMap {
            columnPosition,
            column -> MeasurementSummary? in

            guard column.measurementType != .unknown else {
                return nil
            }

            let samples = snapshots.enumerated().compactMap {
                snapshotIndex,
                snapshot -> MeasurementSample? in

                guard let value = snapshot.values[columnPosition] else {
                    return nil
                }

                return MeasurementSample(
                    snapshotIndex: snapshotIndex,
                    sourceLineNumber: snapshot.sourceLineNumber,
                    value: value
                )
            }

            let series = MeasurementSeries(
                column: column,
                samples: samples
            )

            guard let statistics = series.statistics else {
                return nil
            }

            return MeasurementSummary(
                column: column,
                statistics: statistics
            )
        }
    }
}

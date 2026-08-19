/// Represents one complete, structurally valid ECU logging session.
public struct EngineLog: Equatable, Sendable {
    /// The measurements defined by the CSV header.
    public let columns: [LogColumn]

    /// Successfully parsed rows whose values align with `columns`.
    public let snapshots: [EngineSnapshot]

    public init(
        columns: [LogColumn],
        snapshots: [EngineSnapshot]
    ) throws {
        for snapshot in snapshots {
            guard snapshot.values.count == columns.count else {
                throw EngineLogError.snapshotValueCountMismatch(
                    sourceLineNumber: snapshot.sourceLineNumber,
                    expected: columns.count,
                    actual: snapshot.values.count
                )
            }
        }

        self.columns = columns
        self.snapshots = snapshots
    }

    public func series(
        for measurementType: MeasurementType
    ) -> MeasurementSeries? {
        guard measurementType != .unknown else {
            return nil
        }

        guard let columnPosition = columns.firstIndex(where: {
            $0.measurementType == measurementType
        }) else {
            return nil
        }

        let column = columns[columnPosition]

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

        return MeasurementSeries(
            column: column,
            samples: samples
        )
    }
}

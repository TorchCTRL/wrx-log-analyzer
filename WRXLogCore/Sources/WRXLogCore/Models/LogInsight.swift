/// An objective fact derived from an imported ROMRaider log.
///
/// These insights describe import and data quality. They do not make
/// engine-health judgments or apply vehicle-specific thresholds.
public enum LogInsight: Equatable, Sendable {
    case importQuality(
        parsedRowCount: Int,
        totalDataRowCount: Int,
        skippedRowCount: Int,
        warningCount: Int
    )

    case measurementRecognition(
        recognizedColumnCount: Int,
        totalColumnCount: Int
    )

    case valueCoverage(
        validValueCount: Int,
        totalValueCount: Int
    )
}

extension ROMRaiderParseResult {
    /// Objective import and measurement-coverage observations.
    public var insights: [LogInsight] {
        let recognizedColumnPositions = log.columns.indices.filter {
            log.columns[$0].measurementType != .unknown
        }

        let totalValueCount =
            recognizedColumnPositions.count * log.snapshots.count

        let validValueCount = log.snapshots.reduce(into: 0) {
            count,
            snapshot in

            for columnPosition in recognizedColumnPositions {
                if snapshot.values[columnPosition] != nil {
                    count += 1
                }
            }
        }

        return [
            .importQuality(
                parsedRowCount: parsedRowCount,
                totalDataRowCount: totalDataRowCount,
                skippedRowCount: skippedRowCount,
                warningCount: warnings.count
            ),
            .measurementRecognition(
                recognizedColumnCount: recognizedColumnPositions.count,
                totalColumnCount: log.columns.count
            ),
            .valueCoverage(
                validValueCount: validValueCount,
                totalValueCount: totalValueCount
            )
        ]
    }
}

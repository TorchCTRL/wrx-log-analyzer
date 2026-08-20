/// Summary statistics calculated from one measurement series.
public struct MeasurementStatistics: Equatable, Sendable {
    public let minimum: Double
    public let maximum: Double
    public let average: Double
    public let sampleCount: Int

    public init(
        minimum: Double,
        maximum: Double,
        average: Double,
        sampleCount: Int
    ) {
        self.minimum = minimum
        self.maximum = maximum
        self.average = average
        self.sampleCount = sampleCount
    }
}

extension MeasurementSeries {
    /// Calculates statistics from all valid samples in one pass.
    ///
    /// Returns `nil` when the series contains no valid samples.
    public var statistics: MeasurementStatistics? {
        guard let firstSample = samples.first else {
            return nil
        }

        var minimum = firstSample.value
        var maximum = firstSample.value
        var total = 0.0

        for sample in samples {
            minimum = Swift.min(minimum, sample.value)
            maximum = Swift.max(maximum, sample.value)
            total += sample.value
        }

        return MeasurementStatistics(
            minimum: minimum,
            maximum: maximum,
            average: total / Double(samples.count),
            sampleCount: samples.count
        )
    }
}

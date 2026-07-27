/// Describes one column found in a ROMRaider CSV log.
///
/// The original header is preserved exactly as it appeared in the file,
/// while `measurementType` records WRX Log Analyzer's interpretation.
public struct LogColumn: Equatable, Sendable {
    /// The zero-based position of this column in the CSV row.
    public let index: Int

    /// The exact header text found in the imported CSV file.
    public let originalHeader: String

    /// The standardized measurement recognized by the application.
    public let measurementType: MeasurementType

    /// The measurement unit, when one can be identified.
    public let unit: String?

    public init(
        index: Int,
        originalHeader: String,
        measurementType: MeasurementType,
        unit: String? = nil
    ) {
        self.index = index
        self.originalHeader = originalHeader
        self.measurementType = measurementType
        self.unit = unit
    }
}

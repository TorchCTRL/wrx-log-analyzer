/// Contains the structured log and diagnostic information produced
/// by parsing one ROMRaider CSV file.
public struct ROMRaiderParseResult: Equatable, Sendable {
    public let log: EngineLog
    public let warnings: [ROMRaiderCSVParserWarning]
    public let totalDataRowCount: Int
    public let skippedRowCount: Int

    public var parsedRowCount: Int {
        log.snapshots.count
    }

    public init(
        log: EngineLog,
        warnings: [ROMRaiderCSVParserWarning],
        totalDataRowCount: Int,
        skippedRowCount: Int
    ) {
        self.log = log
        self.warnings = warnings
        self.totalDataRowCount = totalDataRowCount
        self.skippedRowCount = skippedRowCount
    }
}

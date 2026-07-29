import Foundation

/// Converts ROMRaider CSV text into a structured engine log.
public enum ROMRaiderCSVParser {
    public static func parse(
        _ csvText: String
    ) throws -> ROMRaiderParseResult {
        let normalizedText = csvText
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")

        guard !normalizedText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
        else {
            throw ROMRaiderCSVParserError.emptyFile
        }

        let lines = normalizedText
            .split(
                separator: "\n",
                omittingEmptySubsequences: false
            )
            .map(String.init)

        guard let headerLineIndex = lines.firstIndex(where: {
            !$0.trimmingCharacters(
                in: .whitespacesAndNewlines
            ).isEmpty
        }) else {
            throw ROMRaiderCSVParserError.emptyFile
        }

        let rawHeaders: [String]

        do {
            rawHeaders = try CSVRowParser.cells(
                from: lines[headerLineIndex]
            )
        } catch {
            throw ROMRaiderCSVParserError.malformedHeader
        }

        guard rawHeaders.contains(where: {
            !$0.trimmingCharacters(
                in: .whitespacesAndNewlines
            ).isEmpty
        }) else {
            throw ROMRaiderCSVParserError.missingHeader
        }

        let columns = LogColumnFactory.columns(
            from: rawHeaders
        )

        var snapshots: [EngineSnapshot] = []
        var warnings: [ROMRaiderCSVParserWarning] = []
        var totalDataRowCount = 0
        var skippedRowCount = 0

        for lineIndex in lines.indices where lineIndex > headerLineIndex {
            let rawLine = lines[lineIndex]

            // Ignore completely blank lines, including a final newline.
            guard !rawLine.trimmingCharacters(
                in: .whitespacesAndNewlines
            ).isEmpty else {
                continue
            }

            totalDataRowCount += 1

            let sourceLineNumber = lineIndex + 1
            let rawValues: [String]

            do {
                rawValues = try CSVRowParser.cells(
                    from: rawLine
                )
            } catch {
                warnings.append(
                    .malformedRow(
                        sourceLineNumber: sourceLineNumber
                    )
                )

                skippedRowCount += 1
                continue
            }

            guard rawValues.count == columns.count else {
                warnings.append(
                    .rowValueCountMismatch(
                        sourceLineNumber: sourceLineNumber,
                        expected: columns.count,
                        actual: rawValues.count
                    )
                )

                skippedRowCount += 1
                continue
            }

            var values: [Double?] = []

            for (columnIndex, rawValue) in rawValues.enumerated() {
                let trimmedValue = rawValue.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

                if trimmedValue.isEmpty {
                    values.append(nil)

                    warnings.append(
                        .blankValue(
                            sourceLineNumber: sourceLineNumber,
                            columnIndex: columnIndex,
                            header: columns[columnIndex].originalHeader
                        )
                    )
                } else if let numericValue = Double(trimmedValue) {
                    values.append(numericValue)
                } else {
                    values.append(nil)

                    warnings.append(
                        .invalidNumericValue(
                            sourceLineNumber: sourceLineNumber,
                            columnIndex: columnIndex,
                            header: columns[columnIndex].originalHeader,
                            rawValue: rawValue
                        )
                    )
                }
            }

            snapshots.append(
                EngineSnapshot(
                    sourceLineNumber: sourceLineNumber,
                    values: values
                )
            )
        }

        let log = try EngineLog(
            columns: columns,
            snapshots: snapshots
        )

        return ROMRaiderParseResult(
            log: log,
            warnings: warnings,
            totalDataRowCount: totalDataRowCount,
            skippedRowCount: skippedRowCount
        )
    }
}

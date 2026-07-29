import Foundation
import Testing
@testable import WRXLogCore

import Testing
@testable import WRXLogCore

@Test
func parsesValidROMRaiderCSVIntoEngineLog() throws {
    let csv = """
    Engine Speed (rpm),A/F Sensor #1 (AFR),Manifold Relative Pressure (psi)
    1952,14.24,0.87
    1984,13.78,1.45
    """

    let result = try ROMRaiderCSVParser.parse(csv)

    #expect(result.log.columns.count == 3)
    #expect(result.log.snapshots.count == 2)
    #expect(result.parsedRowCount == 2)
    #expect(result.totalDataRowCount == 2)
    #expect(result.skippedRowCount == 0)
    #expect(result.warnings.isEmpty)

    #expect(
        result.log.columns[0].measurementType == .engineSpeed
    )
    #expect(
        result.log.columns[2].measurementType == .boostPressure
    )

    #expect(
        result.log.snapshots[0].values == [1952, 14.24, 0.87]
    )
}

@Test
func keepsRowsContainingBlankOrInvalidNumericValues() throws {
    let csv = """
    Engine Speed (rpm),A/F Sensor #1 (AFR),Manifold Relative Pressure (psi)
    1952,,0.87
    1984,not-a-number,1.45
    """

    let result = try ROMRaiderCSVParser.parse(csv)

    #expect(result.parsedRowCount == 2)
    #expect(result.skippedRowCount == 0)
    #expect(result.warnings.count == 2)

    #expect(
        result.log.snapshots[0].values == [1952, nil, 0.87]
    )

    #expect(
        result.log.snapshots[1].values == [1984, nil, 1.45]
    )
}

@Test
func skipsRowsWhoseCellCountDoesNotMatchHeader() throws {
    let csv = """
    Engine Speed (rpm),A/F Sensor #1 (AFR),Manifold Relative Pressure (psi)
    1952,14.24
    1984,13.78,1.45
    """

    let result = try ROMRaiderCSVParser.parse(csv)

    #expect(result.totalDataRowCount == 2)
    #expect(result.parsedRowCount == 1)
    #expect(result.skippedRowCount == 1)

    #expect(
        result.warnings == [
            .rowValueCountMismatch(
                sourceLineNumber: 2,
                expected: 3,
                actual: 2
            )
        ]
    )
}

@Test
func rejectsEmptyCSVText() {
    #expect(
        throws: ROMRaiderCSVParserError.emptyFile
    ) {
        try ROMRaiderCSVParser.parse("   \n")
    }
}

@Test
func parsesRealROMRaiderLogFixture() throws {
    let fileURL = try #require(
        Bundle.module.url(
            forResource: "romraiderlog_20091208_165038-web",
            withExtension: "csv"
        )
    )

    let csvText = try String(
        contentsOf: fileURL,
        encoding: .utf8
    )

    let result = try ROMRaiderCSVParser.parse(csvText)

    #expect(result.log.columns.count == 9)
    #expect(result.totalDataRowCount == 61)
    #expect(result.parsedRowCount == 61)
    #expect(result.skippedRowCount == 0)
    #expect(result.warnings.isEmpty)

    #expect(
        result.log.columns[0].measurementType == .engineSpeed
    )
    #expect(result.log.columns[0].unit == "rpm")

    #expect(
        result.log.columns[1].measurementType == .airFuelRatio
    )
    #expect(result.log.columns[1].unit == nil)

    #expect(
        result.log.columns[2].measurementType == .unknown
    )
    #expect(result.log.columns[2].unit == "g/rev")

    #expect(
        result.log.columns[5].measurementType == .boostPressure
    )
    #expect(result.log.columns[5].unit == "psi")

    let firstSnapshot = try #require(
        result.log.snapshots.first
    )

    #expect(firstSnapshot.sourceLineNumber == 2)
    #expect(firstSnapshot.values.count == 9)
    #expect(firstSnapshot.values[0] == 1952)
    #expect(firstSnapshot.values[1] == 14.24)
    #expect(firstSnapshot.values[5] == 0.87)

    let lastSnapshot = try #require(
        result.log.snapshots.last
    )

    #expect(lastSnapshot.sourceLineNumber == 62)
    #expect(lastSnapshot.values[0] == 6693)
    #expect(lastSnapshot.values[5] == 7.98)
}

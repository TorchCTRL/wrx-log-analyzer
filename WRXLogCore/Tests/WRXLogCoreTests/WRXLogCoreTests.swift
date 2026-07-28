import Testing
@testable import WRXLogCore

@Test
func createsRecognizedLogColumn() {
    let column = LogColumn(
        index: 0,
        originalHeader: "Engine Speed (rpm)",
        measurementType: .engineSpeed,
        unit: "rpm"
    )

    #expect(column.index == 0)
    #expect(column.originalHeader == "Engine Speed (rpm)")
    #expect(column.measurementType == .engineSpeed)
    #expect(column.unit == "rpm")
}

@Test
func allowsColumnWithoutKnownUnit() {
    let column = LogColumn(
        index: 7,
        originalHeader: "Custom Calculated Load",
        measurementType: .unknown
    )

    #expect(column.unit == nil)
}

@Test
func createsEngineSnapshotWithOrderedValues() {
    let snapshot = EngineSnapshot(
        sourceLineNumber: 2,
        values: [1952, 14.24, 0.87]
    )

    #expect(snapshot.sourceLineNumber == 2)
    #expect(snapshot.values == [1952, 14.24, 0.87])
}

@Test
func preservesMissingMeasurementAsNil() {
    let snapshot = EngineSnapshot(
        sourceLineNumber: 3,
        values: [1984, nil, 1.45]
    )

    #expect(snapshot.values.count == 3)
    #expect(snapshot.values[0] == 1984)
    #expect(snapshot.values[1] == nil)
    #expect(snapshot.values[2] == 1.45)
}

@Test
func createsEngineLogWhenSnapshotValuesMatchColumns() throws {
    let columns = [
        LogColumn(
            index: 0,
            originalHeader: "Engine Speed (rpm)",
            measurementType: .engineSpeed,
            unit: "rpm"
        ),
        LogColumn(
            index: 1,
            originalHeader: "A/F Sensor #1 (AFR)",
            measurementType: .airFuelRatio,
            unit: "AFR"
        )
    ]

    let snapshots = [
        EngineSnapshot(
            sourceLineNumber: 2,
            values: [1952, 14.24]
        )
    ]

    let log = try EngineLog(
        columns: columns,
        snapshots: snapshots
    )

    #expect(log.columns.count == 2)
    #expect(log.snapshots.count == 1)
}

@Test
func rejectsSnapshotWhoseValueCountDoesNotMatchColumns() {
    let columns = [
        LogColumn(
            index: 0,
            originalHeader: "Engine Speed (rpm)",
            measurementType: .engineSpeed,
            unit: "rpm"
        ),
        LogColumn(
            index: 1,
            originalHeader: "A/F Sensor #1 (AFR)",
            measurementType: .airFuelRatio,
            unit: "AFR"
        )
    ]

    let invalidSnapshot = EngineSnapshot(
        sourceLineNumber: 3,
        values: [1984]
    )

    #expect(throws: EngineLogError.snapshotValueCountMismatch(
        sourceLineNumber: 3,
        expected: 2,
        actual: 1
    )) {
        try EngineLog(
            columns: columns,
            snapshots: [invalidSnapshot]
        )
    }
}

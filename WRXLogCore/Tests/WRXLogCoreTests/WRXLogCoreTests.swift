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

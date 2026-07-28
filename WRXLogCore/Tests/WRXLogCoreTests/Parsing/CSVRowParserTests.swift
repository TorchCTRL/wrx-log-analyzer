import Testing
@testable import WRXLogCore

@Test
func separatesOrdinaryCSVCells() throws {
    let cells = try CSVRowParser.cells(
        from: "1952,14.24,0.87"
    )

    #expect(cells == ["1952", "14.24", "0.87"])
}

@Test
func preservesBlankAndTrailingCells() throws {
    let cells = try CSVRowParser.cells(
        from: "3200,,15.2,"
    )

    #expect(cells == ["3200", "", "15.2", ""])
}

@Test
func supportsQuotedCommasAndEscapedQuotes() throws {
    let cells = try CSVRowParser.cells(
        from: "\"Custom \"\"Calculated\"\", Load\",3200"
    )

    #expect(cells == ["Custom \"Calculated\", Load", "3200"])
}

@Test
func rejectsUnterminatedQuotedField() {
    #expect(
        throws: CSVRowParserError.unterminatedQuotedField
    ) {
        try CSVRowParser.cells(
            from: "\"Engine Speed (rpm),AFR"
        )
    }
}

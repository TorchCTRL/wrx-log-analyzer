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

@Test
func recognizesKnownROMRaiderHeaders() {
    #expect(
        HeaderNormalizer.measurementType(
            for: "Engine Speed (rpm)"
        ) == .engineSpeed
    )

    #expect(
        HeaderNormalizer.measurementType(
            for: "A/F Sensor #1 (AFR)"
        ) == .airFuelRatio
    )

    #expect(
        HeaderNormalizer.measurementType(
            for: "Manifold Relative Pressure (psi)"
        ) == .boostPressure
    )
}

@Test
func recognizesAliasesRegardlessOfCaseAndOuterWhitespace() {
    #expect(
        HeaderNormalizer.measurementType(
            for: "  RPM  "
        ) == .engineSpeed
    )

    #expect(
        HeaderNormalizer.measurementType(
            for: "dam"
        ) == .dynamicAdvanceMultiplier
    )
}

@Test
func preservesUnknownMeasurementMeaning() {
    #expect(
        HeaderNormalizer.measurementType(
            for: "Custom Calculated Load (%)"
        ) == .unknown
    )
}

@Test
func extractsKnownUnitFromFinalHeaderSuffix() {
    #expect(
        HeaderUnitParser.unit(
            for: "Engine Load (2-byte)** (g/rev)"
        ) == "g/rev"
    )

    #expect(
        HeaderUnitParser.unit(
            for: "Manifold Relative Pressure (psi)"
        ) == "psi"
    )
}

@Test
func doesNotTreatMeasurementAbbreviationAsUnit() {
    #expect(
        HeaderUnitParser.unit(
            for: "A/F Sensor #1 (AFR)"
        ) == nil
    )

    #expect(
        HeaderUnitParser.unit(
            for: "Dynamic Advance Multiplier (DAM)"
        ) == nil
    )
}

@Test
func createsOrderedLogColumnsFromRawHeaders() {
    let headers = [
        "Engine Speed (rpm)",
        "A/F Sensor #1 (AFR)",
        "Manifold Relative Pressure (psi)"
    ]

    let columns = LogColumnFactory.columns(
        from: headers
    )

    #expect(columns.count == 3)

    #expect(columns[0].index == 0)
    #expect(columns[0].originalHeader == "Engine Speed (rpm)")
    #expect(columns[0].measurementType == .engineSpeed)
    #expect(columns[0].unit == "rpm")

    #expect(columns[1].index == 1)
    #expect(columns[1].measurementType == .airFuelRatio)
    #expect(columns[1].unit == nil)

    #expect(columns[2].index == 2)
    #expect(columns[2].measurementType == .boostPressure)
    #expect(columns[2].unit == "psi")
}

@Test
func createsMeasurementSeriesAndPreservesSamplePositions() throws {
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
            measurementType: .airFuelRatio
        )
    ]

    let snapshots = [
        EngineSnapshot(
            sourceLineNumber: 2,
            values: [2000, 14.7]
        ),
        EngineSnapshot(
            sourceLineNumber: 3,
            values: [nil, 14.6]
        ),
        EngineSnapshot(
            sourceLineNumber: 4,
            values: [2200, 14.5]
        )
    ]

    let log = try EngineLog(
        columns: columns,
        snapshots: snapshots
    )

    let series = log.series(for: .engineSpeed)

    #expect(series?.column == columns[0])
    #expect(
        series?.samples == [
            MeasurementSample(
                snapshotIndex: 0,
                sourceLineNumber: 2,
                value: 2000
            ),
            MeasurementSample(
                snapshotIndex: 2,
                sourceLineNumber: 4,
                value: 2200
            )
        ]
    )
}

@Test
func returnsNilWhenRequestedMeasurementIsAbsent() throws {
    let columns = [
        LogColumn(
            index: 0,
            originalHeader: "Engine Speed (rpm)",
            measurementType: .engineSpeed,
            unit: "rpm"
        )
    ]

    let log = try EngineLog(
        columns: columns,
        snapshots: [
            EngineSnapshot(
                sourceLineNumber: 2,
                values: [2000]
            )
        ]
    )

    #expect(log.series(for: .boostPressure) == nil)
}

@Test
func returnsNilForUnknownMeasurementSeries() throws {
    let columns = [
        LogColumn(
            index: 0,
            originalHeader: "Custom Measurement",
            measurementType: .unknown
        )
    ]

    let log = try EngineLog(
        columns: columns,
        snapshots: [
            EngineSnapshot(
                sourceLineNumber: 2,
                values: [42]
            )
        ]
    )

    #expect(log.series(for: .unknown) == nil)
}

@Test
func calculatesMeasurementSeriesStatistics() {
    let series = MeasurementSeries(
        column: LogColumn(
            index: 0,
            originalHeader: "Engine Speed (rpm)",
            measurementType: .engineSpeed,
            unit: "rpm"
        ),
        samples: [
            MeasurementSample(
                snapshotIndex: 0,
                sourceLineNumber: 2,
                value: 2000
            ),
            MeasurementSample(
                snapshotIndex: 1,
                sourceLineNumber: 3,
                value: 2500
            ),
            MeasurementSample(
                snapshotIndex: 2,
                sourceLineNumber: 4,
                value: 3000
            )
        ]
    )

    let statistics = series.statistics

    #expect(statistics?.minimum == 2000)
    #expect(statistics?.maximum == 3000)
    #expect(statistics?.average == 2500)
    #expect(statistics?.sampleCount == 3)
}

@Test
func returnsNilStatisticsForEmptySeries() {
    let series = MeasurementSeries(
        column: LogColumn(
            index: 0,
            originalHeader: "Engine Speed (rpm)",
            measurementType: .engineSpeed,
            unit: "rpm"
        ),
        samples: []
    )

    #expect(series.statistics == nil)
}

@Test
func recognizesExpandedROMRaiderHeaders() {
    #expect(
        HeaderNormalizer.measurementType(
            for: "Engine Load (2-byte)** (g/rev)"
        ) == .engineLoad
    )

    #expect(
        HeaderNormalizer.measurementType(
            for: "Ignition Total Timing (degrees)"
        ) == .ignitionTiming
    )

    #expect(
        HeaderNormalizer.measurementType(
            for: "Knock Sum* (count)"
        ) == .knockSum
    )

    #expect(
        HeaderNormalizer.measurementType(
            for: "Primary Wastegate Duty Cycle (%)"
        ) == .wastegateDutyCycle
    )

    #expect(
        HeaderNormalizer.measurementType(
            for: "Throttle Opening Angle (%)"
        ) == .throttleOpening
    )

    #expect(
        HeaderNormalizer.measurementType(
            for: """
            Turbo Dynamics Integral (2-byte)** (absolute %)
            """
        ) == .turboDynamicsIntegral
    )
}

@Test
func createsSummariesForRecognizedMeasurements() throws {
    let columns = [
        LogColumn(
            index: 0,
            originalHeader: "Engine Speed (rpm)",
            measurementType: .engineSpeed,
            unit: "rpm"
        ),
        LogColumn(
            index: 1,
            originalHeader: "Custom Measurement",
            measurementType: .unknown
        ),
        LogColumn(
            index: 2,
            originalHeader: "Manifold Relative Pressure (psi)",
            measurementType: .boostPressure,
            unit: "psi"
        ),
        LogColumn(
            index: 3,
            originalHeader: "A/F Sensor #1 (AFR)",
            measurementType: .airFuelRatio
        )
    ]

    let log = try EngineLog(
        columns: columns,
        snapshots: [
            EngineSnapshot(
                sourceLineNumber: 2,
                values: [2000, 42, 5, nil]
            ),
            EngineSnapshot(
                sourceLineNumber: 3,
                values: [3000, 43, nil, nil]
            )
        ]
    )

    let summaries = log.measurementSummaries

    #expect(summaries.count == 2)

    #expect(summaries[0].column == columns[0])
    #expect(
        summaries[0].statistics == MeasurementStatistics(
            minimum: 2000,
            maximum: 3000,
            average: 2500,
            sampleCount: 2
        )
    )

    #expect(summaries[1].column == columns[2])
    #expect(
        summaries[1].statistics == MeasurementStatistics(
            minimum: 5,
            maximum: 5,
            average: 5,
            sampleCount: 1
        )
    )
}

@Test
func createsObjectiveLogInsights() throws {
    let columns = [
        LogColumn(
            index: 0,
            originalHeader: "Engine Speed (rpm)",
            measurementType: .engineSpeed,
            unit: "rpm"
        ),
        LogColumn(
            index: 1,
            originalHeader: "Custom Measurement",
            measurementType: .unknown
        )
    ]

    let log = try EngineLog(
        columns: columns,
        snapshots: [
            EngineSnapshot(
                sourceLineNumber: 2,
                values: [2000, 42]
            ),
            EngineSnapshot(
                sourceLineNumber: 3,
                values: [nil, 43]
            )
        ]
    )

    let result = ROMRaiderParseResult(
        log: log,
        warnings: [
            .blankValue(
                sourceLineNumber: 3,
                columnIndex: 0,
                header: "Engine Speed (rpm)"
            )
        ],
        totalDataRowCount: 3,
        skippedRowCount: 1
    )

    #expect(
        result.insights == [
            LogInsight.importQuality(
                parsedRowCount: 2,
                totalDataRowCount: 3,
                skippedRowCount: 1,
                warningCount: 1
            ),
            LogInsight.measurementRecognition(
                recognizedColumnCount: 1,
                totalColumnCount: 2
            ),
            LogInsight.valueCoverage(
                validValueCount: 1,
                totalValueCount: 2
            )
        ]
    )
}

@Test
func distinguishesCompleteAndIncompleteAnalysisProfiles() {
    let completeProfile = AnalysisProfile(
        modelYear: 2013,
        engineFamily: .ej255,
        tuneType: .stock,
        fuelType: .octane93,
        logCondition: .wideOpenThrottle
    )

    #expect(completeProfile.modelYear == 2013)
    #expect(completeProfile.engineFamily == .ej255)
    #expect(completeProfile.tuneType == .stock)
    #expect(completeProfile.fuelType == .octane93)
    #expect(completeProfile.logCondition == .wideOpenThrottle)
    #expect(completeProfile.isComplete)

    let incompleteProfile = AnalysisProfile(
        modelYear: nil,
        engineFamily: .unknown,
        tuneType: .unknown,
        fuelType: .unknown,
        logCondition: .unknown
    )

    #expect(!incompleteProfile.isComplete)
}

@Test
func returnsMostSignificantFindingForGreaterThanRule() throws {
    let log = try EngineLog(
        columns: [
            LogColumn(
                index: 0,
                originalHeader: "Engine Speed (rpm)",
                measurementType: .engineSpeed,
                unit: "rpm"
            )
        ],
        snapshots: [
            EngineSnapshot(
                sourceLineNumber: 2,
                values: [2500]
            ),
            EngineSnapshot(
                sourceLineNumber: 3,
                values: [3500]
            ),
            EngineSnapshot(
                sourceLineNumber: 4,
                values: [3200]
            )
        ]
    )

    let rule = MeasurementThresholdRule(
        title: "Example Engine Speed Rule",
        measurementType: .engineSpeed,
        comparison: .greaterThan,
        threshold: 3000,
        severity: .caution
    )

    let finding = try #require(
        log.finding(for: rule)
    )

    #expect(finding.rule == rule)
    #expect(finding.observedValue == 3500)
    #expect(finding.snapshotIndex == 1)
    #expect(finding.sourceLineNumber == 3)
}

@Test
func evaluatesMultipleThresholdRulesInOrder() throws {
    let log = try EngineLog(
        columns: [
            LogColumn(
                index: 0,
                originalHeader: "Engine Speed (rpm)",
                measurementType: .engineSpeed,
                unit: "rpm"
            ),
            LogColumn(
                index: 1,
                originalHeader: "Manifold Relative Pressure (psi)",
                measurementType: .boostPressure,
                unit: "psi"
            )
        ],
        snapshots: [
            EngineSnapshot(
                sourceLineNumber: 2,
                values: [2500, -2]
            ),
            EngineSnapshot(
                sourceLineNumber: 3,
                values: [3500, 5]
            ),
            EngineSnapshot(
                sourceLineNumber: 4,
                values: [3200, 1]
            )
        ]
    )

    let highEngineSpeedRule = MeasurementThresholdRule(
        title: "Example High Engine Speed",
        measurementType: .engineSpeed,
        comparison: .greaterThan,
        threshold: 3000,
        severity: .caution
    )

    let lowBoostRule = MeasurementThresholdRule(
        title: "Example Low Boost",
        measurementType: .boostPressure,
        comparison: .lessThan,
        threshold: 0,
        severity: .information
    )

    let absentAFRRule = MeasurementThresholdRule(
        title: "Example AFR Rule",
        measurementType: .airFuelRatio,
        comparison: .lessThan,
        threshold: 10,
        severity: .critical
    )

    let findings = log.findings(
        for: [
            highEngineSpeedRule,
            lowBoostRule,
            absentAFRRule
        ]
    )

    #expect(findings.count == 2)

    #expect(findings[0].rule == highEngineSpeedRule)
    #expect(findings[0].observedValue == 3500)
    #expect(findings[0].sourceLineNumber == 3)

    #expect(findings[1].rule == lowBoostRule)
    #expect(findings[1].observedValue == -2)
    #expect(findings[1].sourceLineNumber == 2)
}

@Test
func returnsNilWhenNoSampleViolatesThresholdRule() throws {
    let log = try EngineLog(
        columns: [
            LogColumn(
                index: 0,
                originalHeader: "Engine Speed (rpm)",
                measurementType: .engineSpeed,
                unit: "rpm"
            )
        ],
        snapshots: [
            EngineSnapshot(
                sourceLineNumber: 2,
                values: [2500]
            ),
            EngineSnapshot(
                sourceLineNumber: 3,
                values: [3000]
            )
        ]
    )

    let rule = MeasurementThresholdRule(
        title: "Example Nonviolating Rule",
        measurementType: .engineSpeed,
        comparison: .greaterThan,
        threshold: 3000,
        severity: .information
    )

    #expect(log.finding(for: rule) == nil)
}

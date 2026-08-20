import Charts
import SwiftUI
import WRXLogCore

struct MeasurementChartView: View {
    let log: EngineLog

    @State private var selectedSeriesIndex = 0

    private let supportedMeasurementTypes: [MeasurementType] = [
        .engineSpeed,
        .airFuelRatio,
        .boostPressure,
        .engineLoad,
        .ignitionTiming,
        .knockSum,
        .feedbackKnock,
        .fineLearningKnock,
        .wastegateDutyCycle,
        .throttleOpening,
        .turboDynamicsIntegral,
        .dynamicAdvanceMultiplier
    ]

    private var availableSeries: [MeasurementSeries] {
        supportedMeasurementTypes.compactMap {
            log.series(for: $0)
        }
    }

    var body: some View {
        Group {
            if availableSeries.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.xyaxis.line")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)

                    Text("No Graphable Measurements")
                        .font(.headline)

                    Text(
                        "This log does not contain any supported measurements."
                    )
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                }
                .padding()
            } else {
                chartContent
            }
        }
        .navigationTitle("Measurement Chart")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var chartContent: some View {
        let series = availableSeries[selectedSeriesIndex]
        let selectedMeasurementName = measurementName(
            for: series.column.measurementType
        )

        return VStack(alignment: .leading, spacing: 20) {
            Picker(
                "Measurement",
                selection: $selectedSeriesIndex
            ) {
                ForEach(
                    availableSeries.indices,
                    id: \.self
                ) { index in
                    Text(
                        measurementName(
                            for: availableSeries[index]
                                .column.measurementType
                        )
                    )
                    .tag(index)
                }
            }
            .pickerStyle(.menu)

            VStack(alignment: .leading, spacing: 4) {
                Text(series.column.originalHeader)
                    .font(.headline)

                Text("\(series.samples.count) valid samples")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let statistics = series.statistics {
                HStack(spacing: 8) {
                    statisticCard(
                        title: "Minimum",
                        value: statistics.minimum,
                        unit: series.column.unit
                    )

                    statisticCard(
                        title: "Average",
                        value: statistics.average,
                        unit: series.column.unit
                    )

                    statisticCard(
                        title: "Maximum",
                        value: statistics.maximum,
                        unit: series.column.unit
                    )
                }
            }

            Chart(
                series.samples,
                id: \.snapshotIndex
            ) { sample in
                LineMark(
                    x: .value(
                        "Sample",
                        sample.snapshotIndex + 1
                    ),
                    y: .value(
                        selectedMeasurementName,
                        sample.value
                    )
                )
                .foregroundStyle(.blue)

                PointMark(
                    x: .value(
                        "Sample",
                        sample.snapshotIndex + 1
                    ),
                    y: .value(
                        selectedMeasurementName,
                        sample.value
                    )
                )
                .foregroundStyle(.blue)
            }
            .chartXAxisLabel("Sample")
            .chartYAxisLabel(
                series.column.unit ?? selectedMeasurementName
            )
            .frame(height: 320)

            Spacer()
        }
        .padding()
    }

    private func measurementName(
        for measurementType: MeasurementType
    ) -> String {
        switch measurementType {
        case .engineSpeed:
            return "Engine Speed"
        case .airFuelRatio:
            return "Air-Fuel Ratio"
        case .boostPressure:
            return "Boost Pressure"
        case .engineLoad:
            return "Engine Load"
        case .ignitionTiming:
            return "Ignition Timing"
        case .knockSum:
            return "Knock Sum"
        case .feedbackKnock:
            return "Feedback Knock"
        case .fineLearningKnock:
            return "Fine Learning Knock"
        case .wastegateDutyCycle:
            return "Wastegate Duty Cycle"
        case .throttleOpening:
            return "Throttle Opening"
        case .turboDynamicsIntegral:
            return "Turbo Dynamics Integral"
        case .dynamicAdvanceMultiplier:
            return "Dynamic Advance Multiplier"
        case .unknown:
            return "Unknown Measurement"
        }
    }

    private func statisticCard(
        title: String,
        value: Double,
        unit: String?
    ) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(
                formattedValue(
                    value,
                    unit: unit
                )
            )
            .font(.headline)
            .lineLimit(1)
            .minimumScaleFactor(0.65)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            .thinMaterial,
            in: RoundedRectangle(cornerRadius: 12)
        )
    }

    private func formattedValue(
        _ value: Double,
        unit: String?
    ) -> String {
        let number = value.formatted(
            .number.precision(
                .fractionLength(0...2)
            )
        )

        if let unit {
            return "\(number) \(unit)"
        }

        return number
    }
}

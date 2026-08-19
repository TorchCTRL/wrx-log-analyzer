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
        .feedbackKnock,
        .fineLearningKnock,
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
        case .feedbackKnock:
            return "Feedback Knock"
        case .fineLearningKnock:
            return "Fine Learning Knock"
        case .dynamicAdvanceMultiplier:
            return "Dynamic Advance Multiplier"
        case .unknown:
            return "Unknown Measurement"
        }
    }
}

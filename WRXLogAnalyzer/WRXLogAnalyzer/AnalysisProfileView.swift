import SwiftUI
import WRXLogCore

struct AnalysisProfileView: View {
    @Binding var profile: AnalysisProfile

    var body: some View {
        Form {
            Section("Vehicle") {
                LabeledContent("Model Year") {
                    TextField(
                        "Year",
                        text: modelYearText
                    )
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                }

                Picker(
                    "Engine Family",
                    selection: $profile.engineFamily
                ) {
                    ForEach(
                        EngineFamily.allCases,
                        id: \.self
                    ) { engineFamily in
                        Text(engineFamily.rawValue)
                            .tag(engineFamily)
                    }
                }
            }

            Section("Calibration and Fuel") {
                Picker(
                    "Tune Type",
                    selection: $profile.tuneType
                ) {
                    ForEach(
                        TuneType.allCases,
                        id: \.self
                    ) { tuneType in
                        Text(tuneType.rawValue)
                            .tag(tuneType)
                    }
                }

                Picker(
                    "Fuel",
                    selection: $profile.fuelType
                ) {
                    ForEach(
                        FuelType.allCases,
                        id: \.self
                    ) { fuelType in
                        Text(fuelType.rawValue)
                            .tag(fuelType)
                    }
                }
            }

            Section("Log Context") {
                Picker(
                    "Driving Condition",
                    selection: $profile.logCondition
                ) {
                    ForEach(
                        LogCondition.allCases,
                        id: \.self
                    ) { logCondition in
                        Text(logCondition.rawValue)
                            .tag(logCondition)
                    }
                }
            }

            Section("Profile Status") {
                if profile.isComplete {
                    Label(
                        "Ready for compatible analysis rules",
                        systemImage: "checkmark.circle.fill"
                    )
                    .foregroundStyle(.green)
                } else {
                    Label(
                        "More information is required",
                        systemImage: "exclamationmark.triangle.fill"
                    )
                    .foregroundStyle(.orange)

                    Text(
                        """
                        Enter a model year and replace every “Not Sure” \
                        selection before health-analysis rules can run.
                        """
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }

            Section {
                Text(
                    """
                    Completing this profile does not diagnose the engine. \
                    It only provides context for compatible analysis rules.
                    """
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Analysis Profile")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var modelYearText: Binding<String> {
        Binding(
            get: {
                guard let modelYear = profile.modelYear else {
                    return ""
                }

                return String(modelYear)
            },
            set: { newValue in
                profile.modelYear = Int(newValue)
            }
        )
    }
}

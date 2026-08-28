import SwiftUI
import UniformTypeIdentifiers
import WRXLogCore

struct ContentView: View {
    @State private var analysisProfile = AnalysisProfile(
        modelYear: nil,
        engineFamily: .unknown,
        tuneType: .unknown,
        fuelType: .unknown,
        logCondition: .unknown
    )

    private let analysisProfileStore = AnalysisProfileStore()
    @State private var isShowingFileImporter = false
    @State private var importMessage = "No log imported yet."

    @State private var importedResult: ROMRaiderParseResult?
    @State private var importedFileName = ""
    @State private var isShowingImportResults = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)
                Text("WRX Log Analyzer")
                    .font(.title)
                    .fontWeight(.bold)
                Text(importMessage)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                Button("Import ROMRaider CSV") {
                    isShowingFileImporter = true
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
                .onAppear {
                    if let savedProfile = analysisProfileStore.load() {
                        analysisProfile = savedProfile
                    }
                }
                .onChange(of: analysisProfile) { _, newProfile in
                    try? analysisProfileStore.save(newProfile)
                }
            .padding()
            .fileImporter(
                isPresented: $isShowingFileImporter,
                allowedContentTypes: [.commaSeparatedText],
                allowsMultipleSelection: false
            ) { result in
                handleFileSelection(result)
            }
            .navigationDestination(
                isPresented: $isShowingImportResults
            ) {
                if let importedResult {
                    ImportResultsView(
                        fileName: importedFileName,
                        result: importedResult,
                        analysisProfile: $analysisProfile
                    )
                }
            }
        }
    }

    private func handleFileSelection(
        _ result: Result<[URL], Error>
    ) {
        switch result {
        case .success(let urls):
            guard let fileURL = urls.first else {
                importMessage = "No file was selected."
                return
            }

            importCSV(from: fileURL)

        case .failure(let error):
            importMessage = "File selection failed: \(error.localizedDescription)"
        }
    }

    private func importCSV(from fileURL: URL) {
        let receivedAccess =
            fileURL.startAccessingSecurityScopedResource()

        defer {
            if receivedAccess {
                fileURL.stopAccessingSecurityScopedResource()
            }
        }

        do {
            let csvText = try String(
                contentsOf: fileURL,
                encoding: .utf8
            )

            let result = try ROMRaiderCSVParser.parse(csvText)

            importedResult = result
            importedFileName = fileURL.lastPathComponent

            importMessage = """
            Imported \(fileURL.lastPathComponent)
            Columns: \(result.log.columns.count)
            Rows: \(result.log.snapshots.count)
            Warnings: \(result.warnings.count)
            """
            isShowingImportResults = true

        } catch {
            importMessage = """
            Could not import \(fileURL.lastPathComponent):
            \(error.localizedDescription)
            """
        }
    }
}

#Preview {
    ContentView()
}

import Foundation
import Testing
import WRXLogCore

@testable import WRXLogAnalyzer

struct WRXLogAnalyzerTests {

    @Test
    func savesAndLoadsAnalysisProfile() throws {
        let suiteName =
            "WRXLogAnalyzerTests.AnalysisProfileStore.\(UUID().uuidString)"

        let defaults = try #require(
            UserDefaults(suiteName: suiteName)
        )

        defer {
            defaults.removePersistentDomain(
                forName: suiteName
            )
        }

        let store = AnalysisProfileStore(
            defaults: defaults
        )

        let originalProfile = AnalysisProfile(
            modelYear: 2013,
            engineFamily: .ej255,
            tuneType: .custom,
            fuelType: .octane93,
            logCondition: .wideOpenThrottle
        )

        try store.save(originalProfile)

        let loadedProfile = store.load()

        #expect(loadedProfile == originalProfile)
    }

}

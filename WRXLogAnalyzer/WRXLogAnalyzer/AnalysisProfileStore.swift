import Foundation
import WRXLogCore

struct AnalysisProfileStore {

    private let defaults: UserDefaults

    private let storageKey = "analysisProfile"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func save(_ profile: AnalysisProfile) throws {
        let data = try JSONEncoder().encode(profile)
        defaults.set(data, forKey: storageKey)
    }

    func load() -> AnalysisProfile? {
        guard let data = defaults.data(
            forKey: storageKey
        ) else {
            return nil
        }

        return try? JSONDecoder().decode(
            AnalysisProfile.self,
            from: data
        )
    }
}

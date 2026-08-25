/// Identifies the documentation supporting an analysis rule.
public struct AnalysisRuleSource: Equatable, Sendable {
    public let title: String
    public let url: String

    public init(
        title: String,
        url: String
    ) {
        self.title = title
        self.url = url
    }
}

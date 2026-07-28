/// Describes a structural problem that prevents an `EngineLog`
/// from being created in a valid state.
public enum EngineLogError: Error, Equatable, Sendable {
    case snapshotValueCountMismatch(
        sourceLineNumber: Int,
        expected: Int,
        actual: Int
    )
}

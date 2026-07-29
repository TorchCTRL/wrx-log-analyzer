/// Describes a problem that prevents a ROMRaider CSV file
/// from being interpreted as a log.
public enum ROMRaiderCSVParserError: Error, Equatable, Sendable {
    case emptyFile
    case missingHeader
    case malformedHeader
}

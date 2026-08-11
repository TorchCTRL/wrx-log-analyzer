/// Creates structured log-column models from raw CSV headers.
public enum LogColumnFactory {
    public static func columns(
        from rawHeaders: [String]
    ) -> [LogColumn] {
        rawHeaders.enumerated().map { index, rawHeader in
            LogColumn(
                index: index,
                originalHeader: rawHeader,
                measurementType: HeaderNormalizer.measurementType(
                    for: rawHeader
                ),
                unit: HeaderUnitParser.unit(
                    for: rawHeader
                )
            )
        }
    }
}

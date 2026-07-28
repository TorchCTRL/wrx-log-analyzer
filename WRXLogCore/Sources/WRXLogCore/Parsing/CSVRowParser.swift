/// Separates one CSV row into its individual cell values.
///
/// Supports empty cells, quoted commas, and escaped quotation marks.
public enum CSVRowParser {
    public static func cells(
        from rawLine: String
    ) throws -> [String] {
        let line: String

        // A line split on "\n" may still contain the "\r" from
        // Windows-style CRLF line endings.
        if rawLine.hasSuffix("\r") {
            line = String(rawLine.dropLast())
        } else {
            line = rawLine
        }

        let characters = Array(line)
        var cells: [String] = []
        var currentCell = ""
        var isInsideQuotes = false
        var index = 0

        while index < characters.count {
            let character = characters[index]

            if character == "\"" {
                if isInsideQuotes {
                    let nextIndex = index + 1

                    if nextIndex < characters.count,
                       characters[nextIndex] == "\"" {
                        // Two consecutive quotes inside a quoted field
                        // represent one literal quotation mark.
                        currentCell.append("\"")
                        index += 1
                    } else {
                        isInsideQuotes = false
                    }
                } else if currentCell.isEmpty {
                    isInsideQuotes = true
                } else {
                    // A quote appearing inside an unquoted value is
                    // preserved as ordinary text.
                    currentCell.append(character)
                }
            } else if character == ",", !isInsideQuotes {
                cells.append(currentCell)
                currentCell = ""
            } else {
                currentCell.append(character)
            }

            index += 1
        }

        guard !isInsideQuotes else {
            throw CSVRowParserError.unterminatedQuotedField
        }

        // Always append the final cell, including an empty trailing cell.
        cells.append(currentCell)

        return cells
    }
}

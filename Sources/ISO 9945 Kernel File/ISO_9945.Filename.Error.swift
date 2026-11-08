public import Binary


extension ISO_9945.Filename {
    public enum Error: Swift::Error, Sendable, Equatable {

        case empty

        case containsPathSeparator

        case containsControlCharacters

        case containsInteriorNUL

        case invalidUTF8
    }
}

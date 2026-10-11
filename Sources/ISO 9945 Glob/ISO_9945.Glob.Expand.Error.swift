extension ISO_9945.Glob.Expand {

    public enum Error: Swift.Error, Sendable, Equatable {

        case noSpace

        case aborted

        case noMatch

        case unrecognized(code: Int32)
    }
}

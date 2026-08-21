extension ISO_9945.Glob.Fnmatch {

    public enum Error: Swift.Error, Sendable, Equatable {

        case failed(code: Int32)
    }
}

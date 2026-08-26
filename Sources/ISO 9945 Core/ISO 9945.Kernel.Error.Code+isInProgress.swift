extension Error.Error.Code {

    @inlinable
    public var isInProgress: Bool {
        self == .posix(Error.Error.Number.inProgress.underlying)
    }
}

extension Error_Primitives.Error.Code {

    @inlinable
    public var isInProgress: Bool {
        self == .posix(Error_Primitives.Error.Number.inProgress.underlying)
    }
}

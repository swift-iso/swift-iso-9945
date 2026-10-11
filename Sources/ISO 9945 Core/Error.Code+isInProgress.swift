extension Error::Error.Code {

    @inlinable
    public var isInProgress: Bool {
        self == .EINPROGRESS
    }
}

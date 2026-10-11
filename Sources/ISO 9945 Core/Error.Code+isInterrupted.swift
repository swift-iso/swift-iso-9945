extension Error::Error.Code {

    @inlinable
    public var isInterrupted: Bool {
        self == .EINTR
    }
}

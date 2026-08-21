extension Error_Primitives.Error.Code {

    @inlinable
    public var isInterrupted: Bool {
        self == .POSIX.EINTR
    }
}

extension ISO_9945.Kernel.Socket.Shutdown.Error {

    @usableFromInline
    internal init(code: Error.Error.Code) {
        self = .platform(Error.Error(code: code))
    }
}

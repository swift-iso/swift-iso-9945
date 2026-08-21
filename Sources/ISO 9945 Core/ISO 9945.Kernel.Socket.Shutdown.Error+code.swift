extension ISO_9945.Kernel.Socket.Shutdown.Error {

    @usableFromInline
    internal init(code: Error_Primitives.Error.Code) {
        self = .platform(Error_Primitives.Error(code: code))
    }
}

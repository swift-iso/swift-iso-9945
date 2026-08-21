extension ISO_9945.Kernel.Directory.Working.Error {

    @usableFromInline
    internal init(code: Error_Primitives.Error.Code) {
        if let e = Path.Resolution.Error(code: code) {
            self = .path(e)
            return
        }
        self = .platform(Error_Primitives.Error(code: code))
    }
}

extension ISO_9945.Kernel.File.Direct.Error {

    public init(from syscall: Syscall) {
        switch syscall {
        case .invalidDescriptor:
            self = .invalidHandle

        case .alignmentViolation(let operation):
            self = .platform(code: .posix(-1), operation: operation)

        case .notSupported:
            self = .notSupported

        case .platform(let code, let operation):
            self.init(code: code, operation: operation)
        }
    }

    @usableFromInline
    internal init(code: Error::Error.Code, operation: Operation) {
        switch code {
        case _ where code == .EINVAL:
            self = .platform(code: code, operation: operation)

        case _ where code == .EBADF:
            self = .invalidHandle

        case _ where Error::Error.Code.POSIX.isENOTSUP(code):
            self = .notSupported

        default:
            self = .platform(code: code, operation: operation)
        }
    }
}

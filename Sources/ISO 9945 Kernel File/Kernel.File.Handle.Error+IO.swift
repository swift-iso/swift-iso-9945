extension ISO_9945.Kernel.File.Handle.Error {
    public init(
        from error: ISO_9945.Kernel.IO.Read.Error,
        operation: ISO_9945.Kernel.File.Handle.Operation
    ) {
        switch error {
        case .handle(let handleError):
            switch handleError {
            case .invalid, .limit:
                self = .invalidHandle
            }

        case .blocking:

            self = .platform(code: Error_Primitives.Error.Code.POSIX.EAGAIN, operation: operation)

        case .platform(let platformError):

            self = .platform(code: platformError.code, operation: operation)
        }
    }

    public init(
        from error: ISO_9945.Kernel.IO.Write.Error,
        operation: ISO_9945.Kernel.File.Handle.Operation
    ) {
        switch error {
        case .handle(let handleError):
            switch handleError {
            case .invalid, .limit:
                self = .invalidHandle
            }

        case .blocking:

            self = .platform(code: Error_Primitives.Error.Code.POSIX.EAGAIN, operation: operation)

        case .platform(let platformError):

            self = .platform(code: platformError.code, operation: operation)
        }
    }
}

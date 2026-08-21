extension ISO_9945.Kernel.Lock.Error {

    @inlinable
    public init?(code: Error_Primitives.Error.Code) {
        if code == Error_Primitives.Error.Code.POSIX.EAGAIN
            || code == Error_Primitives.Error.Code.POSIX.EACCES
        {

            self = .contention
        } else if code == Error_Primitives.Error.Code.POSIX.EDEADLK {
            self = .deadlock
        } else if code == Error_Primitives.Error.Code.POSIX.ENOLCK {
            self = .unavailable
        } else if code == Error_Primitives.Error.Code.POSIX.EINTR {
            self = .interrupted
        } else {
            return nil
        }
    }
}

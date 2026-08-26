extension ISO_9945.Kernel.Lock.Error {

    @inlinable
    public init?(code: Error.Error.Code) {
        if code == Error.Error.Code.POSIX.EAGAIN
            || code == Error.Error.Code.POSIX.EACCES
        {

            self = .contention
        } else if code == Error.Error.Code.POSIX.EDEADLK {
            self = .deadlock
        } else if code == Error.Error.Code.POSIX.ENOLCK {
            self = .unavailable
        } else if code == Error.Error.Code.POSIX.EINTR {
            self = .interrupted
        } else {
            return nil
        }
    }
}

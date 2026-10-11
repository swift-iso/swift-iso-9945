extension ISO_9945.Kernel.Lock.Error {

    @inlinable
    public init?(code: Error::Error.Code) {
        if code == Error::Error.Code.EAGAIN
            || code == Error::Error.Code.EACCES
        {

            self = .contention
        } else if code == Error::Error.Code.EDEADLK {
            self = .deadlock
        } else if code == Error::Error.Code.ENOLCK {
            self = .unavailable
        } else if code == Error::Error.Code.EINTR {
            self = .interrupted
        } else {
            return nil
        }
    }
}

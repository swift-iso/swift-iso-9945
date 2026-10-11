import Memory

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension Memory.Lock {

    public enum All {}
}

extension Memory.Lock {

    public static func lockAll(flags: Int32) throws(Error) {
        guard mlockall(flags) == 0 else {
            throw .lockAll(.captureErrno())
        }
    }

    public static func unlockAll() throws(Error) {
        guard munlockall() == 0 else {
            throw .unlockAll(.captureErrno())
        }
    }
}

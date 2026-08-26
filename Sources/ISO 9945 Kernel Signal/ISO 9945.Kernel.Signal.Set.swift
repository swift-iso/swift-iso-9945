#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Signal {

    public struct Set: Sendable {
        internal var storage: sigset_t

        public init() {
            self.storage = sigset_t()
            unsafe sigemptyset(&self.storage)
        }
    }
}

extension ISO_9945.Kernel.Signal.Set {

    public static var all: Self {
        var set = Self()
        unsafe sigfillset(&set.storage)
        return set
    }

    public init(_ signal: ISO_9945.Kernel.Signal.Number) throws(ISO_9945.Kernel.Signal.Error) {
        self.init()
        guard unsafe sigaddset(&self.storage, signal.rawValue) == 0 else {
            throw .set(Error.Error.captureErrno())
        }
    }

    public init(
        _ signals: some Swift.Sequence<ISO_9945.Kernel.Signal.Number>
    ) throws(ISO_9945.Kernel.Signal.Error) {
        self.init()
        for signal in signals {
            guard unsafe sigaddset(&self.storage, signal.rawValue) == 0 else {
                throw .set(Error.Error.captureErrno())
            }
        }
    }

    public init(__unchecked: Void, _ signal: ISO_9945.Kernel.Signal.Number) {
        self.init()
        _ = unsafe sigaddset(&self.storage, signal.rawValue)
    }

    public mutating func insert(
        _ signal: ISO_9945.Kernel.Signal.Number
    ) throws(ISO_9945.Kernel.Signal.Error) {
        guard unsafe sigaddset(&self.storage, signal.rawValue) == 0 else {
            throw .set(Error.Error.captureErrno())
        }
    }

    public mutating func remove(
        _ signal: ISO_9945.Kernel.Signal.Number
    ) throws(ISO_9945.Kernel.Signal.Error) {
        guard unsafe sigdelset(&self.storage, signal.rawValue) == 0 else {
            throw .set(Error.Error.captureErrno())
        }
    }

    public func contains(
        _ signal: ISO_9945.Kernel.Signal.Number
    ) throws(ISO_9945.Kernel.Signal.Error) -> Bool {
        var mutableStorage = storage
        let result = unsafe sigismember(&mutableStorage, signal.rawValue)
        guard result >= 0 else {
            throw .set(Error.Error.captureErrno())
        }
        return result == 1
    }
}

extension ISO_9945.Kernel.Signal.Set {

    @unsafe
    internal func withUnsafePointer<R, E: Swift.Error>(
        _ body: (UnsafePointer<sigset_t>) throws(E) -> R
    ) throws(E) -> R {
        try Swift.withUnsafePointer(to: storage, body)
    }

    @unsafe
    @_spi(Syscall)
    public func withUnsafeRawPointer<R, E: Swift.Error>(
        _ body: (UnsafeRawPointer) throws(E) -> R
    ) throws(E) -> R {
        try unsafe withUnsafePointer { (pointer: UnsafePointer<sigset_t>) throws(E) -> R in
            try unsafe body(unsafe UnsafeRawPointer(pointer))
        }
    }

    @unsafe
    internal mutating func withUnsafeMutablePointer<R, E: Swift.Error>(
        _ body: (UnsafeMutablePointer<sigset_t>) throws(E) -> R
    ) throws(E) -> R {
        try Swift.withUnsafeMutablePointer(to: &storage, body)
    }

    internal init(storage: sigset_t) {
        self.storage = storage
    }
}

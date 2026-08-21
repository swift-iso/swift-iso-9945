#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Thread {

    public final class Key: @unchecked Sendable {
        private var key: pthread_key_t

        public init() throws(ISO_9945.Kernel.Thread.Error) {
            self.key = pthread_key_t()

            let result = unsafe pthread_key_create(&self.key, nil)
            guard result == 0 else {
                throw .keyCreate(.posix(result))
            }
        }

        public init(
            destructor: @convention(c) (UnsafeMutableRawPointer) -> Void
        ) throws(ISO_9945.Kernel.Thread.Error) {
            self.key = pthread_key_t()

            let result: Int32
            #if canImport(Darwin)
                result = unsafe pthread_key_create(&self.key, destructor)
            #else

                let optDestructor = unsafe unsafeBitCast(
                    destructor,
                    to: (@convention(c) (UnsafeMutableRawPointer?) -> Void).self
                )
                result = unsafe pthread_key_create(&self.key, optDestructor)
            #endif
            guard result == 0 else {
                throw .keyCreate(.posix(result))
            }
        }

        deinit {
            pthread_key_delete(key)
        }
    }
}

extension ISO_9945.Kernel.Thread.Key {

    public var value: UnsafeMutableRawPointer? {
        get {
            unsafe pthread_getspecific(key)
        }
        set {
            unsafe (_ = pthread_setspecific(key, newValue))
        }
    }

    public func setValue(_ newValue: UnsafeMutableRawPointer?) throws(ISO_9945.Kernel.Thread.Error)
    {

        let result = unsafe pthread_setspecific(key, newValue)
        guard result == 0 else {
            throw .keySet(.posix(result))
        }
    }
}

#if !os(Windows)

    import Memory_Primitives

    #if canImport(Darwin)
        internal import Darwin
    #elseif canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    extension Memory.Lock {

        @unsafe
        public static func lock(
            address: UnsafeRawPointer,
            length: Memory.Address.Count
        ) throws(Error) {
            guard unsafe (mlock(address, Int(bitPattern: length.underlying.rawValue)) == 0) else {
                throw .lock(.captureErrno())
            }
        }

        @unsafe
        public static func unlock(
            address: UnsafeRawPointer,
            length: Memory.Address.Count
        ) throws(Error) {
            guard unsafe (munlock(address, Int(bitPattern: length.underlying.rawValue)) == 0) else {
                throw .unlock(.captureErrno())
            }
        }
    }

#endif

#if !os(Windows)

    import Memory_Primitives

    #if canImport(Darwin)
        internal import Darwin
    #elseif canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    extension Memory.Map {

        @unsafe
        public static func advise(
            addr: UnsafeMutableRawPointer,
            length: Memory.Address.Count,
            advice: Memory.Map.Advice
        ) {

            _ = unsafe madvise(addr, Int(bitPattern: length.underlying.rawValue), advice.rawValue)
        }

        @unsafe
        public static func advise(
            addr: UnsafeRawPointer,
            length: Memory.Address.Count,
            advice: Memory.Map.Advice
        ) {
            _ = unsafe madvise(
                UnsafeMutableRawPointer(mutating: addr),
                Int(bitPattern: length.underlying.rawValue),
                advice.rawValue
            )
        }
    }

#endif

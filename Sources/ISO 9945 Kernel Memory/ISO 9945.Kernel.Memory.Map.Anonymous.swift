#if !os(Windows)

    import Memory_Primitives

    #if canImport(Darwin)
        internal import Darwin
    #elseif canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    extension Memory.Map.Anonymous {

        public static func map(
            length: Memory.Address.Count,
            protection: Memory.Map.Protection = [.read, .write],
            shared: Bool = false
        ) throws(Memory.Map.Error) -> Memory.Map.Region {
            let sharingFlag = shared ? Memory.Map.Options.shared : Memory.Map.Options.private
            let flags = Memory.Map.Options(
                rawValue: Memory.Map.Options.anonymous.rawValue | sharingFlag.rawValue
            )

            let addr = try Memory.Map.map(
                length: length,
                protection: protection,
                flags: flags
            )

            return Memory.Map.Region(base: addr, length: length)
        }
    }

#endif

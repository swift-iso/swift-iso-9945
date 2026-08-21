#if !os(Windows)

    #if canImport(Darwin)
        internal import Darwin
    #elseif canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #elseif canImport(Android)
        internal import Android
    #endif

    extension ISO_9945.Kernel.File {

        public struct Advice: RawRepresentable, Sendable, Equatable, Hashable {
            public let rawValue: UInt32

            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }
        }
    }

    #if os(Linux) || os(Android) || os(OpenBSD) || os(FreeBSD)

        extension ISO_9945.Kernel.File.Advice {

            public static let normal = Self(rawValue: UInt32(POSIX_FADV_NORMAL))

            public static let random = Self(rawValue: UInt32(POSIX_FADV_RANDOM))

            public static let sequential = Self(rawValue: UInt32(POSIX_FADV_SEQUENTIAL))

            public static let willNeed = Self(rawValue: UInt32(POSIX_FADV_WILLNEED))

            public static let dontNeed = Self(rawValue: UInt32(POSIX_FADV_DONTNEED))

            public static let noReuse = Self(rawValue: UInt32(POSIX_FADV_NOREUSE))
        }

    #endif

#endif

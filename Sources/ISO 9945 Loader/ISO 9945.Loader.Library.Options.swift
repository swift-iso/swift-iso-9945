public import ISO_9945_Core
public import Loader_Primitives

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

#if canImport(Darwin) || canImport(Glibc) || canImport(Musl)

    extension ISO_9945.Loader.Library {

        public struct Options: OptionSet, Sendable, Hashable {
            public let rawValue: Int32

            @inlinable
            public init(rawValue: Int32) {
                self.rawValue = rawValue
            }
        }
    }

    extension ISO_9945.Loader.Library.Options {

        public static let lazy = Self(rawValue: RTLD_LAZY)

        public static let now = Self(rawValue: RTLD_NOW)

        public static let local = Self(rawValue: RTLD_LOCAL)

        public static let global = Self(rawValue: RTLD_GLOBAL)
    }

#endif

#if canImport(Darwin)

    extension ISO_9945.Loader.Library.Options {

        public static let noLoad = Self(rawValue: RTLD_NOLOAD)

        public static let noDelete = Self(rawValue: RTLD_NODELETE)
    }

#endif

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Process {
    public typealias ID = ISO_9945.Kernel.Process.ID
}

extension ISO_9945.Kernel.Process.ID {

    public static var current: Self {
        #if canImport(Darwin)
            Self(Darwin.getpid())
        #elseif canImport(Musl)
            Self(Musl.getpid())
        #elseif canImport(Glibc)
            Self(Glibc.getpid())
        #endif
    }

    public static var parent: Self {
        #if canImport(Darwin)
            Self(Darwin.getppid())
        #elseif canImport(Musl)
            Self(Musl.getppid())
        #elseif canImport(Glibc)
            Self(Glibc.getppid())
        #endif
    }
}

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Close {

    internal static func close(_ fd: Int32) -> Int32 {
        #if canImport(Darwin)
            return Darwin.close(fd)
        #elseif canImport(Glibc)
            return unsafe Glibc.close(fd)
        #elseif canImport(Musl)
            return unsafe Musl.close(fd)
        #else
            #error("ISO_9945.Kernel.Close: unsupported platform (no Darwin, Glibc, or Musl)")
        #endif
    }
}

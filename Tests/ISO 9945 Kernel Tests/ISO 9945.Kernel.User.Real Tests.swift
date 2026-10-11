import ISO_9945_Kernel
import Testing

#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#elseif canImport(Musl)
    import Musl
#endif

extension ISO_9945.Kernel.User.Real {
    @Suite
    struct Test {
        @Suite struct Unit {}
    }
}

extension ISO_9945.Kernel.User.Real.Test.Unit {
    @Test
    func `POSIX.1-2024 getuid returns the real user ID of the calling process`() {
        #expect(ISO_9945.Kernel.User.Real.id() == ISO_9945.Kernel.User.ID(getuid()))
    }
}

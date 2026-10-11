import ISO_9945_Kernel
import Testing

#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#elseif canImport(Musl)
    import Musl
#endif

extension ISO_9945.Kernel.User.Effective {
    @Suite
    struct Test {
        @Suite struct Unit {}
    }
}

extension ISO_9945.Kernel.User.Effective.Test.Unit {
    @Test
    func `POSIX.1-2024 geteuid returns the effective user ID of the calling process`() {
        #expect(ISO_9945.Kernel.User.Effective.id() == ISO_9945.Kernel.User.ID(geteuid()))
    }
}

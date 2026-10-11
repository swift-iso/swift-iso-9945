import ISO_9945_Kernel
import Testing

#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#elseif canImport(Musl)
    import Musl
#endif

extension ISO_9945.Kernel.Group.Real {
    @Suite
    struct Test {
        @Suite struct Unit {}
    }
}

extension ISO_9945.Kernel.Group.Real.Test.Unit {
    @Test
    func `POSIX.1-2024 getgid returns the real group ID of the calling process`() {
        #expect(ISO_9945.Kernel.Group.Real.id() == ISO_9945.Kernel.Group.ID(getgid()))
    }
}

import ISO_9945_Kernel
import Testing

#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#elseif canImport(Musl)
    import Musl
#endif

enum `ISO_9945.Kernel.Group.Effective Tests` {}

extension `ISO_9945.Kernel.Group.Effective Tests` {
    @Suite
    struct Test {
        @Suite struct Unit {}
    }
}

extension `ISO_9945.Kernel.Group.Effective Tests`.Test.Unit {
    @Test
    func `POSIX.1-2024 getegid returns the effective group ID of the calling process`() {
        #expect(ISO_9945.Kernel.Group.Effective.id() == ISO_9945.Kernel.Group.ID(getegid()))
    }
}

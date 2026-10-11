import ISO_9945_Kernel
import Testing

#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#elseif canImport(Musl)
    import Musl
#endif

extension ISO_9945.Kernel.Group.Supplementary {
    @Suite
    struct Test {
        @Suite struct Unit {}
    }
}

extension ISO_9945.Kernel.Group.Supplementary.Test.Unit {
    @Test
    func `POSIX.1-2024 getgroups returns the supplementary group IDs of the calling process`() throws {
        let count = getgroups(0, nil)
        try #require(count >= 0)
        var expected = [gid_t](repeating: 0, count: Int(count))
        let filled = unsafe getgroups(count, &expected)
        try #require(filled >= 0)
        let groups = try ISO_9945.Kernel.Group.Supplementary.get()
        #expect(Set(groups) == Set(expected.prefix(Int(filled)).map { ISO_9945.Kernel.Group.ID($0) }))
    }
}

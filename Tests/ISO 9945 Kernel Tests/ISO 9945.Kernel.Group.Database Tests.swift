import ISO_9945_Kernel
import Testing

extension ISO_9945.Kernel.Group.Database {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
    }
}

extension ISO_9945.Kernel.Group.Database.Test.Unit {
    @Test
    func `POSIX.1-2024 getgrgid finds the group database entry for group ID 0`() throws {
        let entry = try #require(try ISO_9945.Kernel.Group.Database.find(gid: 0))
        #expect(entry.gid == 0)
        #expect(!entry.name.isEmpty)
    }

    @Test
    func `POSIX.1-2024 getgrnam finds the entry returned by getgrgid`() throws {
        let byID = try #require(try ISO_9945.Kernel.Group.Database.find(gid: 0))
        let byName = try #require(try ISO_9945.Kernel.Group.Database.find(name: byID.name))
        #expect(byName.gid == byID.gid)
    }
}

extension ISO_9945.Kernel.Group.Database.Test.`Edge Case` {
    @Test
    func `POSIX.1-2024 getgrnam returns no entry for an unknown name`() throws {
        #expect(try ISO_9945.Kernel.Group.Database.find(name: "iso-9945-no-such-group") == nil)
    }
}

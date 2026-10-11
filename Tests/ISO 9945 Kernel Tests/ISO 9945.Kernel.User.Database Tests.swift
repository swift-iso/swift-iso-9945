import ISO_9945_Kernel
import Testing

extension ISO_9945.Kernel.User.Database {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
    }
}

extension ISO_9945.Kernel.User.Database.Test.Unit {
    @Test
    func `POSIX.1-2024 getpwuid finds the user database entry for user ID 0`() throws {
        let entry = try #require(try ISO_9945.Kernel.User.Database.find(uid: 0))
        #expect(entry.uid == 0)
        #expect(!entry.name.isEmpty)
    }

    @Test
    func `POSIX.1-2024 getpwnam finds the entry returned by getpwuid`() throws {
        let byID = try #require(try ISO_9945.Kernel.User.Database.find(uid: 0))
        let byName = try #require(try ISO_9945.Kernel.User.Database.find(name: byID.name))
        #expect(byName.uid == byID.uid)
    }
}

extension ISO_9945.Kernel.User.Database.Test.`Edge Case` {
    @Test
    func `POSIX.1-2024 getpwnam returns no entry for an unknown name`() throws {
        #expect(try ISO_9945.Kernel.User.Database.find(name: "iso-9945-no-such-user") == nil)
    }
}

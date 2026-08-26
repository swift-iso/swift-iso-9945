import Error
import ISO_9945_Kernel_Test_Support
import Path
import Tagged_Standard_Library_Integration
import Testing

@testable import ISO_9945_Kernel

extension ISO_9945.Kernel.Environment {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
    }
}

extension ISO_9945.Kernel.Environment.Test.Unit {
    @Test
    func `get returns nil for unset variable`() {
        let result = ISO_9945.Kernel.Environment.get("__KERNEL_TEST_UNSET_VAR_12345__")

        let isNil = (result == nil)
        #expect(isNil)
    }

    @Test
    func `get returns value for PATH`() {

        let result = ISO_9945.Kernel.Environment.get("PATH")

        let isNotNil = (result != nil)
        #expect(isNotNil)
    }
}

extension ISO_9945.Kernel.Environment.Test.Unit {
    @Test
    func `set then get roundtrips and unset removes`() throws {
        let name = "__ISO9945_ENV_SET_TEST__"
        try ISO_9945.Kernel.Environment.set(name, to: "value-1")
        guard let value = ISO_9945.Kernel.Environment.get(name) else {
            Issue.record("expected the variable to be set")
            return
        }
        #expect(decoded(value.span) == "value-1")

        try ISO_9945.Kernel.Environment.set(name, to: "value-2")
        guard let overwritten = ISO_9945.Kernel.Environment.get(name) else {
            Issue.record("expected the variable to remain set")
            return
        }
        #expect(decoded(overwritten.span) == "value-2")

        try ISO_9945.Kernel.Environment.unset(name)
        let removed = ISO_9945.Kernel.Environment.get(name)

        let isNil = (removed == nil)
        #expect(isNil)
    }

    @Test
    func `set without overwrite preserves existing value`() throws {
        let name = "__ISO9945_ENV_NO_OVERWRITE_TEST__"
        try ISO_9945.Kernel.Environment.set(name, to: "original")
        defer { try? ISO_9945.Kernel.Environment.unset(name) }

        try ISO_9945.Kernel.Environment.set(name, to: "replacement", overwrite: false)
        guard let value = ISO_9945.Kernel.Environment.get(name) else {
            Issue.record("expected the variable to remain set")
            return
        }
        #expect(decoded(value.span) == "original")
    }
}

extension ISO_9945.Kernel.Environment.Test.`Edge Case` {
    @Test
    func `set with empty name throws emptyName`() {
        #expect(throws: ISO_9945.Kernel.Environment.Error.invalid(.emptyName)) {
            try ISO_9945.Kernel.Environment.set("", to: "value")
        }
    }

    @Test
    func `set with equals in name throws nameContainsEquals`() {
        #expect(throws: ISO_9945.Kernel.Environment.Error.invalid(.nameContainsEquals)) {
            try ISO_9945.Kernel.Environment.set("BAD=NAME", to: "value")
        }
    }

    @Test
    func `unset with empty name throws emptyName`() {
        #expect(throws: ISO_9945.Kernel.Environment.Error.invalid(.emptyName)) {
            try ISO_9945.Kernel.Environment.unset("")
        }
    }
}

extension ISO_9945.Kernel.Environment.Test.Unit {
    @Test
    func `entries yields the set variable with its value`() throws {
        let name = "__ISO9945_ENV_ENTRIES_TEST__"
        try ISO_9945.Kernel.Environment.set(name, to: "entries-value")
        defer { try? ISO_9945.Kernel.Environment.unset(name) }

        var found = false
        var entries = ISO_9945.Kernel.Environment.entries()
        while let entry = entries.next() {
            let entryName = decoded(entry.name)
            if entryName == name {
                found = true
                #expect(decoded(entry.value) == "entries-value")
            }
        }
        #expect(found)
    }

    @Test
    func `abandoned iteration leaves getenv intact`() throws {

        let name = "__ISO9945_ENV_ABANDON_TEST__"
        try ISO_9945.Kernel.Environment.set(name, to: "abandon-value")
        defer { try? ISO_9945.Kernel.Environment.unset(name) }

        var entries = ISO_9945.Kernel.Environment.entries()
        _ = entries.next()

        guard let value = ISO_9945.Kernel.Environment.get(name) else {
            Issue.record("abandoned iteration corrupted the environment")
            return
        }
        #expect(decoded(value.span) == "abandon-value")
    }
}

private func decoded(_ span: Swift.Span<UInt8>) -> Swift.String {
    var bytes: [UInt8] = []
    bytes.reserveCapacity(span.count)
    for index in span.indices {
        bytes.append(span[index])
    }
    return Swift.String(decoding: bytes, as: UTF8.self)
}

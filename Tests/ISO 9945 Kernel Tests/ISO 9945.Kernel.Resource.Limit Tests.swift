import Testing

@testable import ISO_9945_Kernel

extension ISO_9945.Kernel.Resource.Limit {
    @Suite(.serialized)
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
    }
}

extension ISO_9945.Kernel.Resource.Limit.Test.Unit {
    @Test
    func `the descriptor limit reads back with current at most maximum`() throws {
        let limit = try ISO_9945.Kernel.Resource.Limit.get(.descriptors)
        #expect(limit.current > 0)
        #expect(limit.current <= limit.maximum)
    }

    @Test
    func `lowering and restoring the current descriptor limit round-trips`() throws {
        let original = try ISO_9945.Kernel.Resource.Limit.get(.descriptors)
        defer { try? ISO_9945.Kernel.Resource.Limit.set(original, for: .descriptors) }

        var lowered = original
        lowered.current = original.current - 1
        try ISO_9945.Kernel.Resource.Limit.set(lowered, for: .descriptors)
        #expect(try ISO_9945.Kernel.Resource.Limit.get(.descriptors).current == lowered.current)

        try ISO_9945.Kernel.Resource.Limit.set(original, for: .descriptors)
        #expect(try ISO_9945.Kernel.Resource.Limit.get(.descriptors) == original)
    }
}

extension ISO_9945.Kernel.Resource.Limit.Test.`Edge Case` {
    @Test
    func `a current limit above the maximum is invalid`() throws {
        var limit = try ISO_9945.Kernel.Resource.Limit.get(.stack)
        guard limit.maximum != ISO_9945.Kernel.Resource.Limit.infinity else { return }
        limit.current = limit.maximum + 1
        #expect(throws: ISO_9945.Kernel.Resource.Limit.Error.invalid) {
            try ISO_9945.Kernel.Resource.Limit.set(limit, for: .stack)
        }
    }

    @Test
    func `every resource reads without error`() throws {
        for resource: ISO_9945.Kernel.Resource in [.core, .cpu, .data, .file, .descriptors, .stack, .address] {
            _ = try ISO_9945.Kernel.Resource.Limit.get(resource)
        }
    }
}

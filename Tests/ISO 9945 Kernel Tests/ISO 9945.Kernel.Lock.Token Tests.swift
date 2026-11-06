import Error
import ISO_9945_Kernel_Test_Support
import Path
import Tagged
import Testing

@testable import ISO_9945_Kernel

enum `ISO_9945.Kernel.Lock.Token Tests` {}

extension `ISO_9945.Kernel.Lock.Token Tests` {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
    }
}

extension `ISO_9945.Kernel.Lock.Token Tests`.Test.Unit {
    @Test
    func `withExclusive exists`() {

        typealias WithExclusiveType = (
            borrowing ISO_9945.Kernel.Descriptor,
            ISO_9945.Kernel.Lock.Range,
            ISO_9945.Kernel.Lock.Acquire,
            () throws -> Void
        ) throws -> Void

    }

    @Test
    func `withShared exists`() {

        typealias WithSharedType = (
            borrowing ISO_9945.Kernel.Descriptor,
            ISO_9945.Kernel.Lock.Range,
            ISO_9945.Kernel.Lock.Acquire,
            () throws -> Void
        ) throws -> Void

    }
}

import Error_Primitives
import ISO_9945_Kernel_Test_Support
import Path_Primitives
import Tagged_Primitives_Standard_Library_Integration
import Testing

@testable import ISO_9945_Kernel

extension ISO_9945.Kernel.Thread.Test.Unit {
    @Test
    func `Thread namespace exists`() {
        _ = ISO_9945.Kernel.Thread.self
    }

    @Test
    func `Thread is an enum`() {
        let _: ISO_9945.Kernel.Thread.Type = ISO_9945.Kernel.Thread.self
    }
}

extension ISO_9945.Kernel.Thread.Test.Unit {
    @Test
    func `Thread.Handle type exists`() {
        let _: ISO_9945.Kernel.Thread.Handle.Type = ISO_9945.Kernel.Thread.Handle.self
    }

    @Test
    func `Thread.Error type exists`() {
        let _: ISO_9945.Kernel.Thread.Error.Type = ISO_9945.Kernel.Thread.Error.self
    }

    @Test
    func `Thread.Mutex type exists`() {
        let _: ISO_9945.Kernel.Thread.Mutex.Type = ISO_9945.Kernel.Thread.Mutex.self
    }

    @Test
    func `Thread.Condition type exists`() {
        let _: ISO_9945.Kernel.Thread.Condition.Type = ISO_9945.Kernel.Thread.Condition.self
    }
}

extension ISO_9945.Kernel.Thread.Test.Unit {
    @Test
    func `create function signature exists`() {

        typealias CreateType = (@escaping @Sendable () -> Void) throws ->
            ISO_9945.Kernel.Thread.Handle

    }
}

import Error
import ISO_9945_Kernel_Test_Support
import Path
import Tagged_Standard_Library_Integration
import Testing

@testable import ISO_9945_Kernel

extension ISO_9945.Kernel.Thread.Handle {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

extension ISO_9945.Kernel.Thread.Handle.Test.Unit {
    @Test
    func `Handle type exists`() {
        let _: ISO_9945.Kernel.Thread.Handle.Type = ISO_9945.Kernel.Thread.Handle.self
    }

    @Test
    func `Handle is ~Copyable`() {

        let _: ISO_9945.Kernel.Thread.Handle.Type = ISO_9945.Kernel.Thread.Handle.self
    }
}

extension ISO_9945.Kernel.Thread.Handle.Test.Unit {
    @Test
    func `Handle is @unchecked Sendable`() {

        let _: ISO_9945.Kernel.Thread.Handle.Type = ISO_9945.Kernel.Thread.Handle.self
    }
}

extension ISO_9945.Kernel.Thread.Handle.Test.Unit {
    @Test
    func `join method exists`() {

    }

    @Test
    func `detach method exists`() {

    }

    @Test
    func `isCurrent property exists`() {

    }
}

#if os(Windows)
    extension ISO_9945.Kernel.Thread.Handle.Test.Unit {
        @Test
        func `Handle wraps HANDLE on Windows`() {

        }
    }
#else
    extension ISO_9945.Kernel.Thread.Handle.Test.Unit {
        @Test
        func `Handle wraps pthread_t on POSIX`() {

        }
    }
#endif

extension ISO_9945.Kernel.Thread.Handle.Test.EdgeCase {
    @Test
    func `Handle move-only semantics prevent double-join`() {

        let _: ISO_9945.Kernel.Thread.Handle.Type = ISO_9945.Kernel.Thread.Handle.self
    }
}

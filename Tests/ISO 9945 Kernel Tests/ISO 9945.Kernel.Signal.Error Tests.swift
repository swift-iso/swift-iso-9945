#if canImport(Darwin) || canImport(Glibc) || canImport(Musl)

    import Testing
    import Tagged_Primitives_Standard_Library_Integration

    import Path_Primitives
    import Error_Primitives
    @testable import ISO_9945_Kernel

    extension ISO_9945.Kernel.Signal.Error {
        @Suite
        struct Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    extension ISO_9945.Kernel.Signal.Error.Test.Unit {
        @Test
        func `interrupted case exists`() {
            let error = ISO_9945.Kernel.Signal.Error.interrupted
            if case .interrupted = error {

            } else {
                Issue.record("Expected .interrupted case")
            }
        }

        @Test
        func `Signal.Error conforms to Swift.Error`() {
            let error: any Swift.Error = ISO_9945.Kernel.Signal.Error.interrupted
            #expect(error is ISO_9945.Kernel.Signal.Error)
        }

        @Test
        func `Signal.Error is Sendable`() {
            let error: any Sendable = ISO_9945.Kernel.Signal.Error.interrupted
            #expect(error is ISO_9945.Kernel.Signal.Error)
        }

        @Test
        func `Signal.Error is Equatable`() {
            let a = ISO_9945.Kernel.Signal.Error.interrupted
            let b = ISO_9945.Kernel.Signal.Error.interrupted

            #expect(a == b)
        }

        @Test
        func `Signal.Error is Hashable`() {
            var set = Set<ISO_9945.Kernel.Signal.Error>()
            set.insert(.interrupted)
            set.insert(.interrupted)

            #expect(set.count == 1)
            #expect(set.contains(.interrupted))
        }

        @Test
        func `description returns meaningful string`() {
            let error = ISO_9945.Kernel.Signal.Error.interrupted
            #expect(error.description == "interrupted by signal")
        }

        @Test
        func `CustomStringConvertible conformance`() {
            let error = ISO_9945.Kernel.Signal.Error.interrupted
            let description = Swift.String(describing: error)
            #expect(!description.isEmpty)
            #expect(description.contains("interrupt"))
        }
    }

#endif

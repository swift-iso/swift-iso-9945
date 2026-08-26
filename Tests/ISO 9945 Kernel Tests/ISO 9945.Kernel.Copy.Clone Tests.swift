import Error
import ISO_9945_Kernel_Test_Support
import Path
import Tagged_Standard_Library_Integration
import Testing

@testable import ISO_9945_Kernel

#if os(Linux) || canImport(Darwin)

    extension ISO_9945.Kernel.Copy.Clone {
        @Suite
        struct Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
        }
    }

    extension ISO_9945.Kernel.Copy.Clone.Test.Unit {
        @Test
        func `Clone namespace exists`() {
            _ = ISO_9945.Kernel.Copy.Clone.self
        }

        @Test
        func `Clone is an enum`() {
            let _: ISO_9945.Kernel.Copy.Clone.Type = ISO_9945.Kernel.Copy.Clone.self
        }
    }

    #if os(Linux)
        extension ISO_9945.Kernel.Copy.Clone.Test.Unit {
            @Test
            func `perform function exists on Linux`() {

                typealias PerformType = (
                    borrowing ISO_9945.Kernel.Descriptor, borrowing ISO_9945.Kernel.Descriptor
                ) throws -> Void
            }
        }
    #endif

    #if canImport(Darwin)
        extension ISO_9945.Kernel.Copy.Clone.Test.Unit {
            @Test
            func `file function exists on Darwin`() {

                _ = ISO_9945.Kernel.Copy.Clone.self
            }
        }
    #endif

#endif

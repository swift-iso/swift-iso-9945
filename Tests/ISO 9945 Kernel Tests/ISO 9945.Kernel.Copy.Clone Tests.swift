import Error
import ISO_9945_Kernel_Test_Support
import Path
import Tagged
import Testing

@testable import ISO_9945_Kernel

#if os(Linux) || canImport(Darwin)

    extension ISO_9945.Kernel.Copy.Clone {
        @Suite
        struct Test {
            @Suite struct Unit {}
            @Suite struct `Edge Case` {}
        }
    }

    extension ISO_9945.Kernel.Copy.Clone.Test.Unit {
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
        }
    #endif

#endif

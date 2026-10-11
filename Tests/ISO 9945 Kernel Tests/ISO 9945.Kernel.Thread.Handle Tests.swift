import Error
import ISO_9945_Kernel_Test_Support
import Path
import Tagged
import Testing

@testable import ISO_9945_Kernel

extension ISO_9945.Kernel.Thread.Handle {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
    }
}

#if os(Windows)
    extension ISO_9945.Kernel.Thread.Handle.Test.Unit {
    }
#else
    extension ISO_9945.Kernel.Thread.Handle.Test.Unit {
    }
#endif

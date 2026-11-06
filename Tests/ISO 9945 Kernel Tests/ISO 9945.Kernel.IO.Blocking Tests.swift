import ISO_9945_Kernel
import Tagged
import Testing

enum `ISO_9945.Kernel.IO.Blocking Tests` {}

extension `ISO_9945.Kernel.IO.Blocking Tests` {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
    }
}

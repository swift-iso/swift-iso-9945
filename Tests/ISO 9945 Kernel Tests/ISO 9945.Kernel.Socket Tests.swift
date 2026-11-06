import ISO_9945_Kernel
import Tagged
import Testing

enum `ISO_9945.Kernel.Socket Tests` {}

extension `ISO_9945.Kernel.Socket Tests` {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
    }
}

extension `ISO_9945.Kernel.Socket Tests`.Test.Unit {

}

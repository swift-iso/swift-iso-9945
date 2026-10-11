import ISO_9945_Kernel
import ISO_9945_Kernel_Test_Support
import Testing

extension KernelThreadTest {
    @Suite
    struct Test {
        @Suite struct Unit {}
    }
}

extension KernelThreadTest.Test.Unit {
    @Test
    func `Harness wait throws Timeout when the predicate never holds within the limit`() {
        let harness = KernelThreadTest.Harness<Int>(0, limit: .milliseconds(50))
        #expect(throws: KernelThreadTest.Timeout()) {
            try harness.wait(until: { $0 == 1 })
        }
    }

    @Test
    func `Harness wait returns once an update satisfies the predicate`() throws {
        let harness = KernelThreadTest.Harness<Int>(0, limit: .seconds(5))
        harness.update { $0 = 1 }
        try harness.wait(until: { $0 == 1 })
    }
}

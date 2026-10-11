import ISO_9945_Kernel
import ISO_9945_Kernel_Test_Support
import Tagged
import Testing

@Suite
struct `File Delta Tests` {

    @Test
    func `Delta from integer literal`() {
        let delta: ISO_9945.Kernel.File.Delta = 500
        #expect(delta == 500)
    }

    @Test
    func `Negative Delta`() {
        let delta = ISO_9945.Kernel.File.Delta(-100)
        #expect(delta == -100)
    }

    @Test
    func `Delta is Equatable`() {
        let a = ISO_9945.Kernel.File.Delta(100)
        let b = ISO_9945.Kernel.File.Delta(100)
        let c = ISO_9945.Kernel.File.Delta(-100)
        #expect(a == b)
        #expect(a != c)
    }
}

import Error_Primitives
import Path_Primitives
import Tagged_Primitives_Standard_Library_Integration
import Testing

@testable import ISO_9945_Kernel

@Suite("ISO_9945.Kernel.Process.ID Parent Tests")
struct KernelProcessIDParentTests {
    @Test
    func `parent returns positive PID`() {
        let parent = ISO_9945.Kernel.Process.ID.parent
        #expect(parent.rawValue > 0)
    }

    @Test
    func `spawned child's parent matches spawner's current`() throws {
        #if os(macOS)
            let ourPID = ISO_9945.Kernel.Process.ID.current

            let child = try POSIXTestHelper.spawn("verify-parent", "\(ourPID.rawValue)")

            let result = try ISO_9945.Kernel.Process.Wait.wait(.process(child))
            #expect(result?.status.exit.code == 0, "Child's parent should match spawner's PID")
        #endif
    }
}

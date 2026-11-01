import Error
import ISO_9945_Kernel_Test_Support
import Tagged
import Testing

@testable import ISO_9945_Kernel

extension ISO_9945.Kernel.Name {
    @Suite
    struct Test {
        @Suite struct Unit {}
    }
}

extension ISO_9945.Kernel.Name.Test.Unit {
    @Test
    func `current names the running system`() throws {
        let name = try #require(ISO_9945.Kernel.Name.current)
        #expect(!name.system.isEmpty)
        #expect(!name.release.isEmpty)
        #expect(!name.machine.isEmpty)
    }

    #if os(macOS)
        @Test
        func `macOS reports Darwin`() throws {
            #expect(try #require(ISO_9945.Kernel.Name.current).system == "Darwin")
        }
    #endif

    #if os(Linux)
        @Test
        func `Linux reports Linux`() throws {
            #expect(try #require(ISO_9945.Kernel.Name.current).system == "Linux")
        }
    #endif
}

@Suite
struct `Memory.Page.size Tests` {
    @Test
    func `size is a power of two of at least 4 KiB`() {
        let size = Int(Memory.Page.size)
        #expect(size >= 4096)
        #expect(size & (size - 1) == 0)
    }

    #if os(macOS) && arch(arm64)
        @Test
        func `size is 16 KiB on Apple Silicon`() {
            #expect(Int(Memory.Page.size) == 16384)
        }
    #endif

    @Test
    func `size is consistent across calls`() {
        #expect(Memory.Page.size == Memory.Page.size)
    }

    @Test
    func `allocation granularity equals the page size on POSIX`() {
        let size: Int = Memory.Allocation.system.underlying.magnitude()
        #expect(size == Int(Memory.Page.size))
    }

    @Test
    func `allocation granularity is consistent across calls`() {
        #expect(Memory.Allocation.system == Memory.Allocation.system)
    }
}

@Suite
struct `CPU.Logical.count Tests` {
    @Test
    func `count is at least one`() {
        #expect(Int(CPU.Logical.count) >= 1)
    }
}

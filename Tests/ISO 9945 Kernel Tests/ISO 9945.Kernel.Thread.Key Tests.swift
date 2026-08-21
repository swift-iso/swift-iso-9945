import ISO_9945_Kernel_Test_Support
import Tagged_Primitives_Standard_Library_Integration
import Testing

@testable import ISO_9945_Kernel

@Suite("ISO_9945.Kernel.Thread.Key")
struct KeyTests {
    @Suite struct Unit {}
    @Suite struct Lifecycle {}
}

extension KeyTests.Unit {

    @Test
    func `freshly-allocated slot reads as nil`() throws {
        let key = try ISO_9945.Kernel.Thread.Key()
        unsafe (#expect(key.value == nil))
    }

    @Test
    func `set then get returns the same pointer`() throws {
        let key = try ISO_9945.Kernel.Thread.Key()
        let buffer = unsafe UnsafeMutablePointer<UInt64>.allocate(capacity: 1)
        defer { unsafe buffer.deallocate() }
        let raw = unsafe UnsafeMutableRawPointer(buffer)

        unsafe (key.value = raw)
        unsafe (#expect(key.value == raw))
    }

    @Test
    func `set to nil clears the slot`() throws {
        let key = try ISO_9945.Kernel.Thread.Key()
        let buffer = unsafe UnsafeMutablePointer<UInt64>.allocate(capacity: 1)
        defer { unsafe buffer.deallocate() }
        unsafe (key.value = UnsafeMutableRawPointer(buffer))
        unsafe (#expect(key.value != nil))

        unsafe (key.value = nil)
        unsafe (#expect(key.value == nil))
    }

    @Test
    func `multiple Key instances have independent slots`() throws {
        let a = try ISO_9945.Kernel.Thread.Key()
        let b = try ISO_9945.Kernel.Thread.Key()
        let bufferA = unsafe UnsafeMutablePointer<UInt64>.allocate(capacity: 1)
        let bufferB = unsafe UnsafeMutablePointer<UInt64>.allocate(capacity: 1)
        defer {
            unsafe bufferA.deallocate()
            unsafe bufferB.deallocate()
        }

        unsafe (a.value = UnsafeMutableRawPointer(bufferA))
        unsafe (b.value = UnsafeMutableRawPointer(bufferB))

        unsafe (#expect(a.value == UnsafeMutableRawPointer(bufferA)))
        unsafe (#expect(b.value == UnsafeMutableRawPointer(bufferB)))
        unsafe (#expect(a.value != b.value))
    }
}

extension KeyTests.Lifecycle {

    @Test
    func `Key can be allocated and deallocated repeatedly`() throws {

        for _ in 0..<200 {
            let key = try ISO_9945.Kernel.Thread.Key()
            unsafe (key.value = nil)

            _ = key
        }
    }
}

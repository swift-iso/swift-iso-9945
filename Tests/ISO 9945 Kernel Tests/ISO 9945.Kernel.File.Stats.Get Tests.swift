import ISO_9945_Kernel
import Tagged
import Testing

#if canImport(Darwin)
    import Darwin
    @_spi(Syscall) import ISO_9945_Core

    extension ISO_9945.Kernel.File.Stats {
        @Suite
        struct `Get Test` {
            @Suite struct `Edge Case` {}
        }
    }

    extension ISO_9945.Kernel.File.Stats.`Get Test`.`Edge Case` {
        @Test
        func `a descriptor whose device number is negative stats without trapping`() throws {
            // Darwin's dev_t is a signed Int32, and fstat reports a socket's device as -1.
            let raw = unsafe Darwin.socket(AF_UNIX, SOCK_STREAM, 0)
            try #require(raw >= 0)
            let socket = ISO_9945.Kernel.Descriptor(_rawValue: raw)

            let stats = try ISO_9945.Kernel.File.Stats.get(descriptor: socket)

            #expect(stats.device.rawValue == UInt64(UInt32(bitPattern: -1)))
        }
    }
#endif

import Error
@_spi(Syscall) import ISO_9945_Kernel
import Testing

#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#elseif canImport(Musl)
    import Musl
#endif

extension ISO_9945.Kernel.Termios.Attributes {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
    }
}

#if canImport(Darwin)
    extension ISO_9945.Kernel.Termios.Attributes.Test {
        struct Terminal: ~Copyable {
            let primary: Int32
            let secondary: Int32

            init() throws {
                let primary = posix_openpt(O_RDWR | O_NOCTTY)
                try #require(primary >= 0)
                try #require(grantpt(primary) == 0)
                try #require(unlockpt(primary) == 0)
                let name = try unsafe #require(unsafe ptsname(primary))
                let secondary = unsafe open(name, O_RDWR | O_NOCTTY)
                try #require(secondary >= 0)
                self.primary = primary
                self.secondary = secondary
            }

            deinit {
                close(secondary)
                close(primary)
            }
        }

        static func localFlags(_ attributes: ISO_9945.Kernel.Termios.Attributes) -> tcflag_t {
            unsafe attributes.withUnsafeStorageBytes { buffer in
                unsafe buffer.loadUnaligned(as: termios.self).c_lflag
            }
        }
    }

    extension ISO_9945.Kernel.Termios.Attributes.Test.Unit {
        @Test
        func `POSIX.1-2024 tcgetattr reads the attributes of a pseudo-terminal`() throws {
            let terminal = try ISO_9945.Kernel.Termios.Attributes.Test.Terminal()
            _ = try ISO_9945.Kernel.Termios.Attributes.get(fd: terminal.secondary)
        }

        @Test
        func `POSIX.1-2024 tcsetattr applies raw mode so ICANON and ECHO read back cleared`() throws {
            let terminal = try ISO_9945.Kernel.Termios.Attributes.Test.Terminal()
            let original = try ISO_9945.Kernel.Termios.Attributes.get(fd: terminal.secondary)
            try ISO_9945.Kernel.Termios.Attributes.set(original.withRaw(), fd: terminal.secondary, action: .now)
            let applied = try ISO_9945.Kernel.Termios.Attributes.get(fd: terminal.secondary)
            let flags = ISO_9945.Kernel.Termios.Attributes.Test.localFlags(applied)
            #expect(flags & tcflag_t(ICANON) == 0)
            #expect(flags & tcflag_t(ECHO) == 0)
        }

        @Test
        func `POSIX.1-2024 tcsetattr restores the original canonical and echo modes`() throws {
            let terminal = try ISO_9945.Kernel.Termios.Attributes.Test.Terminal()
            let original = try ISO_9945.Kernel.Termios.Attributes.get(fd: terminal.secondary)
            try ISO_9945.Kernel.Termios.Attributes.set(original.withRaw(), fd: terminal.secondary)
            try ISO_9945.Kernel.Termios.Attributes.set(original, fd: terminal.secondary, action: .drain)
            let restored = try ISO_9945.Kernel.Termios.Attributes.get(fd: terminal.secondary)
            let expected = ISO_9945.Kernel.Termios.Attributes.Test.localFlags(original)
            let mask = tcflag_t(ICANON | ECHO | ISIG | IEXTEN)
            let restoredFlags = ISO_9945.Kernel.Termios.Attributes.Test.localFlags(restored)
            #expect(restoredFlags & mask == expected & mask)
        }
    }
#endif

extension ISO_9945.Kernel.Termios.Attributes.Test.`Edge Case` {
    @Test
    func `POSIX.1-2024 tcgetattr on a pipe fails with ENOTTY`() throws {
        var fds: [Int32] = [-1, -1]
        try #require(unsafe pipe(&fds) == 0)
        defer {
            close(fds[0])
            close(fds[1])
        }
        do {
            _ = try ISO_9945.Kernel.Termios.Attributes.get(fd: fds[0])
            Issue.record("tcgetattr on a pipe succeeded")
        } catch {
            #expect(error.code == .posix(ENOTTY))
        }
    }
}

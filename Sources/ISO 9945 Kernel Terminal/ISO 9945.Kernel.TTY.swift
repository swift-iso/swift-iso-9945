#if !os(Windows)

    @_spi(Syscall) import ISO_9945_Core

    #if canImport(Darwin)
        internal import Darwin
    #elseif canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    #if canImport(ISO_9945_Shims)
        internal import ISO_9945_Shims
    #endif

    extension ISO_9945.Kernel.TTY {

        @_spi(Syscall)
        public static func isTTY(fd: Int32) -> Bool {
            isatty(fd) != 0
        }
    }

    extension ISO_9945.Kernel.TTY.Size {

        @_spi(Syscall)
        public static func query(fd: Int32) throws(Error.Error) -> Self {
            var ws = winsize()
            let result = unsafe iso9945_ioctl_tiocgwinsz(fd, &ws)
            guard result == 0 else {
                throw Error.Error.current(operation: "ioctl(TIOCGWINSZ)")
            }
            return Self(rows: ws.ws_row, columns: ws.ws_col)
        }
    }

    extension ISO_9945.Kernel.TTY {

        public static func isTTY(_ descriptor: borrowing ISO_9945.Kernel.Descriptor) -> Bool {
            isTTY(fd: descriptor._rawValue)
        }
    }

    extension ISO_9945.Kernel.TTY.Size {

        public static func query(
            _ descriptor: borrowing ISO_9945.Kernel.Descriptor
        ) throws(Error.Error) -> Self {
            try query(fd: descriptor._rawValue)
        }
    }

#endif

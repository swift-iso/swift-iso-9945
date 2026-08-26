#if !os(Windows)

    @_spi(Syscall) import ISO_9945_Core

    #if canImport(Darwin)
        internal import Darwin
    #elseif canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    extension ISO_9945.Kernel.Termios.Attributes {

        @_spi(Syscall)
        public static func get(fd: Int32) throws(Error.Error) -> Self {
            var t = termios()
            let result = unsafe tcgetattr(fd, &t)
            guard result == 0 else {
                throw Error.Error.current(operation: "tcgetattr")
            }

            var attrs = ISO_9945.Kernel.Termios.Attributes(_storage: .init())
            unsafe attrs.withUnsafeMutableStorageBytes { buffer in
                withUnsafeBytes(of: t) { src in
                    unsafe buffer.copyMemory(from: src)
                }
            }
            return attrs
        }
    }

    extension ISO_9945.Kernel.Termios.Attributes {

        public static func set(
            _ attributes: Self,
            fd: Int32,
            action: Action = .now
        ) throws(Error.Error) {
            var t = termios()
            unsafe attributes.withUnsafeStorageBytes { buffer in
                withUnsafeMutableBytes(of: &t) { dest in

                    let source = unsafe UnsafeRawBufferPointer(rebasing: buffer[0..<dest.count])
                    unsafe dest.copyMemory(from: source)
                }
            }
            let result = unsafe tcsetattr(fd, action.rawValue, &t)
            guard result == 0 else {
                throw Error.Error.current(operation: "tcsetattr")
            }
        }
    }

    extension ISO_9945.Kernel.Termios.Attributes {

        public static func get(
            _ descriptor: borrowing ISO_9945.Kernel.Descriptor
        ) throws(Error.Error) -> Self {
            try get(fd: descriptor._rawValue)
        }

        public static func set(
            _ attributes: Self,
            on descriptor: borrowing ISO_9945.Kernel.Descriptor,
            action: Action = .now
        ) throws(Error.Error) {
            try set(attributes, fd: descriptor._rawValue, action: action)
        }
    }

    extension ISO_9945.Kernel.Termios.Attributes.Action {

        public static let now = Self(_rawValue: TCSANOW)

        public static let drain = Self(_rawValue: TCSADRAIN)

        public static let flush = Self(_rawValue: TCSAFLUSH)
    }

    extension ISO_9945.Kernel.Termios.Attributes {

        public func withRaw() -> Self {
            var t = termios()
            unsafe self.withUnsafeStorageBytes { buffer in
                withUnsafeMutableBytes(of: &t) { dest in

                    let source = unsafe UnsafeRawBufferPointer(rebasing: buffer[0..<dest.count])
                    unsafe dest.copyMemory(from: source)
                }
            }

            t.c_iflag &= ~tcflag_t(BRKINT | ICRNL | INPCK | ISTRIP | IXON)

            t.c_oflag &= ~tcflag_t(OPOST)

            t.c_cflag &= ~tcflag_t(CSIZE | PARENB)
            t.c_cflag |= tcflag_t(CS8)

            t.c_lflag &= ~tcflag_t(ECHO | ECHONL | ICANON | ISIG | IEXTEN)

            withUnsafeMutablePointer(to: &t.c_cc) { ptr in
                unsafe ptr.withMemoryRebound(to: cc_t.self, capacity: Int(NCCS)) { cc in
                    unsafe (cc[Int(VMIN)] = 1)
                    unsafe (cc[Int(VTIME)] = 0)
                }
            }

            var result = ISO_9945.Kernel.Termios.Attributes(_storage: .init())
            unsafe result.withUnsafeMutableStorageBytes { buffer in
                withUnsafeBytes(of: t) { src in
                    unsafe buffer.copyMemory(from: src)
                }
            }
            return result
        }
    }

#endif

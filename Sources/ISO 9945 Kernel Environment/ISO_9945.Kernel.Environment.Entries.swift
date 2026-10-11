#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Environment {

    @safe
    public struct Entries: ~Copyable, ~Escapable {
        @usableFromInline
        internal var index: Int

        @_lifetime(immortal)
        internal init() {
            self.index = 0
        }
    }
}

extension ISO_9945.Kernel.Environment {

    @_lifetime(immortal)
    public static func entries() -> Entries {
        Entries()
    }
}

extension ISO_9945.Kernel.Environment.Entries {

    @_lifetime(copy self)
    public mutating func next() -> ISO_9945.Kernel.Environment.Entry? {

        guard let entry = unsafe environ[index] else {
            return nil
        }
        index += 1

        var separator = -1
        var length = 0
        while unsafe (entry[length] != 0) {
            let byte = unsafe entry[length]
            if separator == -1 && byte == 0x3D {
                separator = length
            }
            length += 1
        }

        guard separator != -1 else {

            return next()
        }

        let basePtr = unsafe UnsafePointer<UInt8>(UnsafePointer(entry))

        return unsafe _overrideLifetime(
            ISO_9945.Kernel.Environment.Entry(base: basePtr, separator: separator, length: length),
            copying: self
        )
    }
}

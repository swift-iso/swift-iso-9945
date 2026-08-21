@_spi(Syscall) public import ISO_9945_Core

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Socket {

    public enum Option {}
}

extension ISO_9945.Kernel.Socket.Option {

    public static func get(
        _ descriptor: borrowing ISO_9945.Kernel.Socket.Descriptor,
        level: Level,
        name: Name
    ) throws(ISO_9945.Kernel.Socket.Error) -> Int32 {
        try get(fd: descriptor._rawValue, level: level, name: name.rawValue)
    }

    public static func set(
        _ descriptor: borrowing ISO_9945.Kernel.Socket.Descriptor,
        level: Level,
        name: Name,
        value: Int32
    ) throws(ISO_9945.Kernel.Socket.Error) {
        try set(fd: descriptor._rawValue, level: level, name: name.rawValue, value: value)
    }

    public static func get(
        _ descriptor: borrowing ISO_9945.Kernel.Socket.Descriptor,
        level: Level,
        name: Name
    ) throws(ISO_9945.Kernel.Socket.Error) -> Bool {
        try get(fd: descriptor._rawValue, level: level, name: name.rawValue)
    }

    public static func set(
        _ descriptor: borrowing ISO_9945.Kernel.Socket.Descriptor,
        level: Level,
        name: Name,
        enabled: Bool
    ) throws(ISO_9945.Kernel.Socket.Error) {
        try set(fd: descriptor._rawValue, level: level, name: name.rawValue, enabled: enabled)
    }
}

extension ISO_9945.Kernel.Socket.Option {

    internal static func get(
        fd: Int32,
        level: Level,
        name: Int32
    ) throws(ISO_9945.Kernel.Socket.Error) -> Int32 {
        var value: Int32 = 0
        var len = socklen_t(MemoryLayout<Int32>.size)

        let rc = unsafe getsockopt(
            fd,
            level.rawValue,
            name,
            &value,
            &len
        )

        guard rc == 0 else {
            throw ISO_9945.Kernel.Socket.Error.current()
        }

        return value
    }

    internal static func set(
        fd: Int32,
        level: Level,
        name: Int32,
        value: Int32
    ) throws(ISO_9945.Kernel.Socket.Error) {
        var val = value
        let rc = unsafe setsockopt(
            fd,
            level.rawValue,
            name,
            &val,
            socklen_t(MemoryLayout<Int32>.size)
        )

        guard rc == 0 else {
            throw ISO_9945.Kernel.Socket.Error.current()
        }
    }
}

extension ISO_9945.Kernel.Socket.Option {

    internal static func get(
        fd: Int32,
        level: Level,
        name: Int32
    ) throws(ISO_9945.Kernel.Socket.Error) -> Bool {
        let value: Int32 = try get(fd: fd, level: level, name: name)
        return value != 0
    }

    internal static func set(
        fd: Int32,
        level: Level,
        name: Int32,
        enabled: Bool
    ) throws(ISO_9945.Kernel.Socket.Error) {
        try set(fd: fd, level: level, name: name, value: enabled ? 1 : 0)
    }
}

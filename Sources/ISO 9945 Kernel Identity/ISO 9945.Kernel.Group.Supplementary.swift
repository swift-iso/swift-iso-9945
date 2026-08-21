#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Group {

    public enum Supplementary {}
}

extension ISO_9945.Kernel.Group.Supplementary {

    public static func get() throws(Error_Primitives.Error) -> [ISO_9945.Kernel.Group.ID] {
        let count = getgroups(0, nil)
        guard count >= 0 else {
            throw Error_Primitives.Error.current(operation: "getgroups")
        }

        guard count > 0 else { return [] }

        var gids = [gid_t](repeating: 0, count: Int(count))
        let result = gids.withUnsafeMutableBufferPointer { buf in
            unsafe getgroups(count, buf.baseAddress!)
        }

        guard result >= 0 else {
            throw Error_Primitives.Error.current(operation: "getgroups")
        }

        return gids.prefix(Int(result)).map { ISO_9945.Kernel.Group.ID(_unchecked: $0) }
    }
}

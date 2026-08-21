#if canImport(Darwin)
    internal import Darwin
    internal import POSIX_Process_Shims
#elseif canImport(Glibc)
    internal import Glibc
    internal import POSIX_Process_Shims
#elseif canImport(Musl)
    internal import Musl
    internal import POSIX_Process_Shims
#endif

extension ISO_9945.Kernel.Process.Spawn {

    @safe
    public struct Actions: ~Copyable {

        @usableFromInline
        internal let _handle: UnsafeMutableRawPointer

        public init() throws(ISO_9945.Kernel.Process.Error) {
            var result: Int32 = 0
            guard let raw = unsafe swift_posix_spawn_file_actions_init(&result) else {
                throw .spawn(.posix(result))
            }
            unsafe self._handle = raw
        }

        deinit {
            _ = unsafe swift_posix_spawn_file_actions_destroy(_handle)
        }
    }
}

extension ISO_9945.Kernel.Process.Spawn.Actions {

    public mutating func add(
        dup2 source: borrowing ISO_9945.Kernel.Descriptor,
        to target: Target
    ) throws(ISO_9945.Kernel.Process.Error) {
        let rc = unsafe swift_posix_spawn_file_actions_adddup2(
            _handle,
            source._raw,
            target._raw
        )
        guard rc == 0 else { throw .spawn(.posix(rc)) }
    }

    public mutating func add(
        close target: Target
    ) throws(ISO_9945.Kernel.Process.Error) {
        let rc = unsafe swift_posix_spawn_file_actions_addclose(
            _handle,
            target._raw
        )
        guard rc == 0 else { throw .spawn(.posix(rc)) }
    }

    public mutating func add(
        chdir path: UnsafePointer<Path.Char>
    ) throws(ISO_9945.Kernel.Process.Error) {
        let pathCChar = unsafe UnsafePointer<CChar>(path)
        let rc = unsafe swift_posix_spawn_file_actions_addchdir(
            _handle,
            pathCChar
        )
        guard rc == 0 else { throw .spawn(.posix(rc)) }
    }

    public mutating func add(
        open target: Target,
        path: UnsafePointer<Path.Char>,
        flags: Int32,
        mode: UInt32
    ) throws(ISO_9945.Kernel.Process.Error) {
        let pathCChar = unsafe UnsafePointer<CChar>(path)
        let rc = unsafe swift_posix_spawn_file_actions_addopen(
            _handle,
            target._raw,
            pathCChar,
            flags,
            mode_t(mode)
        )
        guard rc == 0 else { throw .spawn(.posix(rc)) }
    }
}

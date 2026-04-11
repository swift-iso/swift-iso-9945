@_spi(Syscall) import Kernel_Descriptor_Primitives

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Process.Wait {
    /// Type of process identifier for `waitid(2)`.
    ///
    /// Wraps `idtype_t`. Used with ``waitid(_:id:options:)`` to specify
    /// the interpretation of the `id` parameter.
    ///
    /// ## Mapping to waitid
    ///
    /// | Kind | Meaning |
    /// |------|---------|
    /// | `.all` | Wait for any child (id is ignored) |
    /// | `.pid` | Wait for child with matching PID |
    /// | `.processGroup` | Wait for child in matching process group |
    public struct Kind: RawRepresentable, Sendable, Equatable, Hashable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - Constants

extension ISO_9945.Kernel.Process.Wait.Kind {
    /// Wait for any child process.
    public static let all = Self(rawValue: Int32(bitPattern: UInt32(P_ALL.rawValue)))

    /// Wait for a specific process by PID.
    public static let pid = Self(rawValue: Int32(bitPattern: UInt32(P_PID.rawValue)))

    /// Wait for any child in a specific process group.
    public static let processGroup = Self(rawValue: Int32(bitPattern: UInt32(P_PGID.rawValue)))
}

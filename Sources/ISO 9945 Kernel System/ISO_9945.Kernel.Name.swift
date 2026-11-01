#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel {

    /// The implementation's identification, `uname()` (`<sys/utsname.h>`).
    public struct Name: Sendable, Hashable {

        /// `sysname`: the name of the operating system implementation.
        public var system: Swift::String

        /// `release`: the release level of the implementation.
        public var release: Swift::String

        /// `machine`: the hardware type the system runs on.
        public var machine: Swift::String

        public init(
            system: Swift::String,
            release: Swift::String,
            machine: Swift::String
        ) {
            self.system = system
            self.release = release
            self.machine = machine
        }
    }
}

extension ISO_9945.Kernel.Name {

    /// The running implementation's name, or `nil` when `uname()` fails.
    public static var current: Self? {
        var buf = utsname()
        guard unsafe uname(&buf) == 0 else { return nil }

        let capacity = MemoryLayout.size(ofValue: buf.sysname)
        let system = withUnsafePointer(to: &buf.sysname) {
            unsafe $0.withMemoryRebound(to: CChar.self, capacity: capacity) {
                unsafe Swift::String(cString: $0)
            }
        }
        let release = withUnsafePointer(to: &buf.release) {
            unsafe $0.withMemoryRebound(to: CChar.self, capacity: capacity) {
                unsafe Swift::String(cString: $0)
            }
        }
        let machine = withUnsafePointer(to: &buf.machine) {
            unsafe $0.withMemoryRebound(to: CChar.self, capacity: capacity) {
                unsafe Swift::String(cString: $0)
            }
        }
        return Self(system: system, release: release, machine: machine)
    }
}

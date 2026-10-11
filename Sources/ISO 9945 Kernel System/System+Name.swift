#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension System {

    public static var name: System.Name? {
        var buf = utsname()
        guard unsafe uname(&buf) == 0 else { return nil }

        let capacity = MemoryLayout.size(ofValue: buf.sysname)
        let system = withUnsafePointer(to: &buf.sysname) {
            unsafe $0.withMemoryRebound(to: CChar.self, capacity: capacity) {
                unsafe Swift.String(cString: $0)
            }
        }
        let release = withUnsafePointer(to: &buf.release) {
            unsafe $0.withMemoryRebound(to: CChar.self, capacity: capacity) {
                unsafe Swift.String(cString: $0)
            }
        }
        let machine = withUnsafePointer(to: &buf.machine) {
            unsafe $0.withMemoryRebound(to: CChar.self, capacity: capacity) {
                unsafe Swift.String(cString: $0)
            }
        }
        return System.Name(system: system, release: release, machine: machine)
    }
}

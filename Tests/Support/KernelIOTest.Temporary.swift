import Error
public import ISO_9945_Kernel
import Path
import String

extension KernelIOTest {

    public enum Temporary {}
}

extension KernelIOTest.Temporary {

    public static var directory: Swift.String {
        if let tmpdir = unsafe ISO_9945.Kernel.Environment.get("TMPDIR") {
            return unsafe tmpdir.withUnsafePointer { unsafe Swift.String(cString: $0) }
        }
        return "/tmp"
    }

    public static func filePath(prefix: Swift.String) -> Swift.String {
        let pid = Int(ISO_9945.Kernel.Process.ID.current.rawValue)
        let random = Int.random(in: 0..<Int.max)
        let name = "\(prefix)-\(pid)-\(random)"

        return directory + "/" + name
    }
}

import Error
public import ISO_9945_Kernel
import Path
import String

extension ISO_9945.Kernel {

    public enum Temporary {}
}

extension ISO_9945.Kernel.Temporary {

    public static var directory: Swift.String {
        #if os(Windows)
            if let temp = unsafe ISO_9945.Kernel.Environment.get("TEMP") {
                return unsafe temp.withUnsafePointer { Swift.String(cString: $0) }
            }
            if let tmp = unsafe ISO_9945.Kernel.Environment.get("TMP") {
                return unsafe tmp.withUnsafePointer { Swift.String(cString: $0) }
            }
            return "C:\\Temp"
        #else
            if let tmpdir = unsafe ISO_9945.Kernel.Environment.get("TMPDIR") {
                return unsafe tmpdir.withUnsafePointer { unsafe Swift.String(cString: $0) }
            }
            return "/tmp"
        #endif
    }

    public static func filePath(prefix: Swift.String) -> Swift.String {
        let pid = Int(ISO_9945.Kernel.Process.ID.current.rawValue)
        let random = Int.random(in: 0..<Int.max)
        let name = "\(prefix)-\(pid)-\(random)"

        #if os(Windows)
            return directory + "\\" + name
        #else
            return directory + "/" + name
        #endif
    }
}

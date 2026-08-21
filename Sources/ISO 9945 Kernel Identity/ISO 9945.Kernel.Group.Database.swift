#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Group {

    public enum Database {}
}

extension ISO_9945.Kernel.Group.Database {

    private static let maximumBufferSize = 1 << 20

    public static func find(name: String) throws(Error) -> Entry? {
        try unsafe withReentrantLookup { buffer, gr, result in
            name.withCString { cName in
                unsafe getgrnam_r(cName, gr, buffer.baseAddress, numericCast(buffer.count), result)
            }
        }
    }

    public static func find(gid: ISO_9945.Kernel.Group.ID) throws(Error) -> Entry? {
        try unsafe withReentrantLookup { buffer, gr, result in
            unsafe getgrgid_r(
                gid.underlying,
                gr,
                buffer.baseAddress,
                numericCast(buffer.count),
                result
            )
        }
    }

    private static func withReentrantLookup(
        _ lookup: (
            UnsafeMutableBufferPointer<CChar>,
            UnsafeMutablePointer<group>,
            UnsafeMutablePointer<UnsafeMutablePointer<group>?>
        ) -> Int32
    ) throws(Error) -> Entry? {
        var bufferSize = initialBufferSize()
        while true {
            var gr = unsafe group()
            var resultPtr: UnsafeMutablePointer<group>?
            var buffer = [CChar](repeating: 0, count: bufferSize)

            let rc = buffer.withUnsafeMutableBufferPointer { bufferPtr in
                withUnsafeMutablePointer(to: &gr) { grPtr in
                    withUnsafeMutablePointer(to: &resultPtr) { resultPtrPtr in
                        unsafe lookup(bufferPtr, grPtr, resultPtrPtr)
                    }
                }
            }

            if rc == 0 {
                guard let resultPtr = unsafe resultPtr else { return nil }
                return unsafe entry(from: resultPtr)
            }

            if rc == ERANGE, bufferSize < maximumBufferSize {
                bufferSize *= 2
                continue
            }

            throw .lookup(.posix(rc))
        }
    }

    private static func initialBufferSize() -> Int {
        let suggested = sysconf(Int32(_SC_GETGR_R_SIZE_MAX))
        return suggested > 0 ? Int(suggested) : 1024
    }

    private static func entry(from gr: UnsafePointer<group>) -> Entry {
        var members: [String] = []
        if let memberList = unsafe gr.pointee.gr_mem {
            var i = 0
            while let member = unsafe memberList[i] {
                unsafe members.append(String(cString: member))
                i += 1
            }
        }

        return unsafe Entry(
            name: String(cString: gr.pointee.gr_name),
            gid: ISO_9945.Kernel.Group.ID(_unchecked: gr.pointee.gr_gid),
            members: members
        )
    }
}

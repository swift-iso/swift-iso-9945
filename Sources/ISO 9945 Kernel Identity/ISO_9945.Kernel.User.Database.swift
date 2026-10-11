#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.User {

    public enum Database {}
}

extension ISO_9945.Kernel.User.Database {

    private static let maximumBufferSize = 1 << 20

    public static func find(name: String) throws(Error) -> Entry? {
        try unsafe withReentrantLookup { buffer, pwd, result in
            name.withCString { cName in
                unsafe getpwnam_r(
                    cName,
                    pwd,
                    buffer.baseAddress!,
                    numericCast(buffer.count),
                    result
                )
            }
        }
    }

    public static func find(uid: ISO_9945.Kernel.User.ID) throws(Error) -> Entry? {
        try unsafe withReentrantLookup { buffer, pwd, result in
            unsafe getpwuid_r(
                uid.underlying,
                pwd,
                buffer.baseAddress!,
                numericCast(buffer.count),
                result
            )
        }
    }

    private static func withReentrantLookup(
        _ lookup: (
            UnsafeMutableBufferPointer<CChar>,
            UnsafeMutablePointer<passwd>,
            UnsafeMutablePointer<UnsafeMutablePointer<passwd>?>
        ) -> Int32
    ) throws(Error) -> Entry? {
        var bufferSize = initialBufferSize()
        while true {
            var pwd = unsafe passwd()
            var resultPtr: UnsafeMutablePointer<passwd>?
            var buffer = [CChar](repeating: 0, count: bufferSize)

            let rc = buffer.withUnsafeMutableBufferPointer { bufferPtr in
                withUnsafeMutablePointer(to: &pwd) { pwdPtr in
                    withUnsafeMutablePointer(to: &resultPtr) { resultPtrPtr in
                        unsafe lookup(bufferPtr, pwdPtr, resultPtrPtr)
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
        let suggested = sysconf(Int32(_SC_GETPW_R_SIZE_MAX))
        return suggested > 0 ? Int(suggested) : 1024
    }

    private static func entry(from pw: UnsafePointer<passwd>) -> Entry {
        unsafe Entry(
            name: String(cString: pw.pointee.pw_name),
            uid: ISO_9945.Kernel.User.ID(_unchecked: pw.pointee.pw_uid),
            gid: ISO_9945.Kernel.Group.ID(_unchecked: pw.pointee.pw_gid),
            home: String(cString: pw.pointee.pw_dir),
            shell: String(cString: pw.pointee.pw_shell)
        )
    }
}

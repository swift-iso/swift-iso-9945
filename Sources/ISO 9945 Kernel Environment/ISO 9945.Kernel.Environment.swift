#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Environment {

    public static func withValueBytes<R: ~Copyable>(
        _ name: UnsafePointer<String.Char>,
        _ body: (Swift.Span<String.Char>) -> R
    ) -> R? {
        let cName = unsafe UnsafePointer<CChar>(name)
        guard let valuePtr = unsafe getenv(cName) else {
            return nil
        }

        var length = 0
        while (unsafe valuePtr[length]) != 0 {
            length += 1
        }

        let u8Ptr = unsafe UnsafePointer<UInt8>(valuePtr)
        let span = unsafe Span(_unsafeStart: u8Ptr, count: length)
        return body(span)
    }

    public static func withValue<R: ~Copyable>(
        _ name: UnsafePointer<String.Char>,
        _ body: (borrowing String.Borrowed) -> R
    ) -> R? {
        let cName = unsafe UnsafePointer<CChar>(name)
        guard let valuePtr = unsafe getenv(cName) else {
            return nil
        }

        let u8Ptr = unsafe UnsafePointer<UInt8>(valuePtr)
        let view = unsafe String.Borrowed(u8Ptr, count: String.length(of: u8Ptr))
        return body(view)
    }

    public static func get(_ name: UnsafePointer<String.Char>) -> String? {
        unsafe withValue(name) { view in
            String(copying: view)
        }
    }

    public static func set(
        _ name: UnsafePointer<String.Char>,
        to value: UnsafePointer<String.Char>,
        overwrite: Bool = true
    ) throws(ISO_9945.Kernel.Environment.Error) {

        try unsafe validate(name: name)
        let cName = unsafe UnsafePointer<CChar>(name)
        let cValue = unsafe UnsafePointer<CChar>(value)
        let result = unsafe setenv(cName, cValue, overwrite ? 1 : 0)
        guard result == 0 else {
            throw .current()
        }
    }

    public static func unset(
        _ name: UnsafePointer<String.Char>
    ) throws(ISO_9945.Kernel.Environment.Error) {
        try unsafe validate(name: name)
        let cName = unsafe UnsafePointer<CChar>(name)
        let result = unsafe unsetenv(cName)
        guard result == 0 else {
            throw .current()
        }
    }

    internal static func validate(
        name: UnsafePointer<String.Char>
    ) throws(ISO_9945.Kernel.Environment.Error) {
        guard unsafe (name[0] != 0) else {
            throw .invalid(.emptyName)
        }
        var index = 0
        while unsafe (name[index] != 0) {
            if unsafe (name[index] == 0x3D) {
                throw .invalid(.nameContainsEquals)
            }
            index += 1
        }
    }
}

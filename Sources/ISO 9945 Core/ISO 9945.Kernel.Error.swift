#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension Error_Primitives.Error {

    public static func captureErrno() -> Error_Primitives.Error.Code {
        .posix(errno)
    }
}

extension Error_Primitives.Error {

    public static func current(
        operation: StaticString,
        function: StaticString = #function,
        fileID: StaticString = #fileID,
        line: UInt32 = #line
    ) -> Self {
        .capturing(
            .posix(errno),
            operation: operation,
            function: function,
            file: .init(id: fileID),
            line: line
        )
    }
}

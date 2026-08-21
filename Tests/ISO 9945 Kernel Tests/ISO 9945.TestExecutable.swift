#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#endif

enum TestExecutable {

    struct NotFound: Swift.Error, CustomStringConvertible {
        let name: Swift.String

        var description: Swift.String {
            """
            test-support executable '\(name)' not found beside the running test \
            binary. Build it (it is an executableTarget in this package) or set an \
            explicit override environment variable.
            """
        }
    }

    private static let maximumAscent = 5

    static func path(_ name: Swift.String, overrides: [Swift.String] = []) -> Swift.String? {
        for variable in overrides {
            if let value = unsafe getenv(variable) {
                let candidate = unsafe Swift.String(cString: value)
                if isExecutable(candidate) {
                    return candidate
                }
            }
        }

        guard var directory = runningExecutableDirectory() else { return nil }

        for _ in 0..<maximumAscent {
            let candidate = "\(directory)/\(name)"
            if isExecutable(candidate) {
                return candidate
            }
            guard
                let separator = directory.lastIndex(of: "/"),
                separator != directory.startIndex
            else { break }
            directory = Swift.String(directory[..<separator])
        }

        return nil
    }

    private static func runningExecutableDirectory() -> Swift.String? {
        guard let executable = runningImagePath() else { return nil }
        guard let separator = executable.lastIndex(of: "/") else { return nil }
        return Swift.String(executable[..<separator])
    }

    #if canImport(Darwin)

        private static let imageMarker: @convention(c) () -> Void = {}
    #endif

    private static func runningImagePath() -> Swift.String? {
        #if canImport(Darwin)
            var info = unsafe Dl_info()
            let address: UnsafeRawPointer = unsafe unsafeBitCast(
                Self.imageMarker,
                to: UnsafeRawPointer.self
            )
            guard unsafe dladdr(address, &info) != 0 else { return nil }
            guard let name = unsafe info.dli_fname else { return nil }
            return unsafe Swift.String(cString: name)
        #elseif canImport(Glibc)
            var buffer = [CChar](repeating: 0, count: 4096)
            let written = unsafe readlink("/proc/self/exe", &buffer, buffer.count - 1)
            guard written > 0 else { return nil }
            buffer[written] = 0
            return Self.string(fromNulTerminated: buffer)
        #else
            return nil
        #endif
    }

    private static func string(fromNulTerminated buffer: [CChar]) -> Swift.String {
        unsafe buffer.withUnsafeBufferPointer { pointer in
            unsafe Swift.String(cString: pointer.baseAddress!)
        }
    }

    private static func isExecutable(_ path: Swift.String) -> Bool {
        unsafe path.withCString { cPath in
            unsafe access(cPath, X_OK) == 0
        }
    }
}

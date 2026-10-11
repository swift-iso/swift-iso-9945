import ISO_9945_Core
import ISO_9945_Loader
import Loader_Vocabulary
import Testing

extension ISO_9945.Loader.Library {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
    }
}

extension ISO_9945.Loader.Library.Test.Unit {
    @Test
    func `POSIX.1-2024 dlopen with a null file returns a handle to the global symbol object`() throws {
        let handle = try unsafe ISO_9945.Loader.Library.open(path: nil, options: .now)
        try unsafe ISO_9945.Loader.Library.close(handle)
    }

    @Test
    func `POSIX.1-2024 dlopen accepts RTLD_LAZY with RTLD_LOCAL`() throws {
        let handle = try unsafe ISO_9945.Loader.Library.open(path: nil, options: [.lazy, .local])
        try unsafe ISO_9945.Loader.Library.close(handle)
    }
}

extension ISO_9945.Loader.Library.Test.`Edge Case` {
    @Test
    func `POSIX.1-2024 dlopen of a nonexistent file fails`() {
        #expect(throws: ISO_9945.Loader.Error.self) {
            try unsafe "/nonexistent/iso-9945-loader-test.so".withCString { path in
                _ = try unsafe ISO_9945.Loader.Library.open(path: path)
            }
        }
    }
}

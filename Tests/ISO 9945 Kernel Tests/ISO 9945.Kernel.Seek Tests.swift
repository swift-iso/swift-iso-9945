import Error
import ISO_9945_Kernel_Test_Support
import Path
import Tagged
import Testing

@testable import ISO_9945_Kernel

extension ISO_9945.Kernel.File.Seek {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
    }
}

#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#elseif canImport(Musl)
    import Musl
#endif

extension ISO_9945.Kernel.File.Seek.Test.Unit {
    @Test
    func `POSIX.1-2024 lseek whence values are SEEK_SET, SEEK_CUR and SEEK_END`() {
        #expect(ISO_9945.Kernel.File.Seek.Whence.start.rawValue == SEEK_SET)
        #expect(ISO_9945.Kernel.File.Seek.Whence.current.rawValue == SEEK_CUR)
        #expect(ISO_9945.Kernel.File.Seek.Whence.end.rawValue == SEEK_END)
    }
}

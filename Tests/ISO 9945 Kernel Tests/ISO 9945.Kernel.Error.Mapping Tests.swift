@_spi(Syscall) import ISO_9945_Core
import ISO_9945_Kernel
import Memory
import Path
import Tagged_Standard_Library_Integration
import Testing

@testable import Error

#if !os(Windows)

    #if canImport(Darwin)
        import Darwin
    #elseif canImport(Glibc)
        import Glibc
    #elseif canImport(Musl)
        import Musl
    #endif

    @Suite("Path.Resolution.Error Mapping")
    struct PathResolutionErrorMappingTests {
        @Test
        func `notFound from ENOENT`() {
            let error = Path.Resolution.Error(code: .posix(ENOENT))
            #expect(error == .notFound)
        }

        @Test
        func `exists from EEXIST`() {
            let error = Path.Resolution.Error(code: .posix(EEXIST))
            #expect(error == .exists)
        }

        @Test
        func `isDirectory from EISDIR`() {
            let error = Path.Resolution.Error(code: .posix(EISDIR))
            #expect(error == .isDirectory)
        }

        @Test
        func `notDirectory from ENOTDIR`() {
            let error = Path.Resolution.Error(code: .posix(ENOTDIR))
            #expect(error == .notDirectory)
        }

        @Test
        func `returns nil for unmapped errno`() {
            let error = Path.Resolution.Error(code: .posix(EINTR))
            #expect(error == nil)
        }
    }

    @Suite("Permission.Error Mapping")
    struct PermissionErrorMappingTests {
        @Test
        func `denied from EACCES`() {
            let error = ISO_9945.Kernel.Permission.Error(code: .posix(EACCES))
            #expect(error == .denied)
        }

        @Test
        func `notPermitted from EPERM`() {
            let error = ISO_9945.Kernel.Permission.Error(code: .posix(EPERM))
            #expect(error == .notPermitted)
        }

        @Test
        func `readOnlyFilesystem from EROFS`() {
            let error = ISO_9945.Kernel.Permission.Error(code: .posix(EROFS))
            #expect(error == .readOnlyFilesystem)
        }

        @Test
        func `returns nil for unmapped errno`() {
            let error = ISO_9945.Kernel.Permission.Error(code: .posix(EINTR))
            #expect(error == nil)
        }
    }

    @Suite("Descriptor.Validity.Error Mapping")
    struct DescriptorValidityErrorMappingTests {
        @Test
        func `invalid from EBADF`() {
            let error = ISO_9945.Kernel.Descriptor.Validity.Error(code: .posix(EBADF))
            #expect(error == .invalid)
        }

        @Test
        func `limit process from EMFILE`() {
            let error = ISO_9945.Kernel.Descriptor.Validity.Error(code: .posix(EMFILE))
            #expect(error == .limit(.process))
        }

        @Test
        func `limit system from ENFILE`() {
            let error = ISO_9945.Kernel.Descriptor.Validity.Error(code: .posix(ENFILE))
            #expect(error == .limit(.system))
        }

        @Test
        func `returns nil for unmapped errno`() {
            let error = ISO_9945.Kernel.Descriptor.Validity.Error(code: .posix(EINTR))
            #expect(error == nil)
        }
    }

    @Suite("IO.Blocking.Error Mapping")
    struct IOBlockingErrorMappingTests {
        @Test
        func `wouldBlock from EAGAIN`() {
            let error = ISO_9945.Kernel.IO.Blocking.Error(code: .posix(EAGAIN))
            #expect(error == .wouldBlock)
        }

        @Test
        func `returns nil for unmapped errno`() {
            let error = ISO_9945.Kernel.IO.Blocking.Error(code: .posix(EACCES))
            #expect(error == nil)
        }
    }

    @Suite("Storage.Error Mapping")
    struct StorageErrorMappingTests {
        @Test
        func `exhausted from ENOSPC`() {
            let error = ISO_9945.Kernel.Storage.Error(code: .posix(ENOSPC))
            #expect(error == .exhausted)
        }

        @Test
        func `quota from EDQUOT`() {
            let error = ISO_9945.Kernel.Storage.Error(code: .posix(EDQUOT))
            #expect(error == .quota)
        }

        @Test
        func `returns nil for unmapped errno`() {
            let error = ISO_9945.Kernel.Storage.Error(code: .posix(EINTR))
            #expect(error == nil)
        }
    }

    @Suite("Memory.Allocation.Error Mapping")
    struct MemoryAllocationErrorMappingTests {
        @Test
        func `exhausted from ENOMEM`() {
            let error = Memory.Allocation.Error(code: .posix(ENOMEM))
            #expect(error == .exhausted)
        }

        @Test
        func `returns nil for unmapped errno`() {
            let error = Memory.Allocation.Error(code: .posix(EINTR))
            #expect(error == nil)
        }
    }

    @Suite("IO.Error Mapping")
    struct IOErrorMappingTests {
        @Test
        func `hardware from EIO`() {
            let error = ISO_9945.Kernel.IO.Error(code: .posix(EIO))
            #expect(error == .hardware)
        }

        @Test
        func `broken from EPIPE`() {
            let error = ISO_9945.Kernel.IO.Error(code: .posix(EPIPE))
            #expect(error == .broken)
        }

        @Test
        func `reset from ECONNRESET`() {
            let error = ISO_9945.Kernel.IO.Error(code: .posix(ECONNRESET))
            #expect(error == .reset)
        }

        @Test
        func `returns nil for unmapped errno`() {
            let error = ISO_9945.Kernel.IO.Error(code: .posix(EINTR))
            #expect(error == nil)
        }
    }

    @Suite("Error.Error")
    struct KernelErrorTests {
        @Test
        func `creates error from errno code`() {
            let error = Error.Error(code: .posix(EINTR))
            if case .posix(let value) = error.code {
                #expect(value == EINTR)
            } else {
                Issue.record("Expected .posix code")
            }
        }

        @Test
        func `error is Sendable`() {
            let error: any Sendable = Error.Error(code: .posix(EINTR))
            #expect(error is Error.Error)
        }

        @Test
        func `error is Equatable`() {
            let a = Error.Error(code: .posix(EINTR))
            let b = Error.Error(code: .posix(EINTR))
            let c = Error.Error(code: .posix(ENOENT))
            #expect(a == b)
            #expect(a != c)
        }

        @Test
        func `error is Hashable`() {
            var set = Set<Error.Error>()
            set.insert(Error.Error(code: .posix(1)))
            set.insert(Error.Error(code: .posix(2)))
            set.insert(Error.Error(code: .posix(1)))
            #expect(set.count == 2)
        }
    }

#endif

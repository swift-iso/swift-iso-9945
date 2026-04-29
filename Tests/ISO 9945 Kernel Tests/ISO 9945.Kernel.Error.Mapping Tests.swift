// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

// Tests use Apple native Testing framework
import Testing
import Kernel_Primitives_Test_Support

@testable import Error_Primitives
import Path_Primitives
import Kernel_Permission_Primitives
import Kernel_Descriptor_Primitives
import Kernel_File_Primitives
import Memory_Primitives

// L2 init?(code:) extensions live in ISO 9945 Core
@_spi(Syscall) import ISO_9945_Core

// Error_Primitives.Error.Mapping.swift contains extension initializers for error mapping.
// These tests verify the error mapping functionality using Error_Primitives.Error.Code.

#if !os(Windows)

    #if canImport(Darwin)
        import Darwin
    #elseif canImport(Glibc)
        import Glibc
    #elseif canImport(Musl)
        import Musl
    #endif

    // MARK: - Path.Resolution.Error Mapping Tests

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

    // MARK: - Permission.Error Mapping Tests

    @Suite("Permission.Error Mapping")
    struct PermissionErrorMappingTests {
        @Test
        func `denied from EACCES`() {
            let error = Kernel.Permission.Error(code: .posix(EACCES))
            #expect(error == .denied)
        }

        @Test
        func `notPermitted from EPERM`() {
            let error = Kernel.Permission.Error(code: .posix(EPERM))
            #expect(error == .notPermitted)
        }

        @Test
        func `readOnlyFilesystem from EROFS`() {
            let error = Kernel.Permission.Error(code: .posix(EROFS))
            #expect(error == .readOnlyFilesystem)
        }

        @Test
        func `returns nil for unmapped errno`() {
            let error = Kernel.Permission.Error(code: .posix(EINTR))
            #expect(error == nil)
        }
    }

    // MARK: - Descriptor.Validity.Error Mapping Tests

    @Suite("Descriptor.Validity.Error Mapping")
    struct DescriptorValidityErrorMappingTests {
        @Test
        func `invalid from EBADF`() {
            let error = Kernel.Descriptor.Validity.Error(code: .posix(EBADF))
            #expect(error == .invalid)
        }

        @Test
        func `limit process from EMFILE`() {
            let error = Kernel.Descriptor.Validity.Error(code: .posix(EMFILE))
            #expect(error == .limit(.process))
        }

        @Test
        func `limit system from ENFILE`() {
            let error = Kernel.Descriptor.Validity.Error(code: .posix(ENFILE))
            #expect(error == .limit(.system))
        }

        @Test
        func `returns nil for unmapped errno`() {
            let error = Kernel.Descriptor.Validity.Error(code: .posix(EINTR))
            #expect(error == nil)
        }
    }

    // MARK: - IO.Blocking.Error Mapping Tests

    @Suite("IO.Blocking.Error Mapping")
    struct IOBlockingErrorMappingTests {
        @Test
        func `wouldBlock from EAGAIN`() {
            let error = Kernel.IO.Blocking.Error(code: .posix(EAGAIN))
            #expect(error == .wouldBlock)
        }

        @Test
        func `returns nil for unmapped errno`() {
            let error = Kernel.IO.Blocking.Error(code: .posix(EACCES))
            #expect(error == nil)
        }
    }

    // MARK: - Storage.Error Mapping Tests

    @Suite("Storage.Error Mapping")
    struct StorageErrorMappingTests {
        @Test
        func `exhausted from ENOSPC`() {
            let error = Kernel.Storage.Error(code: .posix(ENOSPC))
            #expect(error == .exhausted)
        }

        @Test
        func `quota from EDQUOT`() {
            let error = Kernel.Storage.Error(code: .posix(EDQUOT))
            #expect(error == .quota)
        }

        @Test
        func `returns nil for unmapped errno`() {
            let error = Kernel.Storage.Error(code: .posix(EINTR))
            #expect(error == nil)
        }
    }

    // MARK: - Memory.Error Mapping Tests

    @Suite("Memory.Error Mapping")
    struct MemoryErrorMappingTests {
        @Test
        func `fault from EFAULT`() {
            let error = Memory.Error(code: .posix(EFAULT))
            #expect(error == .fault)
        }

        @Test
        func `exhausted from ENOMEM`() {
            let error = Memory.Error(code: .posix(ENOMEM))
            #expect(error == .exhausted)
        }

        @Test
        func `returns nil for unmapped errno`() {
            let error = Memory.Error(code: .posix(EINTR))
            #expect(error == nil)
        }
    }

    // MARK: - IO.Error Mapping Tests

    @Suite("IO.Error Mapping")
    struct IOErrorMappingTests {
        @Test
        func `hardware from EIO`() {
            let error = Kernel.IO.Error(code: .posix(EIO))
            #expect(error == .hardware)
        }

        @Test
        func `broken from EPIPE`() {
            let error = Kernel.IO.Error(code: .posix(EPIPE))
            #expect(error == .broken)
        }

        @Test
        func `reset from ECONNRESET`() {
            let error = Kernel.IO.Error(code: .posix(ECONNRESET))
            #expect(error == .reset)
        }

        @Test
        func `returns nil for unmapped errno`() {
            let error = Kernel.IO.Error(code: .posix(EINTR))
            #expect(error == nil)
        }
    }

    // MARK: - Error_Primitives.Error Tests

    @Suite("Error_Primitives.Error")
    struct KernelErrorTests {
        @Test
        func `creates error from errno code`() {
            let error = Error_Primitives.Error(code: .posix(EINTR))
            if case .posix(let value) = error.code {
                #expect(value == EINTR)
            } else {
                Issue.record("Expected .posix code")
            }
        }

        @Test
        func `error is Sendable`() {
            let error: any Sendable = Error_Primitives.Error(code: .posix(EINTR))
            #expect(error is Error_Primitives.Error)
        }

        @Test
        func `error is Equatable`() {
            let a = Error_Primitives.Error(code: .posix(EINTR))
            let b = Error_Primitives.Error(code: .posix(EINTR))
            let c = Error_Primitives.Error(code: .posix(ENOENT))
            #expect(a == b)
            #expect(a != c)
        }

        @Test
        func `error is Hashable`() {
            var set = Set<Error_Primitives.Error>()
            set.insert(Error_Primitives.Error(code: .posix(1)))
            set.insert(Error_Primitives.Error(code: .posix(2)))
            set.insert(Error_Primitives.Error(code: .posix(1)))  // duplicate
            #expect(set.count == 2)
        }
    }

#endif

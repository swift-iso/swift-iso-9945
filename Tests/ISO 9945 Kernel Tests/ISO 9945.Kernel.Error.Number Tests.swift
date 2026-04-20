// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

// Tests use Apple native Testing framework
import Testing
import ISO_9945_Kernel_Test_Support
import ISO_9945_Kernel
import Kernel_Primitives_Core
import Kernel_Descriptor_Primitives
import Kernel_Event_Primitives
import Kernel_IO_Primitives
import Kernel_File_Primitives
import Kernel_Path_Primitives
import Kernel_Environment_Primitives
import Kernel_Process_Primitives
import Kernel_Thread_Primitives
import Kernel_Error_Primitives

@testable import ISO_9945_Kernel

extension Kernel.Error.Number {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Error Number Tests


    #if canImport(Darwin)
        import Darwin
    #elseif canImport(Glibc)
        import Glibc
    #elseif canImport(Musl)
        import Musl
    #endif

    extension Kernel.Error.Number.Test.Unit {
        @Test
        func `noEntry equals ENOENT`() {
            #expect(Kernel.Error.Number.noEntry == Kernel.Error.Number(__unchecked: (), ENOENT))
        }

        @Test
        func `accessDenied equals EACCES`() {
            #expect(Kernel.Error.Number.accessDenied == Kernel.Error.Number(__unchecked: (), EACCES))
        }

        @Test
        func `notPermitted equals EPERM`() {
            #expect(Kernel.Error.Number.notPermitted == Kernel.Error.Number(__unchecked: (), EPERM))
        }

        @Test
        func `exists equals EEXIST`() {
            #expect(Kernel.Error.Number.exists == Kernel.Error.Number(__unchecked: (), EEXIST))
        }

        @Test
        func `isDirectory equals EISDIR`() {
            #expect(Kernel.Error.Number.isDirectory == Kernel.Error.Number(__unchecked: (), EISDIR))
        }

        @Test
        func `processLimit equals EMFILE`() {
            #expect(Kernel.Error.Number.processLimit == Kernel.Error.Number(__unchecked: (), EMFILE))
        }

        @Test
        func `systemLimit equals ENFILE`() {
            #expect(Kernel.Error.Number.systemLimit == Kernel.Error.Number(__unchecked: (), ENFILE))
        }

        @Test
        func `invalid equals EINVAL`() {
            #expect(Kernel.Error.Number.invalid == Kernel.Error.Number(__unchecked: (), EINVAL))
        }

        @Test
        func `interrupted equals EINTR`() {
            #expect(Kernel.Error.Number.interrupted == Kernel.Error.Number(__unchecked: (), EINTR))
        }

        @Test
        func `wouldBlock equals EAGAIN`() {
            #expect(Kernel.Error.Number.wouldBlock == Kernel.Error.Number(__unchecked: (), EAGAIN))
        }

        @Test
        func `noDevice equals ENODEV`() {
            #expect(Kernel.Error.Number.noDevice == Kernel.Error.Number(__unchecked: (), ENODEV))
        }

        @Test
        func `notDirectory equals ENOTDIR`() {
            #expect(Kernel.Error.Number.notDirectory == Kernel.Error.Number(__unchecked: (), ENOTDIR))
        }

        @Test
        func `readOnlyFilesystem equals EROFS`() {
            #expect(Kernel.Error.Number.readOnlyFilesystem == Kernel.Error.Number(__unchecked: (), EROFS))
        }

        @Test
        func `noSpace equals ENOSPC`() {
            #expect(Kernel.Error.Number.noSpace == Kernel.Error.Number(__unchecked: (), ENOSPC))
        }

        @Test
        func `badDescriptor equals EBADF`() {
            #expect(Kernel.Error.Number.badDescriptor == Kernel.Error.Number(__unchecked: (), EBADF))
        }
    }

    extension Kernel.Error.Number.Test.Unit {
        @Test
        func `all error number values are distinct`() {
            let values: [Kernel.Error.Number] = [
                .noEntry,
                .accessDenied,
                .notPermitted,
                .exists,
                .isDirectory,
                .processLimit,
                .systemLimit,
                .invalid,
                .interrupted,
                .noDevice,
                .notDirectory,
                .readOnlyFilesystem,
                .noSpace,
                .badDescriptor,
            ]
            let uniqueValues = Set(values)
            #expect(uniqueValues.count == values.count, "All error number values should be distinct")
        }

        @Test
        func `all error number values are positive`() {
            #expect(Kernel.Error.Number.noEntry > 0)
            #expect(Kernel.Error.Number.accessDenied > 0)
            #expect(Kernel.Error.Number.notPermitted > 0)
            #expect(Kernel.Error.Number.exists > 0)
            #expect(Kernel.Error.Number.invalid > 0)
            #expect(Kernel.Error.Number.interrupted > 0)
            #expect(Kernel.Error.Number.badDescriptor > 0)
        }
    }


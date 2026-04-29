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
import Kernel_File_Primitives
import Path_Primitives
import Kernel_Process_Primitives
import Error_Primitives

@testable import ISO_9945_Kernel

extension Error_Primitives.Error.Number {
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

    extension Error_Primitives.Error.Number.Test.Unit {
        @Test
        func `noEntry equals ENOENT`() {
            #expect(Error_Primitives.Error.Number.noEntry == Error_Primitives.Error.Number(__unchecked: (), ENOENT))
        }

        @Test
        func `accessDenied equals EACCES`() {
            #expect(Error_Primitives.Error.Number.accessDenied == Error_Primitives.Error.Number(__unchecked: (), EACCES))
        }

        @Test
        func `notPermitted equals EPERM`() {
            #expect(Error_Primitives.Error.Number.notPermitted == Error_Primitives.Error.Number(__unchecked: (), EPERM))
        }

        @Test
        func `exists equals EEXIST`() {
            #expect(Error_Primitives.Error.Number.exists == Error_Primitives.Error.Number(__unchecked: (), EEXIST))
        }

        @Test
        func `isDirectory equals EISDIR`() {
            #expect(Error_Primitives.Error.Number.isDirectory == Error_Primitives.Error.Number(__unchecked: (), EISDIR))
        }

        @Test
        func `processLimit equals EMFILE`() {
            #expect(Error_Primitives.Error.Number.processLimit == Error_Primitives.Error.Number(__unchecked: (), EMFILE))
        }

        @Test
        func `systemLimit equals ENFILE`() {
            #expect(Error_Primitives.Error.Number.systemLimit == Error_Primitives.Error.Number(__unchecked: (), ENFILE))
        }

        @Test
        func `invalid equals EINVAL`() {
            #expect(Error_Primitives.Error.Number.invalid == Error_Primitives.Error.Number(__unchecked: (), EINVAL))
        }

        @Test
        func `interrupted equals EINTR`() {
            #expect(Error_Primitives.Error.Number.interrupted == Error_Primitives.Error.Number(__unchecked: (), EINTR))
        }

        @Test
        func `wouldBlock equals EAGAIN`() {
            #expect(Error_Primitives.Error.Number.wouldBlock == Error_Primitives.Error.Number(__unchecked: (), EAGAIN))
        }

        @Test
        func `noDevice equals ENODEV`() {
            #expect(Error_Primitives.Error.Number.noDevice == Error_Primitives.Error.Number(__unchecked: (), ENODEV))
        }

        @Test
        func `notDirectory equals ENOTDIR`() {
            #expect(Error_Primitives.Error.Number.notDirectory == Error_Primitives.Error.Number(__unchecked: (), ENOTDIR))
        }

        @Test
        func `readOnlyFilesystem equals EROFS`() {
            #expect(Error_Primitives.Error.Number.readOnlyFilesystem == Error_Primitives.Error.Number(__unchecked: (), EROFS))
        }

        @Test
        func `noSpace equals ENOSPC`() {
            #expect(Error_Primitives.Error.Number.noSpace == Error_Primitives.Error.Number(__unchecked: (), ENOSPC))
        }

        @Test
        func `badDescriptor equals EBADF`() {
            #expect(Error_Primitives.Error.Number.badDescriptor == Error_Primitives.Error.Number(__unchecked: (), EBADF))
        }
    }

    extension Error_Primitives.Error.Number.Test.Unit {
        @Test
        func `all error number values are distinct`() {
            let values: [Error_Primitives.Error.Number] = [
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
            #expect(Error_Primitives.Error.Number.noEntry > 0)
            #expect(Error_Primitives.Error.Number.accessDenied > 0)
            #expect(Error_Primitives.Error.Number.notPermitted > 0)
            #expect(Error_Primitives.Error.Number.exists > 0)
            #expect(Error_Primitives.Error.Number.invalid > 0)
            #expect(Error_Primitives.Error.Number.interrupted > 0)
            #expect(Error_Primitives.Error.Number.badDescriptor > 0)
        }
    }


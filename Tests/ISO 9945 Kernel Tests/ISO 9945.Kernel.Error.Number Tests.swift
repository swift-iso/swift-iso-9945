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
import ISO_9945
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
        @Test("noEntry equals ENOENT")
        func noEntryEqualsENOENT() {
            #expect(Kernel.Error.Number.noEntry == Kernel.Error.Number(__unchecked: (), ENOENT))
        }

        @Test("accessDenied equals EACCES")
        func accessDeniedEqualsEACCES() {
            #expect(Kernel.Error.Number.accessDenied == Kernel.Error.Number(__unchecked: (), EACCES))
        }

        @Test("notPermitted equals EPERM")
        func notPermittedEqualsEPERM() {
            #expect(Kernel.Error.Number.notPermitted == Kernel.Error.Number(__unchecked: (), EPERM))
        }

        @Test("exists equals EEXIST")
        func existsEqualsEEXIST() {
            #expect(Kernel.Error.Number.exists == Kernel.Error.Number(__unchecked: (), EEXIST))
        }

        @Test("isDirectory equals EISDIR")
        func isDirectoryEqualsEISDIR() {
            #expect(Kernel.Error.Number.isDirectory == Kernel.Error.Number(__unchecked: (), EISDIR))
        }

        @Test("processLimit equals EMFILE")
        func processLimitEqualsEMFILE() {
            #expect(Kernel.Error.Number.processLimit == Kernel.Error.Number(__unchecked: (), EMFILE))
        }

        @Test("systemLimit equals ENFILE")
        func systemLimitEqualsENFILE() {
            #expect(Kernel.Error.Number.systemLimit == Kernel.Error.Number(__unchecked: (), ENFILE))
        }

        @Test("invalid equals EINVAL")
        func invalidEqualsEINVAL() {
            #expect(Kernel.Error.Number.invalid == Kernel.Error.Number(__unchecked: (), EINVAL))
        }

        @Test("interrupted equals EINTR")
        func interruptedEqualsEINTR() {
            #expect(Kernel.Error.Number.interrupted == Kernel.Error.Number(__unchecked: (), EINTR))
        }

        @Test("wouldBlock equals EAGAIN")
        func wouldBlockEqualsEAGAIN() {
            #expect(Kernel.Error.Number.wouldBlock == Kernel.Error.Number(__unchecked: (), EAGAIN))
        }

        @Test("noDevice equals ENODEV")
        func noDeviceEqualsENODEV() {
            #expect(Kernel.Error.Number.noDevice == Kernel.Error.Number(__unchecked: (), ENODEV))
        }

        @Test("notDirectory equals ENOTDIR")
        func notDirectoryEqualsENOTDIR() {
            #expect(Kernel.Error.Number.notDirectory == Kernel.Error.Number(__unchecked: (), ENOTDIR))
        }

        @Test("readOnlyFilesystem equals EROFS")
        func readOnlyFilesystemEqualsEROFS() {
            #expect(Kernel.Error.Number.readOnlyFilesystem == Kernel.Error.Number(__unchecked: (), EROFS))
        }

        @Test("noSpace equals ENOSPC")
        func noSpaceEqualsENOSPC() {
            #expect(Kernel.Error.Number.noSpace == Kernel.Error.Number(__unchecked: (), ENOSPC))
        }

        @Test("badDescriptor equals EBADF")
        func badDescriptorEqualsEBADF() {
            #expect(Kernel.Error.Number.badDescriptor == Kernel.Error.Number(__unchecked: (), EBADF))
        }
    }

    extension Kernel.Error.Number.Test.Unit {
        @Test("all error number values are distinct")
        func allValuesDistinct() {
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

        @Test("all error number values are positive")
        func allValuesPositive() {
            #expect(Kernel.Error.Number.noEntry > 0)
            #expect(Kernel.Error.Number.accessDenied > 0)
            #expect(Kernel.Error.Number.notPermitted > 0)
            #expect(Kernel.Error.Number.exists > 0)
            #expect(Kernel.Error.Number.invalid > 0)
            #expect(Kernel.Error.Number.interrupted > 0)
            #expect(Kernel.Error.Number.badDescriptor > 0)
        }
    }


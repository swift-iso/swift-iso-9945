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


    #if canImport(Darwin)
        import Darwin
    #elseif canImport(Glibc)
        import Glibc
    #endif

import Testing
import Tagged_Primitives_Standard_Library_Integration

    import Path_Primitives
    import Error_Primitives
    @testable import ISO_9945_Kernel

    extension ISO_9945.Kernel.Process.Error {
        @Suite
        struct Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

// MARK: - Unit Tests

    extension ISO_9945.Kernel.Process.Error.Test.Unit {
        @Test
        func `error conforms to Swift.Error`() {
            let error: any Swift.Error = ISO_9945.Kernel.Process.Error.fork(.posix(1))
            #expect(error is ISO_9945.Kernel.Process.Error)
        }

        @Test
        func `error is Sendable`() {
            let error: any Sendable = ISO_9945.Kernel.Process.Error.fork(.posix(1))
            #expect(error is ISO_9945.Kernel.Process.Error)
        }

        @Test
        func `error is Equatable`() {
            let code = Error_Primitives.Error.Code.posix(1)
            #expect(ISO_9945.Kernel.Process.Error.fork(code) == ISO_9945.Kernel.Process.Error.fork(code))
            #expect(ISO_9945.Kernel.Process.Error.fork(code) != ISO_9945.Kernel.Process.Error.wait(code))
        }

        @Test
        func `code accessor returns underlying code`() {
            let code = Error_Primitives.Error.Code.posix(42)
            let errors: [ISO_9945.Kernel.Process.Error] = [
                .fork(code),
                .execute(code),
                .wait(code),
                .session(code),
                .group(code),
            ]

            for error in errors {
                #expect(error.code == code)
            }
        }

        @Test
        func `isInterrupted returns true for EINTR`() {
            let code = Error_Primitives.Error.Code.posix(EINTR)
            let error = ISO_9945.Kernel.Process.Error.wait(code)
            #expect(error.isInterrupted)

            let nonInterrupted = ISO_9945.Kernel.Process.Error.wait(.posix(1))
            #expect(!nonInterrupted.isInterrupted)
        }

        @Test
        func `all error cases are distinct`() {
            let code = Error_Primitives.Error.Code.posix(1)
            let cases: [ISO_9945.Kernel.Process.Error] = [
                .fork(code),
                .execute(code),
                .wait(code),
                .session(code),
                .group(code),
            ]

            for (i, a) in cases.enumerated() {
                for (j, b) in cases.enumerated() {
                    if i != j {
                        #expect(a != b, "Cases at index \(i) and \(j) should be different")
                    }
                }
            }
        }
    }

    // MARK: - Semantic Tests

    extension ISO_9945.Kernel.Process.Error.Test.Unit {
        @Test
        func `semantic classification works`() {
            let resourceLimit = ISO_9945.Kernel.Process.Error.fork(.posix(EAGAIN))
            #expect(resourceLimit.semantic == .resourceLimit)

            let noPermission = ISO_9945.Kernel.Process.Error.session(.posix(EPERM))
            #expect(noPermission.semantic == .noPermission)

            let noSuchProcess = ISO_9945.Kernel.Process.Error.wait(.posix(ESRCH))
            #expect(noSuchProcess.semantic == .noSuchProcess)

            let noChild = ISO_9945.Kernel.Process.Error.wait(.posix(ECHILD))
            #expect(noChild.semantic == .noSuchProcess)

            let interrupted = ISO_9945.Kernel.Process.Error.wait(.posix(EINTR))
            #expect(interrupted.semantic == .interrupted)

            let invalidArg = ISO_9945.Kernel.Process.Error.wait(.posix(EINVAL))
            #expect(invalidArg.semantic == .invalidArgument)
        }
    }


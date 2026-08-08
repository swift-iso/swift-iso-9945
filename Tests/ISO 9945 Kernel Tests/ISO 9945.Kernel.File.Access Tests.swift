// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

import ISO_9945_Kernel_Test_Support
import Path_Primitives
import Testing

@testable import ISO_9945_Kernel

extension ISO_9945.Kernel.File.Access {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct Integration {}
    }
}

extension ISO_9945.Kernel.File.Access.Test.Unit {
    @Test
    func `mode composes semantic requirements without exposing libc values`() {
        let mode = ISO_9945.Kernel.File.Access.Mode(read: true, execute: true)

        #expect(mode != .read)
        #expect(mode != .execute)
        #expect(ISO_9945.Kernel.File.Access.Mode.existence == .init())
    }
}

#if os(Android)
    extension ISO_9945.Kernel.File.Access.Test.Integration {
        @Test
        func `Android allows executable access or reports kernel unavailability`() throws {
            let path = KernelIOTest.makeTempPath(prefix: "effective-access-allowed")
            defer { KernelIOTest.cleanup(path: path) }
            let descriptor = try KernelIOTest.open(at: path)

            _ = try Path.scope(path) { path in
                try ISO_9945.Kernel.File.Attributes.set(.privateExecutable, at: path)
                do throws(ISO_9945.Kernel.File.Access.Error) {
                    let allowed = try ISO_9945.Kernel.File.Access.check(.execute, at: path)
                    #expect(allowed)
                } catch {
                    #expect(error == .unsupported)
                }
            }
            _ = descriptor
        }

        @Test
        func `Android denies nonexecutable access or reports kernel unavailability`() throws {
            let path = KernelIOTest.makeTempPath(prefix: "effective-access-denied")
            defer { KernelIOTest.cleanup(path: path) }
            let descriptor = try KernelIOTest.open(at: path)

            _ = try Path.scope(path) { path in
                try ISO_9945.Kernel.File.Attributes.set(.privateFile, at: path)
                do throws(ISO_9945.Kernel.File.Access.Error) {
                    let allowed = try ISO_9945.Kernel.File.Access.check(.execute, at: path)
                    #expect(!allowed)
                } catch {
                    #expect(error == .unsupported)
                }
            }
            _ = descriptor
        }
    }
#elseif os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux)
    extension ISO_9945.Kernel.File.Access.Test.Integration {
        @Test
        func `effective execute access allows an executable file`() throws {
            let path = KernelIOTest.makeTempPath(prefix: "effective-access-allowed")
            defer { KernelIOTest.cleanup(path: path) }
            let descriptor = try KernelIOTest.open(at: path)

            _ = try Path.scope(path) { path in
                try ISO_9945.Kernel.File.Attributes.set(.privateExecutable, at: path)
                let allowed = try ISO_9945.Kernel.File.Access.check(.execute, at: path)
                #expect(allowed)
            }
            _ = descriptor
        }

        @Test
        func `effective execute access denies a nonexecutable file`() throws {
            let path = KernelIOTest.makeTempPath(prefix: "effective-access-denied")
            defer { KernelIOTest.cleanup(path: path) }
            let descriptor = try KernelIOTest.open(at: path)

            _ = try Path.scope(path) { path in
                try ISO_9945.Kernel.File.Attributes.set(.privateFile, at: path)
                let allowed = try ISO_9945.Kernel.File.Access.check(.execute, at: path)
                #expect(!allowed)
            }
            _ = descriptor
        }

        @Test
        func `missing path reports a typed resolution error`() throws {
            let path = KernelIOTest.makeTempPath(prefix: "effective-access-missing")

            _ = try Path.scope(path) { path in
                #expect(throws: ISO_9945.Kernel.File.Access.Error.path(.notFound)) {
                    try ISO_9945.Kernel.File.Access.check(.execute, at: path)
                }
            }
        }
    }
#else
    extension ISO_9945.Kernel.File.Access.Test.Integration {
        @Test
        func `effective access reports typed unsupported result`() throws {
            _ = try Path.scope("effective-access-test") { path in
                #expect(throws: ISO_9945.Kernel.File.Access.Error.unsupported) {
                    try ISO_9945.Kernel.File.Access.check(.execute, at: path)
                }
            }
        }
    }
#endif

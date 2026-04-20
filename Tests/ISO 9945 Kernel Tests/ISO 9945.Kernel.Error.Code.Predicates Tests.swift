// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

import Testing

@testable import ISO_9945_Kernel

extension Kernel.Error.Code {
    @Suite
    struct Test {
        @Suite struct Unit {}
    }
}

// MARK: - Predicate Unit Tests (POSIX)

extension Kernel.Error.Code.Test.Unit {
    @Test("isNotFound matches ENOENT")
    func predicateIsNotFound() {
        #expect(Kernel.Error.Code.POSIX.ENOENT.isNotFound)
        #expect(!Kernel.Error.Code.POSIX.EACCES.isNotFound)
    }

    @Test("isPermissionDenied matches EACCES and EPERM")
    func predicateIsPermissionDenied() {
        #expect(Kernel.Error.Code.POSIX.EACCES.isPermissionDenied)
        #expect(Kernel.Error.Code.POSIX.EPERM.isPermissionDenied)
        #expect(!Kernel.Error.Code.POSIX.ENOENT.isPermissionDenied)
    }

    @Test("isAccessDenied trampolines to isPermissionDenied")
    func predicateIsAccessDenied() {
        #expect(Kernel.Error.Code.POSIX.EACCES.isAccessDenied)
        #expect(Kernel.Error.Code.POSIX.EPERM.isAccessDenied)
        #expect(!Kernel.Error.Code.POSIX.ENOENT.isAccessDenied)
    }

    @Test("isReadOnly matches EROFS")
    func predicateIsReadOnly() {
        #expect(Kernel.Error.Code.POSIX.EROFS.isReadOnly)
        #expect(!Kernel.Error.Code.POSIX.ENOENT.isReadOnly)
    }

    @Test("isNoSpace matches ENOSPC")
    func predicateIsNoSpace() {
        #expect(Kernel.Error.Code.POSIX.ENOSPC.isNoSpace)
        #expect(!Kernel.Error.Code.POSIX.ENOENT.isNoSpace)
    }

    @Test("isNotDirectory matches ENOTDIR")
    func predicateIsNotDirectory() {
        #expect(Kernel.Error.Code.POSIX.ENOTDIR.isNotDirectory)
        #expect(!Kernel.Error.Code.POSIX.ENOENT.isNotDirectory)
    }

    @Test("isInvalidPath returns false on POSIX (no distinct errno)")
    func predicateIsInvalidPath() {
        #expect(!Kernel.Error.Code.POSIX.ENOENT.isInvalidPath)
        #expect(!Kernel.Error.Code.POSIX.EACCES.isInvalidPath)
    }

    @Test("isNetworkNotFound returns false on POSIX (no distinct errno)")
    func predicateIsNetworkNotFound() {
        #expect(!Kernel.Error.Code.POSIX.ENOENT.isNetworkNotFound)
        #expect(!Kernel.Error.Code.POSIX.EACCES.isNetworkNotFound)
    }
}

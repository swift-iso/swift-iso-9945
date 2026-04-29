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

extension Error_Primitives.Error.Code {
    @Suite
    struct Test {
        @Suite struct Unit {}
    }
}

// MARK: - Predicate Unit Tests (POSIX)

extension Error_Primitives.Error.Code.Test.Unit {
    @Test
    func `isNotFound matches ENOENT`() {
        #expect(Error_Primitives.Error.Code.POSIX.ENOENT.isNotFound)
        #expect(!Error_Primitives.Error.Code.POSIX.EACCES.isNotFound)
    }

    @Test
    func `isPermissionDenied matches EACCES and EPERM`() {
        #expect(Error_Primitives.Error.Code.POSIX.EACCES.isPermissionDenied)
        #expect(Error_Primitives.Error.Code.POSIX.EPERM.isPermissionDenied)
        #expect(!Error_Primitives.Error.Code.POSIX.ENOENT.isPermissionDenied)
    }

    @Test
    func `isAccessDenied trampolines to isPermissionDenied`() {
        #expect(Error_Primitives.Error.Code.POSIX.EACCES.isAccessDenied)
        #expect(Error_Primitives.Error.Code.POSIX.EPERM.isAccessDenied)
        #expect(!Error_Primitives.Error.Code.POSIX.ENOENT.isAccessDenied)
    }

    @Test
    func `isReadOnly matches EROFS`() {
        #expect(Error_Primitives.Error.Code.POSIX.EROFS.isReadOnly)
        #expect(!Error_Primitives.Error.Code.POSIX.ENOENT.isReadOnly)
    }

    @Test
    func `isNoSpace matches ENOSPC`() {
        #expect(Error_Primitives.Error.Code.POSIX.ENOSPC.isNoSpace)
        #expect(!Error_Primitives.Error.Code.POSIX.ENOENT.isNoSpace)
    }

    @Test
    func `isNotDirectory matches ENOTDIR`() {
        #expect(Error_Primitives.Error.Code.POSIX.ENOTDIR.isNotDirectory)
        #expect(!Error_Primitives.Error.Code.POSIX.ENOENT.isNotDirectory)
    }

    @Test
    func `isInvalidPath returns false on POSIX (no distinct errno)`() {
        #expect(!Error_Primitives.Error.Code.POSIX.ENOENT.isInvalidPath)
        #expect(!Error_Primitives.Error.Code.POSIX.EACCES.isInvalidPath)
    }

    @Test
    func `isNetworkNotFound returns false on POSIX (no distinct errno)`() {
        #expect(!Error_Primitives.Error.Code.POSIX.ENOENT.isNetworkNotFound)
        #expect(!Error_Primitives.Error.Code.POSIX.EACCES.isNetworkNotFound)
    }
}

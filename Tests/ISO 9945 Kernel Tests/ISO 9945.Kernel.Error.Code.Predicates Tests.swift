import Tagged_Standard_Library_Integration
import Testing

@testable import ISO_9945_Kernel

extension Error.Error.Code {
    @Suite
    struct Test {
        @Suite struct Unit {}
    }
}

extension Error.Error.Code.Test.Unit {
    @Test
    func `isNotFound matches ENOENT`() {
        #expect(Error.Error.Code.POSIX.ENOENT.isNotFound)
        #expect(!Error.Error.Code.POSIX.EACCES.isNotFound)
    }

    @Test
    func `isPermissionDenied matches EACCES and EPERM`() {
        #expect(Error.Error.Code.POSIX.EACCES.isPermissionDenied)
        #expect(Error.Error.Code.POSIX.EPERM.isPermissionDenied)
        #expect(!Error.Error.Code.POSIX.ENOENT.isPermissionDenied)
    }

    @Test
    func `isAccessDenied trampolines to isPermissionDenied`() {
        #expect(Error.Error.Code.POSIX.EACCES.isAccessDenied)
        #expect(Error.Error.Code.POSIX.EPERM.isAccessDenied)
        #expect(!Error.Error.Code.POSIX.ENOENT.isAccessDenied)
    }

    @Test
    func `isReadOnly matches EROFS`() {
        #expect(Error.Error.Code.POSIX.EROFS.isReadOnly)
        #expect(!Error.Error.Code.POSIX.ENOENT.isReadOnly)
    }

    @Test
    func `isNoSpace matches ENOSPC`() {
        #expect(Error.Error.Code.POSIX.ENOSPC.isNoSpace)
        #expect(!Error.Error.Code.POSIX.ENOENT.isNoSpace)
    }

    @Test
    func `isNotDirectory matches ENOTDIR`() {
        #expect(Error.Error.Code.POSIX.ENOTDIR.isNotDirectory)
        #expect(!Error.Error.Code.POSIX.ENOENT.isNotDirectory)
    }

    @Test
    func `isInvalidPath returns false on POSIX (no distinct errno)`() {
        #expect(!Error.Error.Code.POSIX.ENOENT.isInvalidPath)
        #expect(!Error.Error.Code.POSIX.EACCES.isInvalidPath)
    }

    @Test
    func `isNetworkNotFound returns false on POSIX (no distinct errno)`() {
        #expect(!Error.Error.Code.POSIX.ENOENT.isNetworkNotFound)
        #expect(!Error.Error.Code.POSIX.EACCES.isNetworkNotFound)
    }
}

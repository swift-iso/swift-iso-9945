import Tagged
import Testing

@testable import ISO_9945_Kernel

extension Error::Error.Code {
    @Suite
    struct Test {
        @Suite struct Unit {}
    }
}

extension Error::Error.Code.Test.Unit {
    @Test
    func `isNotFound matches ENOENT`() {
        #expect(Error::Error.Code.ENOENT.isNotFound)
        #expect(!Error::Error.Code.EACCES.isNotFound)
    }

    @Test
    func `isPermissionDenied matches EACCES and EPERM`() {
        #expect(Error::Error.Code.EACCES.isPermissionDenied)
        #expect(Error::Error.Code.EPERM.isPermissionDenied)
        #expect(!Error::Error.Code.ENOENT.isPermissionDenied)
    }

    @Test
    func `isAccessDenied trampolines to isPermissionDenied`() {
        #expect(Error::Error.Code.EACCES.isAccessDenied)
        #expect(Error::Error.Code.EPERM.isAccessDenied)
        #expect(!Error::Error.Code.ENOENT.isAccessDenied)
    }

    @Test
    func `isReadOnly matches EROFS`() {
        #expect(Error::Error.Code.EROFS.isReadOnly)
        #expect(!Error::Error.Code.ENOENT.isReadOnly)
    }

    @Test
    func `isNoSpace matches ENOSPC`() {
        #expect(Error::Error.Code.ENOSPC.isNoSpace)
        #expect(!Error::Error.Code.ENOENT.isNoSpace)
    }

    @Test
    func `isNotDirectory matches ENOTDIR`() {
        #expect(Error::Error.Code.ENOTDIR.isNotDirectory)
        #expect(!Error::Error.Code.ENOENT.isNotDirectory)
    }

    @Test
    func `isInvalidPath returns false on POSIX (no distinct errno)`() {
        #expect(!Error::Error.Code.ENOENT.isInvalidPath)
        #expect(!Error::Error.Code.EACCES.isInvalidPath)
    }

    @Test
    func `isNetworkNotFound returns false on POSIX (no distinct errno)`() {
        #expect(!Error::Error.Code.ENOENT.isNetworkNotFound)
        #expect(!Error::Error.Code.EACCES.isNetworkNotFound)
    }
}

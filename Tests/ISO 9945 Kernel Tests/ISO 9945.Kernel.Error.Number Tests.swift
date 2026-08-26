import Error
import ISO_9945_Kernel_Test_Support
import Path
import Tagged_Standard_Library_Integration
import Testing

@testable import ISO_9945_Kernel

extension Error.Error.Number {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#elseif canImport(Musl)
    import Musl
#endif

extension Error.Error.Number.Test.Unit {
    @Test
    func `noEntry equals ENOENT`() {
        #expect(
            Error.Error.Number.noEntry
                == Error.Error.Number(_unchecked: ENOENT)
        )
    }

    @Test
    func `accessDenied equals EACCES`() {
        #expect(
            Error.Error.Number.accessDenied
                == Error.Error.Number(_unchecked: EACCES)
        )
    }

    @Test
    func `notPermitted equals EPERM`() {
        #expect(
            Error.Error.Number.notPermitted
                == Error.Error.Number(_unchecked: EPERM)
        )
    }

    @Test
    func `exists equals EEXIST`() {
        #expect(
            Error.Error.Number.exists
                == Error.Error.Number(_unchecked: EEXIST)
        )
    }

    @Test
    func `isDirectory equals EISDIR`() {
        #expect(
            Error.Error.Number.isDirectory
                == Error.Error.Number(_unchecked: EISDIR)
        )
    }

    @Test
    func `processLimit equals EMFILE`() {
        #expect(
            Error.Error.Number.processLimit
                == Error.Error.Number(_unchecked: EMFILE)
        )
    }

    @Test
    func `systemLimit equals ENFILE`() {
        #expect(
            Error.Error.Number.systemLimit
                == Error.Error.Number(_unchecked: ENFILE)
        )
    }

    @Test
    func `invalid equals EINVAL`() {
        #expect(
            Error.Error.Number.invalid
                == Error.Error.Number(_unchecked: EINVAL)
        )
    }

    @Test
    func `interrupted equals EINTR`() {
        #expect(
            Error.Error.Number.interrupted
                == Error.Error.Number(_unchecked: EINTR)
        )
    }

    @Test
    func `wouldBlock equals EAGAIN`() {
        #expect(
            Error.Error.Number.wouldBlock
                == Error.Error.Number(_unchecked: EAGAIN)
        )
    }

    @Test
    func `inProgress equals EINPROGRESS and classifies its code`() {
        let number = Error.Error.Number.inProgress
        #expect(number == Error.Error.Number(_unchecked: EINPROGRESS))
        #expect(Error.Error.Code.posix(number.underlying).isInProgress)
        #expect(!Error.Error.Code.POSIX.EINTR.isInProgress)
    }

    @Test
    func `noDevice equals ENODEV`() {
        #expect(
            Error.Error.Number.noDevice
                == Error.Error.Number(_unchecked: ENODEV)
        )
    }

    @Test
    func `notDirectory equals ENOTDIR`() {
        #expect(
            Error.Error.Number.notDirectory
                == Error.Error.Number(_unchecked: ENOTDIR)
        )
    }

    @Test
    func `readOnlyFilesystem equals EROFS`() {
        #expect(
            Error.Error.Number.readOnlyFilesystem
                == Error.Error.Number(_unchecked: EROFS)
        )
    }

    @Test
    func `noSpace equals ENOSPC`() {
        #expect(
            Error.Error.Number.noSpace
                == Error.Error.Number(_unchecked: ENOSPC)
        )
    }

    @Test
    func `badDescriptor equals EBADF`() {
        #expect(
            Error.Error.Number.badDescriptor
                == Error.Error.Number(_unchecked: EBADF)
        )
    }
}

extension Error.Error.Number.Test.Unit {
    @Test
    func `all error number values are distinct`() {
        let values: [Error.Error.Number] = [
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
        #expect(Error.Error.Number.noEntry > 0)
        #expect(Error.Error.Number.accessDenied > 0)
        #expect(Error.Error.Number.notPermitted > 0)
        #expect(Error.Error.Number.exists > 0)
        #expect(Error.Error.Number.invalid > 0)
        #expect(Error.Error.Number.interrupted > 0)
        #expect(Error.Error.Number.badDescriptor > 0)
    }
}

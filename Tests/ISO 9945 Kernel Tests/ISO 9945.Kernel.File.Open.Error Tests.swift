@_spi(Syscall) import ISO_9945_Kernel
import Tagged_Standard_Library_Integration
import Testing

extension ISO_9945.Kernel.File.Open.Error {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

extension ISO_9945.Kernel.File.Open.Error.Test.Unit {
    @Test
    func `path case stores Path.Resolution.Error`() {
        let pathError = Path.Resolution.Error.notFound
        let error = ISO_9945.Kernel.File.Open.Error.path(pathError)
        if case .path(let stored) = error {
            #expect(stored == pathError)
        } else {
            Issue.record("Expected .path case")
        }
    }

    @Test
    func `handle case stores Descriptor.Validity.Error`() {
        let handleError = ISO_9945.Kernel.Descriptor.Validity.Error.invalid
        let error = ISO_9945.Kernel.File.Open.Error.handle(handleError)
        if case .handle(let stored) = error {
            #expect(stored == handleError)
        } else {
            Issue.record("Expected .handle case")
        }
    }

    @Test
    func `platform case stores Error.Error`() {
        let code = Error.Error.Code.posix(999)
        let unmappedError = Error.Error(code: code)
        let error = ISO_9945.Kernel.File.Open.Error.platform(unmappedError)
        if case .platform(let stored) = error {
            #expect(stored == unmappedError)
        } else {
            Issue.record("Expected .platform case")
        }
    }
}

extension ISO_9945.Kernel.File.Open.Error.Test.Unit {
    @Test
    func `path description format`() {
        let error = ISO_9945.Kernel.File.Open.Error.path(.notFound)
        #expect(error.description.contains("path:"))
    }

    @Test
    func `handle description format`() {
        let error = ISO_9945.Kernel.File.Open.Error.handle(.invalid)
        #expect(error.description.contains("handle:"))
    }
}

extension ISO_9945.Kernel.File.Open.Error.Test.Unit {
    @Test
    func `Error conforms to Swift.Error`() {
        let error: any Swift.Error = ISO_9945.Kernel.File.Open.Error.path(.notFound)
        #expect(error is ISO_9945.Kernel.File.Open.Error)
    }

    @Test
    func `Error is Sendable`() {
        let error: any Sendable = ISO_9945.Kernel.File.Open.Error.path(.notFound)
        #expect(error is ISO_9945.Kernel.File.Open.Error)
    }

    @Test
    func `Error is Equatable`() {
        let a = ISO_9945.Kernel.File.Open.Error.path(.notFound)
        let b = ISO_9945.Kernel.File.Open.Error.path(.notFound)
        let c = ISO_9945.Kernel.File.Open.Error.path(.exists)
        #expect(a == b)
        #expect(a != c)
    }
}

extension ISO_9945.Kernel.File.Open.Error.Test.EdgeCase {
    @Test
    func `all cases are distinct`() {
        let cases: [ISO_9945.Kernel.File.Open.Error] = [
            .path(.notFound),
            .handle(.invalid),
            .platform(Error.Error(code: .posix(1))),
        ]

        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }

    @Test
    func `path resolution cases are distinct`() {
        let notFound = ISO_9945.Kernel.File.Open.Error.path(.notFound)
        let exists = ISO_9945.Kernel.File.Open.Error.path(.exists)
        let isDirectory = ISO_9945.Kernel.File.Open.Error.path(.isDirectory)
        #expect(notFound != exists)
        #expect(exists != isDirectory)
    }
}

#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#elseif canImport(Musl)
    import Musl
#endif

extension ISO_9945.Kernel.File.Open.Error.Test.Unit {
    @Test
    func `permission-classed code (EACCES) folds into platform`() {
        let error = ISO_9945.Kernel.File.Open.Error(code: .posix(EACCES))
        if case .platform = error {

        } else {
            Issue.record("Expected .platform case for EACCES")
        }
    }

    @Test
    func `space-classed code (ENOSPC) folds into platform`() {
        let error = ISO_9945.Kernel.File.Open.Error(code: .posix(ENOSPC))
        if case .platform = error {

        } else {
            Issue.record("Expected .platform case for ENOSPC")
        }
    }

    @Test
    func `io-classed code (EIO) folds into platform`() {
        let error = ISO_9945.Kernel.File.Open.Error(code: .posix(EIO))
        if case .platform = error {

        } else {
            Issue.record("Expected .platform case for EIO")
        }
    }
}

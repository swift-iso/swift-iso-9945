import ISO_9945_Kernel
import Tagged_Primitives_Standard_Library_Integration
import Testing

extension ISO_9945.Kernel.IO.Read.Error {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

extension ISO_9945.Kernel.IO.Read.Error.Test.Unit {
    @Test
    func `handle case stores Descriptor.Validity.Error`() {
        let validityError = ISO_9945.Kernel.Descriptor.Validity.Error.invalid
        let error = ISO_9945.Kernel.IO.Read.Error.handle(validityError)
        if case .handle(let stored) = error {
            #expect(stored == validityError)
        } else {
            Issue.record("Expected .handle case")
        }
    }

    @Test
    func `blocking case stores IO.Blocking.Error`() {
        let blockingError = ISO_9945.Kernel.IO.Blocking.Error.wouldBlock
        let error = ISO_9945.Kernel.IO.Read.Error.blocking(blockingError)
        if case .blocking(let stored) = error {
            #expect(stored == blockingError)
        } else {
            Issue.record("Expected .blocking case")
        }
    }

    @Test
    func `platform case stores Error_Primitives.Error`() {
        let code = Error_Primitives.Error.Code.posix(999)
        let unmappedError = Error_Primitives.Error(code: code)
        let error = ISO_9945.Kernel.IO.Read.Error.platform(unmappedError)
        if case .platform(let stored) = error {
            #expect(stored == unmappedError)
        } else {
            Issue.record("Expected .platform case")
        }
    }
}

extension ISO_9945.Kernel.IO.Read.Error.Test.Unit {
    @Test
    func `handle description format`() {
        let error = ISO_9945.Kernel.IO.Read.Error.handle(.invalid)
        #expect(error.description.contains("handle:"))
    }

    @Test
    func `blocking description format`() {
        let error = ISO_9945.Kernel.IO.Read.Error.blocking(.wouldBlock)
        #expect(error.description.contains("blocking:"))
    }
}

extension ISO_9945.Kernel.IO.Read.Error.Test.Unit {
    @Test
    func `Error conforms to Swift.Error`() {
        let error: any Swift.Error = ISO_9945.Kernel.IO.Read.Error.handle(.invalid)
        #expect(error is ISO_9945.Kernel.IO.Read.Error)
    }

    @Test
    func `Error is Sendable`() {
        let error: any Sendable = ISO_9945.Kernel.IO.Read.Error.handle(.invalid)
        #expect(error is ISO_9945.Kernel.IO.Read.Error)
    }

    @Test
    func `Error is Equatable - same case same value`() {
        let a = ISO_9945.Kernel.IO.Read.Error.handle(.invalid)
        let b = ISO_9945.Kernel.IO.Read.Error.handle(.invalid)
        #expect(a == b)
    }

    @Test
    func `Error is Equatable - same case different value`() {
        let a = ISO_9945.Kernel.IO.Read.Error.handle(.invalid)
        let b = ISO_9945.Kernel.IO.Read.Error.handle(.limit(.process))
        #expect(a != b)
    }

    @Test
    func `Error is Equatable - different cases`() {
        let a = ISO_9945.Kernel.IO.Read.Error.handle(.invalid)
        let b = ISO_9945.Kernel.IO.Read.Error.blocking(.wouldBlock)
        #expect(a != b)
    }
}

extension ISO_9945.Kernel.IO.Read.Error.Test.EdgeCase {
    @Test
    func `all cases are distinct`() {
        let cases: [ISO_9945.Kernel.IO.Read.Error] = [
            .handle(.invalid),
            .blocking(.wouldBlock),
            .platform(Error_Primitives.Error(code: .posix(1))),
        ]

        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }
}

#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#elseif canImport(Musl)
    import Musl
#endif

extension ISO_9945.Kernel.IO.Read.Error.Test.Unit {
    @Test
    func `broken-classed code (EPIPE) folds into platform`() {
        let error = ISO_9945.Kernel.IO.Read.Error(code: .posix(EPIPE))
        if case .platform = error {

        } else {
            Issue.record("Expected .platform case for EPIPE")
        }
    }

    @Test
    func `reset-classed code (ECONNRESET) folds into platform`() {
        let error = ISO_9945.Kernel.IO.Read.Error(code: .posix(ECONNRESET))
        if case .platform = error {

        } else {
            Issue.record("Expected .platform case for ECONNRESET")
        }
    }

    @Test
    func `hardware-classed code (EIO) folds into platform`() {
        let error = ISO_9945.Kernel.IO.Read.Error(code: .posix(EIO))
        if case .platform = error {

        } else {
            Issue.record("Expected .platform case for EIO")
        }
    }
}

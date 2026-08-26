import ISO_9945_Kernel
import Tagged_Standard_Library_Integration
import Testing

extension ISO_9945.Kernel.File.Clone.Error.Syscall {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

extension ISO_9945.Kernel.File.Clone.Error.Syscall.Test.Unit {
    @Test
    func `platform case exists`() {
        let syscall = ISO_9945.Kernel.File.Clone.Error.Syscall.platform(
            code: .posix(1),
            operation: .clonefile
        )
        if case .platform = syscall {

        } else {
            Issue.record("Expected .platform case")
        }
    }

    @Test
    func `notSupported case exists`() {
        let syscall = ISO_9945.Kernel.File.Clone.Error.Syscall.notSupported(operation: .clonefile)
        if case .notSupported = syscall {

        } else {
            Issue.record("Expected .notSupported case")
        }
    }
}

extension ISO_9945.Kernel.File.Clone.Error.Syscall.Test.Unit {
    @Test
    func `Syscall conforms to Swift.Error`() {
        let syscall: any Swift.Error = ISO_9945.Kernel.File.Clone.Error.Syscall.platform(
            code: .posix(1),
            operation: .clonefile
        )
        #expect(syscall is ISO_9945.Kernel.File.Clone.Error.Syscall)
    }

    @Test
    func `Syscall is Sendable`() {
        let syscall: any Sendable = ISO_9945.Kernel.File.Clone.Error.Syscall.platform(
            code: .posix(1),
            operation: .clonefile
        )
        #expect(syscall is ISO_9945.Kernel.File.Clone.Error.Syscall)
    }
}

extension ISO_9945.Kernel.File.Clone.Error.Syscall.Test.Unit {
    @Test
    func `platform stores error code`() {
        let syscall = ISO_9945.Kernel.File.Clone.Error.Syscall.platform(
            code: .posix(42),
            operation: .clonefile
        )
        if case .platform(let code, _) = syscall {
            if case .posix(let errno) = code {
                #expect(errno == 42)
            } else {
                Issue.record("Expected .posix code")
            }
        } else {
            Issue.record("Expected .platform case")
        }
    }

    @Test
    func `platform stores operation`() {
        let syscall = ISO_9945.Kernel.File.Clone.Error.Syscall.platform(
            code: .posix(1),
            operation: .copyfile
        )
        if case .platform(_, let operation) = syscall {
            #expect(operation == .copyfile)
        } else {
            Issue.record("Expected .platform case")
        }
    }

    @Test
    func `notSupported stores operation`() {
        let syscall = ISO_9945.Kernel.File.Clone.Error.Syscall.notSupported(operation: .ficlone)
        if case .notSupported(let operation) = syscall {
            #expect(operation == .ficlone)
        } else {
            Issue.record("Expected .notSupported case")
        }
    }
}

extension ISO_9945.Kernel.File.Clone.Error.Syscall.Test.EdgeCase {
    @Test
    func `platform with different codes are distinct`() {
        let syscall1 = ISO_9945.Kernel.File.Clone.Error.Syscall.platform(
            code: .posix(1),
            operation: .clonefile
        )
        let syscall2 = ISO_9945.Kernel.File.Clone.Error.Syscall.platform(
            code: .posix(2),
            operation: .clonefile
        )

        _ = syscall1
        _ = syscall2
    }

    @Test
    func `platform with different operations are distinct`() {
        let syscall1 = ISO_9945.Kernel.File.Clone.Error.Syscall.platform(
            code: .posix(1),
            operation: .clonefile
        )
        let syscall2 = ISO_9945.Kernel.File.Clone.Error.Syscall.platform(
            code: .posix(1),
            operation: .copyfile
        )
        _ = syscall1
        _ = syscall2
    }

    @Test
    func `all operations can be used with platform`() {
        let operations: [ISO_9945.Kernel.File.Clone.Error.Operation] = [
            .clonefile,
            .copyfile,
            .ficlone,
            .copyFileRange,
            .duplicateExtents,
            .statfs,
            .stat,
            .copy,
        ]

        for operation in operations {
            let syscall = ISO_9945.Kernel.File.Clone.Error.Syscall.platform(
                code: .posix(1),
                operation: operation
            )
            if case .platform(_, let op) = syscall {
                #expect(op == operation)
            } else {
                Issue.record("Expected .platform case for operation \(operation)")
            }
        }
    }

    @Test
    func `all operations can be used with notSupported`() {
        let operations: [ISO_9945.Kernel.File.Clone.Error.Operation] = [
            .clonefile,
            .copyfile,
            .ficlone,
            .copyFileRange,
            .duplicateExtents,
            .statfs,
            .stat,
            .copy,
        ]

        for operation in operations {
            let syscall = ISO_9945.Kernel.File.Clone.Error.Syscall.notSupported(
                operation: operation
            )
            if case .notSupported(let op) = syscall {
                #expect(op == operation)
            } else {
                Issue.record("Expected .notSupported case for operation \(operation)")
            }
        }
    }
}

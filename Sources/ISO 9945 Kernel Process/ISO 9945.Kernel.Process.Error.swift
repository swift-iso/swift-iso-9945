#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#elseif canImport(Musl)
    import Musl
#endif

extension ISO_9945.Kernel.Process {

    public enum Error: Swift.Error, Sendable, Equatable, Hashable {

        case fork(Error_Primitives.Error.Code)

        case execute(Error_Primitives.Error.Code)

        case wait(Error_Primitives.Error.Code)

        case kill(Error_Primitives.Error.Code)

        case session(Error_Primitives.Error.Code)

        case group(Error_Primitives.Error.Code)

        case spawn(Error_Primitives.Error.Code)
    }
}

extension ISO_9945.Kernel.Process.Error {

    public var code: Error_Primitives.Error.Code {
        switch self {
        case .fork(let c), .execute(let c), .wait(let c), .kill(let c),
            .session(let c), .group(let c), .spawn(let c):
            return c
        }
    }

    public var isInterrupted: Bool {
        code.isInterrupted
    }

    public var semantic: Semantic? {
        guard let posix = code.posix else { return nil }
        switch posix {
        case EAGAIN, ENOMEM:
            return .resourceLimit

        case EPERM:
            return .noPermission

        case ESRCH, ECHILD:
            return .noSuchProcess

        case EINTR:
            return .interrupted

        case EINVAL:
            return .invalidArgument

        default:
            return nil
        }
    }
}

extension ISO_9945.Kernel.Process.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .fork(let code):
            return "fork failed: \(code)"

        case .execute(let code):
            return "execute failed: \(code)"

        case .wait(let code):
            return "wait failed: \(code)"

        case .kill(let code):
            return "kill failed: \(code)"

        case .session(let code):
            return "session operation failed: \(code)"

        case .group(let code):
            return "process group operation failed: \(code)"

        case .spawn(let code):
            return "spawn failed: \(code)"
        }
    }
}

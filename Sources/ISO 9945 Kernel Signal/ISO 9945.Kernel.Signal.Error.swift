#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Signal {

    public enum Error: Swift.Error, Sendable, Equatable, Hashable {

        case interrupted

        case set(Error_Primitives.Error.Code)

        case mask(Error_Primitives.Error.Code)

        case action(Error_Primitives.Error.Code)

        case send(Error_Primitives.Error.Code)
    }
}

extension ISO_9945.Kernel.Signal.Error {

    public init?(code: Error_Primitives.Error.Code) {
        guard case .posix(let errno) = code else { return nil }
        switch errno {
        case EINTR:
            self = .interrupted

        default:
            return nil
        }
    }
}

extension ISO_9945.Kernel.Signal.Error {

    public var code: Error_Primitives.Error.Code? {
        switch self {
        case .interrupted:
            return nil

        case .set(let c), .mask(let c), .action(let c), .send(let c):
            return c
        }
    }

    public var isInterrupted: Bool {
        if case .interrupted = self { return true }
        if let code, code.isInterrupted { return true }
        return false
    }

    public var semantic: Semantic? {
        if case .interrupted = self { return .interrupted }
        guard let posix = code?.posix else { return nil }
        switch posix {
        case EINVAL: return .invalidSignal
        case EPERM: return .noPermission
        case ESRCH: return .noSuchProcess
        case EINTR: return .interrupted
        default: return nil
        }
    }
}

extension ISO_9945.Kernel.Signal.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .interrupted:
            return "interrupted by signal"

        case .set(let code):
            return "signal set operation failed: \(code)"

        case .mask(let code):
            return "signal mask operation failed: \(code)"

        case .action(let code):
            return "signal action operation failed: \(code)"

        case .send(let code):
            return "signal send operation failed: \(code)"
        }
    }
}

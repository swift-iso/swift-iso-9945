#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Socket.Address.Info {

    public enum Error: Swift.Error, Sendable, Equatable, Hashable {

        case again

        case badFlags

        case fail

        case family

        case memory

        case noName

        case overflow

        case service

        case socketType

        case system(Error_Primitives.Error.Code)

        case unknown(Int32)
    }
}

extension ISO_9945.Kernel.Socket.Address.Info.Error {

    public init(code: Int32) {
        switch code {
        case EAI_AGAIN: self = .again
        case EAI_BADFLAGS: self = .badFlags
        case EAI_FAIL: self = .fail
        case EAI_FAMILY: self = .family
        case EAI_MEMORY: self = .memory
        case EAI_NONAME: self = .noName
        case EAI_OVERFLOW: self = .overflow
        case EAI_SERVICE: self = .service
        case EAI_SOCKTYPE: self = .socketType
        case EAI_SYSTEM: self = .system(.captureErrno())
        default: self = .unknown(code)
        }
    }

    public var code: Int32 {
        switch self {
        case .again: EAI_AGAIN
        case .badFlags: EAI_BADFLAGS
        case .fail: EAI_FAIL
        case .family: EAI_FAMILY
        case .memory: EAI_MEMORY
        case .noName: EAI_NONAME
        case .overflow: EAI_OVERFLOW
        case .service: EAI_SERVICE
        case .socketType: EAI_SOCKTYPE
        case .system: EAI_SYSTEM
        case .unknown(let code): code
        }
    }
}

extension ISO_9945.Kernel.Socket.Address.Info.Error {

    public var message: String {
        guard let text = unsafe gai_strerror(code) else {
            return "Unknown host-resolution error \(code)"
        }
        return unsafe String(cString: text)
    }
}

extension ISO_9945.Kernel.Socket.Address.Info.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .system(let errno): "\(message): \(errno)"
        default: message
        }
    }
}

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Signal {

    public enum Action {}
}

extension ISO_9945.Kernel.Signal.Action {

    @discardableResult

    @unsafe
    public static func set(
        signal: ISO_9945.Kernel.Signal.Number,
        _ configuration: Configuration
    ) throws(ISO_9945.Kernel.Signal.Error) -> Configuration {
        var newAction = unsafe sigaction(configuration)
        var oldAction = sigaction()

        guard unsafe sigaction(signal.rawValue, &newAction, &oldAction) == 0 else {
            throw .action(Error.Error.captureErrno())
        }

        return unsafe Configuration(oldAction)
    }

    @unsafe
    public static func get(
        signal: ISO_9945.Kernel.Signal.Number
    ) throws(ISO_9945.Kernel.Signal.Error) -> Configuration {
        var action = sigaction()

        guard unsafe sigaction(signal.rawValue, nil, &action) == 0 else {
            throw .action(Error.Error.captureErrno())
        }

        return unsafe Configuration(action)
    }
}

extension sigaction {

    @unsafe
    internal init(_ configuration: ISO_9945.Kernel.Signal.Action.Configuration) {
        self.init()

        self.sa_mask = configuration.mask.storage

        self.sa_flags = configuration.flags.rawValue

        #if canImport(Darwin)
            switch unsafe configuration.handler {
            case .default:
                unsafe (self.__sigaction_u.__sa_handler = SIG_DFL)

            case .ignore:
                unsafe (self.__sigaction_u.__sa_handler = SIG_IGN)

            case .custom(let handler):
                unsafe (self.__sigaction_u.__sa_handler = handler)

            case .customInfo(let handler):
                unsafe (self.__sigaction_u.__sa_sigaction = handler)
            }
        #elseif canImport(Glibc)
            switch unsafe configuration.handler {
            case .default:
                unsafe (self.__sigaction_handler.sa_handler = SIG_DFL)

            case .ignore:
                unsafe (self.__sigaction_handler.sa_handler = SIG_IGN)

            case .custom(let handler):
                unsafe (self.__sigaction_handler.sa_handler = handler)

            case .customInfo(let handler):
                unsafe (self.__sigaction_handler.sa_sigaction = handler)
            }
        #elseif canImport(Musl)
            switch unsafe configuration.handler {
            case .default:
                unsafe (self.sa_handler = SIG_DFL)

            case .ignore:
                unsafe (self.sa_handler = SIG_IGN)

            case .custom(let handler):
                unsafe (self.sa_handler = handler)

            case .customInfo(let handler):
                unsafe (self.sa_sigaction = handler)
            }
        #endif
    }
}

extension ISO_9945.Kernel.Signal.Action.Configuration {

    @unsafe
    internal init(_ action: sigaction) {
        let flags = ISO_9945.Kernel.Signal.Action.Options(rawValue: action.sa_flags)
        let mask = ISO_9945.Kernel.Signal.Set(storage: action.sa_mask)

        let handler: ISO_9945.Kernel.Signal.Action.Handler

        #if canImport(Darwin)
            let handlerPtr = unsafe action.__sigaction_u.__sa_handler
            let sigactionPtr = unsafe action.__sigaction_u.__sa_sigaction
        #elseif canImport(Glibc)
            let handlerPtr = unsafe action.__sigaction_handler.sa_handler
            let sigactionPtr = unsafe action.__sigaction_handler.sa_sigaction
        #elseif canImport(Musl)
            let handlerPtr = unsafe action.sa_handler
            let sigactionPtr = unsafe action.sa_sigaction
        #endif

        let sigDflRaw = unsafe unsafeBitCast(SIG_DFL, to: Int.self)
        let sigIgnRaw = unsafe unsafeBitCast(SIG_IGN, to: Int.self)

        if flags.contains(.sigInfo) {

            let handlerRaw = unsafe unsafeBitCast(sigactionPtr, to: Int.self)
            if handlerRaw == sigDflRaw {
                unsafe (handler = .default)
            } else if handlerRaw == sigIgnRaw {
                unsafe (handler = .ignore)
            } else if let ptr = unsafe sigactionPtr {
                unsafe (handler = .customInfo(ptr))
            } else {

                unsafe (handler = .default)
            }
        } else {

            let handlerRaw = unsafe unsafeBitCast(handlerPtr, to: Int.self)

            if handlerRaw == sigDflRaw {
                unsafe (handler = .default)
            } else if handlerRaw == sigIgnRaw {
                unsafe (handler = .ignore)
            } else if let ptr = handlerPtr {
                unsafe (handler = .custom(ptr))
            } else {
                unsafe (handler = .default)
            }
        }

        unsafe self.init(__unchecked: (), handler: handler, mask: mask, flags: flags)
    }
}

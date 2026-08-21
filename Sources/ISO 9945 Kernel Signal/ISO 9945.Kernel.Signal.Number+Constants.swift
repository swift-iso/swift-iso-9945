#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#elseif canImport(Musl)
    import Musl
#endif

extension ISO_9945.Kernel.Signal.Number {

    public static let hangup = Self(rawValue: SIGHUP)

    public static let interrupt = Self(rawValue: SIGINT)

    public static let quit = Self(rawValue: SIGQUIT)

    public static let illegal = Self(rawValue: SIGILL)

    public static let trap = Self(rawValue: SIGTRAP)

    public static let abort = Self(rawValue: SIGABRT)

    public static let bus = Self(rawValue: SIGBUS)

    public static let floatingPoint = Self(rawValue: SIGFPE)

    public static let kill = Self(rawValue: SIGKILL)

    public static let user1 = Self(rawValue: SIGUSR1)

    public static let segmentation = Self(rawValue: SIGSEGV)

    public static let user2 = Self(rawValue: SIGUSR2)

    public static let pipe = Self(rawValue: SIGPIPE)

    public static let alarm = Self(rawValue: SIGALRM)

    public static let terminate = Self(rawValue: SIGTERM)

    public static let child = Self(rawValue: SIGCHLD)

    public static let `continue` = Self(rawValue: SIGCONT)

    public static let stop = Self(rawValue: SIGSTOP)

    public static let terminalStop = Self(rawValue: SIGTSTP)

    public static let terminalInput = Self(rawValue: SIGTTIN)

    public static let terminalOutput = Self(rawValue: SIGTTOU)

    public static let urgent = Self(rawValue: SIGURG)

    public static let cpuLimit = Self(rawValue: SIGXCPU)

    public static let fileLimit = Self(rawValue: SIGXFSZ)

    public static let virtualAlarm = Self(rawValue: SIGVTALRM)

    public static let profiling = Self(rawValue: SIGPROF)

    public static let windowChange = Self(rawValue: SIGWINCH)

    public static let io = Self(rawValue: SIGIO)
}

extension ISO_9945.Kernel.Signal.Number: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .hangup: return "SIGHUP"
        case .interrupt: return "SIGINT"
        case .quit: return "SIGQUIT"
        case .illegal: return "SIGILL"
        case .trap: return "SIGTRAP"
        case .abort: return "SIGABRT"
        case .bus: return "SIGBUS"
        case .floatingPoint: return "SIGFPE"
        case .kill: return "SIGKILL"
        case .user1: return "SIGUSR1"
        case .segmentation: return "SIGSEGV"
        case .user2: return "SIGUSR2"
        case .pipe: return "SIGPIPE"
        case .alarm: return "SIGALRM"
        case .terminate: return "SIGTERM"
        case .child: return "SIGCHLD"
        case .continue: return "SIGCONT"
        case .stop: return "SIGSTOP"
        case .terminalStop: return "SIGTSTP"
        case .terminalInput: return "SIGTTIN"
        case .terminalOutput: return "SIGTTOU"
        case .urgent: return "SIGURG"
        case .cpuLimit: return "SIGXCPU"
        case .fileLimit: return "SIGXFSZ"
        case .virtualAlarm: return "SIGVTALRM"
        case .profiling: return "SIGPROF"
        case .windowChange: return "SIGWINCH"
        case .io: return "SIGIO"
        default: return "signal(\(rawValue))"
        }
    }
}

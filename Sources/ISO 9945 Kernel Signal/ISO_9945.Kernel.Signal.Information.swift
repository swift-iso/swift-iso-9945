#if canImport(Darwin)
    public import Darwin
#elseif canImport(Glibc)
    public import Glibc
#elseif canImport(Musl)
    public import Musl
#endif

extension ISO_9945.Kernel.Signal {

    @safe
    public struct Information: @unchecked Sendable {
        internal var cValue: siginfo_t

        public init() {
            unsafe (self.cValue = siginfo_t())
        }

        @_spi(Syscall)
        @unsafe
        public init(pointee: siginfo_t) {
            unsafe (self.cValue = pointee)
        }
    }
}

extension ISO_9945.Kernel.Signal.Information {

    public var number: ISO_9945.Kernel.Signal.Number {
        ISO_9945.Kernel.Signal.Number(rawValue: unsafe cValue.si_signo)
    }

    public var sender: ISO_9945.Kernel.Process.ID? {
        let signo = unsafe cValue.si_signo
        let code = unsafe cValue.si_code

        let isUserOrQueue = code == Int32(SI_USER) || code == Int32(SI_QUEUE)
        var isChildCode = false
        if signo == Int32(SIGCHLD) {
            switch code {
            case Int32(CLD_EXITED), Int32(CLD_KILLED), Int32(CLD_DUMPED), Int32(CLD_TRAPPED),
                Int32(CLD_STOPPED), Int32(CLD_CONTINUED):
                isChildCode = true

            default:
                isChildCode = false
            }
        }

        guard isUserOrQueue || isChildCode else { return nil }

        #if canImport(Darwin)

            return ISO_9945.Kernel.Process.ID(rawValue: unsafe cValue.si_pid)
        #elseif canImport(Glibc)

            if isUserOrQueue {
                return ISO_9945.Kernel.Process.ID(rawValue: unsafe cValue._sifields._kill.si_pid)
            } else {
                return ISO_9945.Kernel.Process.ID(rawValue: unsafe cValue._sifields._sigchld.si_pid)
            }
        #elseif canImport(Musl)

            return ISO_9945.Kernel.Process.ID(
                rawValue: unsafe cValue.__si_fields.__si_common.__first.__piduid.si_pid
            )
        #endif
    }

    public var fault: UInt? {
        let signo = unsafe cValue.si_signo
        let code = unsafe cValue.si_code

        let matches: Bool
        switch signo {
        case Int32(SIGSEGV):
            switch code {
            case Int32(SEGV_MAPERR), Int32(SEGV_ACCERR): matches = true
            default: matches = false
            }

        case Int32(SIGBUS):
            switch code {
            case Int32(BUS_ADRALN), Int32(BUS_ADRERR), Int32(BUS_OBJERR): matches = true
            default: matches = false
            }

        case Int32(SIGILL):
            switch code {
            case Int32(ILL_ILLOPC), Int32(ILL_ILLTRP), Int32(ILL_PRVOPC), Int32(ILL_PRVREG),
                Int32(ILL_COPROC), Int32(ILL_BADSTK):
                matches = true

            default: matches = false
            }

        case Int32(SIGFPE):
            switch code {
            case Int32(FPE_INTDIV), Int32(FPE_INTOVF), Int32(FPE_FLTDIV), Int32(FPE_FLTOVF),
                Int32(FPE_FLTUND), Int32(FPE_FLTRES), Int32(FPE_FLTINV), Int32(FPE_FLTSUB):
                matches = true

            default: matches = false
            }

        default:
            matches = false
        }

        guard matches else { return nil }

        #if canImport(Darwin)
            guard let address = unsafe cValue.si_addr else { return nil }
            return UInt(bitPattern: address)
        #elseif canImport(Glibc)
            guard let address = unsafe cValue._sifields._sigfault.si_addr else { return nil }
            return UInt(bitPattern: address)
        #elseif canImport(Musl)
            guard let address = unsafe cValue.__si_fields.__sigfault.si_addr else { return nil }
            return UInt(bitPattern: address)
        #endif
    }
}

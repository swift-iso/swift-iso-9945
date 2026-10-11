#if canImport(Darwin)
    public import Darwin
#elseif canImport(Glibc)
    public import Glibc
#elseif canImport(Musl)
    public import Musl
#endif

extension ISO_9945.Kernel.Signal.Action {

    @unsafe
    public enum Handler: Sendable {

        case `default`

        case ignore

        case custom(@convention(c) (Int32) -> Void)

        case customInfo(
            @convention(c) (Int32, UnsafeMutablePointer<siginfo_t>?, UnsafeMutableRawPointer?) ->
                Void
        )
    }
}

extension ISO_9945.Kernel.Signal.Action.Handler {

    internal var requiresSigInfo: Bool {
        if case .customInfo = unsafe self { return true }
        return false
    }
}

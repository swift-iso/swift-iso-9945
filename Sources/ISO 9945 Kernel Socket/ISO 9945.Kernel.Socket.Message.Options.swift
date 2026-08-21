#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#elseif canImport(Android)
    internal import Android
#else
    #error(
        "ISO_9945.Kernel.Socket.Message.Options: unsupported platform (no Darwin, Glibc, Musl, or Android)"
    )
#endif

extension ISO_9945.Kernel.Socket.Message.Options {

    public static let outOfBand = Self(rawValue: Int32(MSG_OOB))

    public static let peek = Self(rawValue: Int32(MSG_PEEK))

    public static let waitAll = Self(rawValue: Int32(MSG_WAITALL))

    public static let endOfRecord = Self(rawValue: Int32(MSG_EOR))

    public static let dontRoute = Self(rawValue: Int32(MSG_DONTROUTE))

    public static let truncate = Self(rawValue: Int32(MSG_TRUNC))

    public static let controlTruncate = Self(rawValue: Int32(MSG_CTRUNC))

    public static let dontWait = Self(rawValue: Int32(MSG_DONTWAIT))

    #if canImport(Glibc) || canImport(Musl) || canImport(Android)
        public static let noSignal = Self(rawValue: Int32(MSG_NOSIGNAL))
    #endif
}

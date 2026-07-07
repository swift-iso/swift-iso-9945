#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX Socket Message Flags

extension ISO_9945.Kernel.Socket.Message.Options {
    /// Send or receive out-of-band data (MSG_OOB).
    public static let outOfBand = Self(rawValue: Int32(MSG_OOB))

    /// Peek at incoming data without consuming it (MSG_PEEK).
    public static let peek = Self(rawValue: Int32(MSG_PEEK))

    /// Wait for the full request or an error (MSG_WAITALL).
    public static let waitAll = Self(rawValue: Int32(MSG_WAITALL))

    /// Terminates a record (MSG_EOR).
    public static let endOfRecord = Self(rawValue: Int32(MSG_EOR))

    /// Do not use gateway routing (MSG_DONTROUTE).
    public static let dontRoute = Self(rawValue: Int32(MSG_DONTROUTE))

    /// Normal data was truncated (MSG_TRUNC).
    public static let truncate = Self(rawValue: Int32(MSG_TRUNC))

    /// Control data was truncated (MSG_CTRUNC).
    public static let controlTruncate = Self(rawValue: Int32(MSG_CTRUNC))

    /// Do not block (MSG_DONTWAIT).
    public static let dontWait = Self(rawValue: Int32(MSG_DONTWAIT))

    /// Do not generate SIGPIPE (MSG_NOSIGNAL).
    #if os(Linux)
        public static let noSignal = Self(rawValue: Int32(MSG_NOSIGNAL))
    #endif
}

//
//  Kernel.Wakeup.Channel.swift
//  swift-kernel-primitives
//
//  Thread-safe channel for interrupting blocking event waits.
//  Shared by Readiness (reactor) and Completion (proactor) drivers.
//

extension Kernel.Wakeup {
    /// Thread-safe channel for waking an event loop.
    ///
    /// Created by the driver backend. The channel is `Sendable`
    /// and can be called from any thread to interrupt a blocking wait.
    ///
    /// Platform mechanism:
    /// - **kqueue**: `EVFILT_USER` trigger event
    /// - **epoll**: `eventfd` write
    /// - **IOCP**: `PostQueuedCompletionStatus`
    public struct Channel: Sendable {
        private let signal: @Sendable () -> Void

        /// Creates a wakeup channel with the given signal closure.
        public init(signal: @escaping @Sendable () -> Void) {
            self.signal = signal
        }

        /// Interrupt a blocking wait.
        ///
        /// Thread-safe. Multiple concurrent calls are coalesced.
        /// Safe to call after the driver is closed (benign errors suppressed).
        public func wake() {
            signal()
        }
    }
}

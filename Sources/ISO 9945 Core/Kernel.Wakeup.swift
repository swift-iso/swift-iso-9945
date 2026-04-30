//
//  ISO_9945.Kernel.Wakeup.swift
//  swift-kernel-primitives
//
//  Namespace for wakeup-related types shared across
//  Readiness (reactor) and Completion (proactor) drivers.
//

extension ISO_9945.Kernel {
    /// Wakeup mechanism for interrupting blocking event waits.
    public enum Wakeup {}
}

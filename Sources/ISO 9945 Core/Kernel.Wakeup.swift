//
//  Kernel.Wakeup.swift
//  swift-kernel-primitives
//
//  Namespace for wakeup-related types shared across
//  Readiness (reactor) and Completion (proactor) drivers.
//

extension Kernel {
    /// Wakeup mechanism for interrupting blocking event waits.
    public enum Wakeup {}
}

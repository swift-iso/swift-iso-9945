// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

public import Kernel_Process_Primitives

#if canImport(Darwin)
    public import Darwin
#elseif canImport(Glibc)
    public import Glibc
#elseif canImport(Musl)
    public import Musl
#endif

extension ISO_9945.Kernel.Signal {
    /// Typed signal information accompanying an SA_SIGINFO handler invocation.
    ///
    /// Wraps `siginfo_t` layout-compatibly so typed accessors read the
    /// kernel-populated bytes without a copy. Consumers construct an
    /// `Information` value inside a `Handler.customInfo` body by dereferencing
    /// the `UnsafeMutablePointer<siginfo_t>?` passed by the kernel:
    ///
    /// ```swift
    /// let config = Configuration(handler: .customInfo { sig, infoPtr, _ in
    ///     guard let ptr = infoPtr else { return }
    ///     let info = unsafe Kernel.Signal.Information(pointee: ptr.pointee)
    ///     // info.number, info.sender, info.fault, …
    /// })
    /// ```
    ///
    /// ## Async-Signal-Safety
    ///
    /// Accessors are designed to be async-signal-safe: they read `cValue`
    /// fields directly and return stdlib or ecosystem value types without
    /// allocation, locks, or Swift runtime calls beyond primitive value
    /// construction. Matches the non-allocating contract of
    /// `Kernel.Socket.Address.Storage` and `Kernel.IO.Vector.Segment`.
    /// Empirical verification of this contract under a live signal-handler
    /// context is a recommended follow-up cycle; consumers relying on
    /// async-signal-safety SHOULD confirm in their own test harnesses
    /// until that verification lands. See `Handler` for the broader
    /// async-signal-safety contract.
    ///
    /// ## Layout Compatibility
    ///
    /// `MemoryLayout<Information>.stride == MemoryLayout<siginfo_t>.stride`
    /// by construction (single stored `siginfo_t` field).
    @safe
    public struct Information: @unchecked Sendable {
        internal var cValue: siginfo_t

        /// Creates a typed signal information value by copying the pointee
        /// of a kernel-provided `siginfo_t` pointer.
        ///
        /// Typically called inside a `Handler.customInfo` handler body:
        /// `unsafe Kernel.Signal.Information(pointee: infoPtr.pointee)`.
        @unsafe
        public init(pointee: siginfo_t) {
            unsafe (self.cValue = pointee)
        }
    }
}

// MARK: - Accessors

extension ISO_9945.Kernel.Signal.Information {
    /// The signal number this information describes.
    ///
    /// - POSIX: `si_signo`
    public var number: ISO_9945.Kernel.Signal.Number {
        ISO_9945.Kernel.Signal.Number(rawValue: unsafe cValue.si_signo)
    }

    /// The sender process identifier, when the signal carries sender information.
    ///
    /// Returns the sending process's `Kernel.Process.ID` when `si_code` indicates
    /// a user-sent signal (`SI_USER`, `SI_QUEUE`) or a child-state change
    /// (`CLD_*` under `SIGCHLD`). Returns `nil` for fault signals and other
    /// codes that do not populate `si_pid`.
    ///
    /// - POSIX: `si_pid`
    public var sender: Kernel.Process.ID? {
        let code = unsafe cValue.si_code

        #if canImport(Darwin)
            // Darwin siginfo_t exposes si_pid as a direct scalar field.
            switch code {
            case Int32(SI_USER), Int32(SI_QUEUE),
                 Int32(CLD_EXITED), Int32(CLD_KILLED), Int32(CLD_DUMPED), Int32(CLD_TRAPPED), Int32(CLD_STOPPED), Int32(CLD_CONTINUED):
                return Kernel.Process.ID(rawValue: unsafe cValue.si_pid)
            default:
                return nil
            }
        #elseif canImport(Glibc)
            // glibc siginfo_t uses the _sifields union; Swift's C importer
            // does not expand libc's `#define si_pid …` macro, so we reach
            // the union branch appropriate to the si_code class.
            switch code {
            case Int32(SI_USER), Int32(SI_QUEUE):
                return Kernel.Process.ID(rawValue: unsafe cValue._sifields._kill.si_pid)
            case Int32(CLD_EXITED), Int32(CLD_KILLED), Int32(CLD_DUMPED), Int32(CLD_TRAPPED), Int32(CLD_STOPPED), Int32(CLD_CONTINUED):
                return Kernel.Process.ID(rawValue: unsafe cValue._sifields._sigchld.si_pid)
            default:
                return nil
            }
        #elseif canImport(Musl)
            // musl siginfo_t lays out pid/uid under __si_fields.__si_common.__first.__piduid
            // for both SI_USER/SI_QUEUE and CLD_* (single sibling struct).
            switch code {
            case Int32(SI_USER), Int32(SI_QUEUE),
                 Int32(CLD_EXITED), Int32(CLD_KILLED), Int32(CLD_DUMPED), Int32(CLD_TRAPPED), Int32(CLD_STOPPED), Int32(CLD_CONTINUED):
                return Kernel.Process.ID(rawValue: unsafe cValue.__si_fields.__si_common.__first.__piduid.si_pid)
            default:
                return nil
            }
        #endif
    }

    /// The faulting memory address bit-pattern, when the signal represents a memory fault.
    ///
    /// Returns the `si_addr` bit-pattern (as `UInt`) when `si_code` indicates
    /// a fault (`SEGV_*`, `BUS_*`, `ILL_*`, `FPE_*`). Returns `nil` for non-fault
    /// signals or when the kernel left `si_addr` as null.
    ///
    /// To recover a typed address at a consumer site that imports
    /// `Kernel_Memory_Primitives`, use:
    ///
    /// ```swift
    /// import Kernel_Memory_Primitives
    /// if let bits = info.fault, let ptr = UnsafeMutableRawPointer(bitPattern: bits) {
    ///     let addr = unsafe Kernel.Memory.Address(ptr)
    /// }
    /// ```
    ///
    /// The weaker `UInt?` typing here avoids pulling `Kernel_Memory_Primitives`
    /// into the Signal target's public-import closure, which triggers an
    /// `Optic.Prism` namespace cascade at enum-pattern-match sites. Upgrading
    /// `.fault` to return `Kernel.Memory.Address?` is a candidate for a future
    /// cycle once the ecosystem resolves the cascade.
    ///
    /// - POSIX: `si_addr`
    public var fault: UInt? {
        let code = unsafe cValue.si_code

        #if canImport(Darwin)
            switch code {
            case Int32(SEGV_MAPERR), Int32(SEGV_ACCERR),
                 Int32(BUS_ADRALN), Int32(BUS_ADRERR), Int32(BUS_OBJERR),
                 Int32(ILL_ILLOPC), Int32(ILL_ILLTRP), Int32(ILL_PRVOPC), Int32(ILL_PRVREG), Int32(ILL_COPROC), Int32(ILL_BADSTK),
                 Int32(FPE_INTDIV), Int32(FPE_INTOVF), Int32(FPE_FLTDIV), Int32(FPE_FLTOVF), Int32(FPE_FLTUND), Int32(FPE_FLTRES), Int32(FPE_FLTINV), Int32(FPE_FLTSUB):
                guard let address = unsafe cValue.si_addr else { return nil }
                return UInt(bitPattern: address)
            default:
                return nil
            }
        #elseif canImport(Glibc)
            switch code {
            case Int32(SEGV_MAPERR), Int32(SEGV_ACCERR),
                 Int32(BUS_ADRALN), Int32(BUS_ADRERR), Int32(BUS_OBJERR),
                 Int32(ILL_ILLOPC), Int32(ILL_ILLTRP), Int32(ILL_PRVOPC), Int32(ILL_PRVREG), Int32(ILL_COPROC), Int32(ILL_BADSTK),
                 Int32(FPE_INTDIV), Int32(FPE_INTOVF), Int32(FPE_FLTDIV), Int32(FPE_FLTOVF), Int32(FPE_FLTUND), Int32(FPE_FLTRES), Int32(FPE_FLTINV), Int32(FPE_FLTSUB):
                guard let address = unsafe cValue._sifields._sigfault.si_addr else { return nil }
                return UInt(bitPattern: address)
            default:
                return nil
            }
        #elseif canImport(Musl)
            switch code {
            case Int32(SEGV_MAPERR), Int32(SEGV_ACCERR),
                 Int32(BUS_ADRALN), Int32(BUS_ADRERR), Int32(BUS_OBJERR),
                 Int32(ILL_ILLOPC), Int32(ILL_ILLTRP), Int32(ILL_PRVOPC), Int32(ILL_PRVREG), Int32(ILL_COPROC), Int32(ILL_BADSTK),
                 Int32(FPE_INTDIV), Int32(FPE_INTOVF), Int32(FPE_FLTDIV), Int32(FPE_FLTOVF), Int32(FPE_FLTUND), Int32(FPE_FLTRES), Int32(FPE_FLTINV), Int32(FPE_FLTSUB):
                guard let address = unsafe cValue.__si_fields.__sigfault.si_addr else { return nil }
                return UInt(bitPattern: address)
            default:
                return nil
            }
        #endif
    }
}

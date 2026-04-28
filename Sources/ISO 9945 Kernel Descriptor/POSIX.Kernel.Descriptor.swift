// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

internal import Kernel_Descriptor_Primitives
@_spi(Syscall) internal import ISO_9945_Kernel_File

// MARK: - POSIX Descriptor (L2 — Phase 1.5)
//
// Per `swift-institute/Research/posix-descriptor-l2-vs-l3policy.md` v1.0.0
// RECOMMENDATION (2026-04-28, commit 1bddfe6): the type-level commitment
// (RAII close-on-deinit) belongs WITH the type definition; iso-9945 owns
// the spec-mirroring `Kernel` namespace and IS the canonical home for
// POSIX-spec types. The L3-policy placement at swift-posix was structurally
// redundant — the symmetry argument from `l1-types-only-no-exceptions.md`
// § 5 elided the type-level vs function-level policy distinction.
//
// The cross-platform name `Kernel.Descriptor` is unified at L3-unifier
// (`swift-kernel`) via `#if`-gated typealias resolving to this type on
// POSIX platforms. swift-posix retains policy-bearing extensions (Validity,
// Close.Error, +Equation, +Hash, Interest, Duplicate) on this type at
// L3-policy.

extension POSIX.Kernel {
    /// POSIX file descriptor with close-on-deinit policy.
    ///
    /// A `~Copyable` move-only wrapper around the platform-native `Int32` file
    /// descriptor. The `deinit` invokes the L2 raw `close(2)` syscall via
    /// `Kernel.Close.close(_ fd: Int32)` (in `ISO 9945 Kernel File`) and
    /// ignores the result — `deinit` cannot throw, so close-failure is
    /// silently dropped here. Use `POSIX.Kernel.Close.close(_:)` (in
    /// swift-posix) for explicit close-with-error reporting.
    ///
    /// ## Layering
    ///
    /// | Layer | Site | Behavior |
    /// |---|---|---|
    /// | L1 swift-kernel-primitives | (no Descriptor type, slated for Cycle 23 deletion) | Hosts only the `Kernel.Close` namespace shell |
    /// | L2 swift-iso-9945 | `POSIX.Kernel.Descriptor` (this type) + `Kernel.Close.close(_:Int32) -> Int32` | Native fd + close-on-deinit + spec-literal raw close |
    /// | L3-policy swift-posix | Extensions on this type — Validity, Close.Error, +Equation, +Hash, Interest, Duplicate | Policy-bearing error mapping + protocol conformances |
    /// | L3-unifier swift-kernel | `typealias Kernel.Descriptor = POSIX.Kernel.Descriptor` | Cross-platform name |
    ///
    /// ## Thread Safety
    ///
    /// The descriptor value is `Sendable`. Sharing the underlying kernel
    /// resource across threads requires external synchronization.
    public struct Descriptor: ~Copyable, Sendable {
        @usableFromInline
        package var _raw: Int32

        @usableFromInline
        package init(_raw: Int32) {
            self._raw = _raw
        }

        deinit {
            guard isValid else { return }
            // L2 deinit: spec-literal close. deinit can't throw, so ignore the
            // result. Application code wanting close-with-error reporting calls
            // `POSIX.Kernel.Close.close(_:)` (at swift-posix L3-policy)
            // explicitly.
            _ = Kernel.Close.close(_raw)
        }

        /// Invalid descriptor sentinel (`-1`).
        public static var invalid: Descriptor {
            Descriptor(_raw: -1)
        }

        /// Whether the descriptor is valid (not the sentinel).
        @inlinable
        public var isValid: Bool {
            _raw >= 0
        }
    }
}

// MARK: - SPI for Syscall Layers

extension POSIX.Kernel.Descriptor {
    /// Creates a descriptor from a raw POSIX file-descriptor value.
    ///
    /// Available only via `@_spi(Syscall)` for syscall-implementation layers
    /// (iso-9945 spec wrappers, etc.). Application code obtains descriptors
    /// from policy-aware open / accept / pipe constructors.
    @_spi(Syscall)
    @inlinable
    public init(_rawValue: Int32) {
        self._raw = _rawValue
    }

    /// The raw POSIX file-descriptor value.
    ///
    /// Available only via `@_spi(Syscall)` for syscall-implementation layers.
    /// Setter is the disarm path used by L3-policy `close(_:)` wrappers that
    /// need to prevent the RAII deinit-close from firing alongside an explicit
    /// close (which would double-close the kernel fd).
    @_spi(Syscall)
    @inlinable
    public var _rawValue: Int32 {
        get { _raw }
        set { _raw = newValue }
    }
}

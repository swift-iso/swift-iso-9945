# ISO 9945

Swift implementation of ISO/IEC/IEEE 9945 (POSIX.1) — the **System Interfaces** volume:
kernel and C-library surfaces (file descriptors, errno, processes, signals, sockets,
threads, time) under the `ISO_9945` namespace.

Swift Embedded compatible.

## Specification identity

ISO/IEC/IEEE 9945 and IEEE Std 1003.1 are the **same joint standard** (POSIX), published
under two authorities' designations. This ecosystem encodes it per volume:

| Volume | Package | Namespace |
|---|---|---|
| System Interfaces (**this package**) | `swift-iso/swift-iso-9945` | `ISO_9945` |
| Base Definitions (XBD) Ch.12 — Utility Conventions | [`swift-ieee/swift-ieee-1003`](https://github.com/swift-ieee/swift-ieee-1003) | `IEEE_1003` |

Sibling volume of the same joint standard: [`swift-ieee/swift-ieee-1003`](https://github.com/swift-ieee/swift-ieee-1003)
— argv tokenization per the XBD §12.2 Utility Syntax Guidelines, consumed by `swift-arguments`.
Neither package supersedes the other; they implement disjoint volumes of one specification.

POSIX targets POSIX systems: CI runs the Apple and Linux legs; the Windows leg is declared
out via the CI `platform-support` input (Windows is not a POSIX system).

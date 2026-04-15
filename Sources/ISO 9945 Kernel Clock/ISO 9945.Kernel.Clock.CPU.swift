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

extension Kernel.Clock {
    /// CPU-time clocks — count CPU consumption (user + system time spent
    /// executing), as opposed to ``Continuous`` and ``Suspending`` which
    /// count wall-clock progression.
    ///
    /// A thread sleeping in the kernel (blocked on a syscall, a futex, or
    /// explicit sleep) does not contribute to CPU time. A thread executing
    /// user code or a kernel-side operation does.
    ///
    /// Used to distinguish idle-waiting from hot-spinning in tests and
    /// benchmarks: wall-clock alone cannot tell the two apart.
    public enum CPU {}
}

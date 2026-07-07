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

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX thread creation

extension ISO_9945.Kernel.Thread {
    /// Creates a new OS thread.
    ///
    /// This is the low-level thread creation syscall wrapper. The closure
    /// is invoked exactly once on the spawned OS thread.
    ///
    /// - Parameter body: The work to run on the new thread.
    /// - Returns: A handle to the created thread.
    /// - Throws: `Error.create` if thread creation fails.

    public static func create(
        _ body: @escaping @Sendable () -> Void
    ) throws(ISO_9945.Kernel.Thread.Error) -> ISO_9945.Kernel.Thread.Handle {
        let context = UnsafeMutablePointer<(@Sendable () -> Void)>.allocate(capacity: 1)
        unsafe context.initialize(to: body)

        #if canImport(Darwin)
            var thread: pthread_t?

            let result = unsafe pthread_create(
                &thread,
                nil,
                { ctx in
                    let bodyPtr = unsafe ctx.assumingMemoryBound(to: (@Sendable () -> Void).self)
                    let work = unsafe bodyPtr.move()
                    unsafe bodyPtr.deallocate()
                    work()
                    return nil
                },
                context
            )

            guard result == 0, let thread = unsafe thread else {
                unsafe context.deinitialize(count: 1)
                unsafe context.deallocate()
                throw .create(.posix(result))
            }

            return unsafe ISO_9945.Kernel.Thread.Handle(rawValue: thread)

        #else
            // Linux: pthread_t is non-optional
            var thread: pthread_t = 0

            let result = pthread_create(
                &thread,
                nil,
                { ctx in
                    guard let ctx else { return nil }
                    let bodyPtr = ctx.assumingMemoryBound(to: (@Sendable () -> Void).self)
                    let work = bodyPtr.move()
                    bodyPtr.deallocate()
                    work()
                    return nil
                },
                context
            )

            guard result == 0 else {
                context.deinitialize(count: 1)
                context.deallocate()
                throw .create(.posix(result))
            }

            return ISO_9945.Kernel.Thread.Handle(rawValue: thread)
        #endif
    }
}

// MARK: - Thread Yield

extension ISO_9945.Kernel.Thread {
    /// Yields execution to the OS scheduler as a hint.
    ///
    /// This is a policy-free wrapper around platform yield primitives.

    public static func yield() {
        let result = sched_yield()
        #if DEBUG
            precondition(result == 0, "sched_yield() failed with errno \(errno)")
        #endif
    }
}

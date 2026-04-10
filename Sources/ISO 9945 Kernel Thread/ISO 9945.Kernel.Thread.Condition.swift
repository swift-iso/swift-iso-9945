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

@_spi(Syscall) public import Kernel_Primitives_Core
@_spi(Syscall) public import Kernel_Descriptor_Primitives
@_spi(Syscall) public import Kernel_Error_Primitives
@_spi(Syscall) public import Kernel_File_Primitives
@_spi(Syscall) public import Kernel_IO_Primitives
@_spi(Syscall) public import Kernel_Socket_Primitives
@_spi(Syscall) public import Kernel_Memory_Primitives
@_spi(Syscall) public import Kernel_Process_Primitives
@_spi(Syscall) public import Kernel_Permission_Primitives
@_spi(Syscall) public import Kernel_Path_Primitives
@_spi(Syscall) public import Kernel_Thread_Primitives
@_spi(Syscall) public import Kernel_System_Primitives
@_spi(Syscall) public import Kernel_Time_Primitives
@_spi(Syscall) public import Kernel_Clock_Primitives
@_spi(Syscall) public import Kernel_Random_Primitives
@_spi(Syscall) public import Kernel_Environment_Primitives
@_spi(Syscall) public import Kernel_Syscall_Primitives
@_spi(Syscall) public import Kernel_Terminal_Primitives
public import ISO_9945

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX Thread Condition Variable

extension ISO_9945.Kernel.Thread {
    /// A low-level condition variable for thread synchronization.
    ///
    /// This is a policy-free wrapper around `pthread_cond_t`.
    ///
    /// ## Safety
    /// This type is `@unchecked Sendable` because it provides internal synchronization.
    ///
    /// ## Usage
    /// Condition variables are always used with a mutex:
    /// ```swift
    /// let mutex = POSIX.Kernel.Thread.Mutex()
    /// let condition = POSIX.Kernel.Thread.Condition()
    ///
    /// // Waiting thread:
    /// mutex.lock()
    /// while !ready {
    ///     condition.wait(mutex: mutex)
    /// }
    /// // ... process ...
    /// mutex.unlock()
    ///
    /// // Signaling thread:
    /// mutex.lock()
    /// ready = true
    /// condition.signal()
    /// mutex.unlock()
    /// ```
    public final class Condition: @unchecked Sendable {
        private var cond: pthread_cond_t

        /// Creates a new condition variable.
        ///
        /// On Linux, configures the condition to use `CLOCK_MONOTONIC` for
        /// timed waits, which is more robust than `CLOCK_REALTIME`.
        public init() {
            self.cond = pthread_cond_t()
            var attr = pthread_condattr_t()
            unsafe pthread_condattr_init(&attr)
            #if !os(macOS) && !os(iOS) && !os(tvOS) && !os(watchOS)
                unsafe pthread_condattr_setclock(&attr, CLOCK_MONOTONIC)
            #endif
            unsafe pthread_cond_init(&self.cond, &attr)
            unsafe pthread_condattr_destroy(&attr)
        }

        deinit {
            unsafe pthread_cond_destroy(&cond)
        }
    }
}

// MARK: - Wait Operations

extension ISO_9945.Kernel.Thread.Condition {
    /// Waits on the condition variable.
    ///
    /// The mutex is atomically released while waiting and reacquired before returning.
    ///
    /// - Parameter mutex: The mutex to release while waiting.
    /// - Precondition: The mutex must be held by the current thread.
    public func wait(mutex: ISO_9945.Kernel.Thread.Mutex) {
        _ = unsafe mutex.withUnsafeMutablePointer { mutexPtr in
            unsafe pthread_cond_wait(&cond, mutexPtr)
        }
    }

    /// Waits on the condition variable with a timeout.
    ///
    /// The mutex is atomically released while waiting and reacquired before returning.
    ///
    /// - Parameters:
    ///   - mutex: The mutex to release while waiting.
    ///   - timeout: Maximum time to wait.
    /// - Returns: `true` if signaled, `false` if timed out.
    /// - Precondition: The mutex must be held by the current thread.
    public func wait(mutex: ISO_9945.Kernel.Thread.Mutex, timeout: Duration) -> Bool {
        unsafe mutex.withUnsafeMutablePointer { mutexPtr in
            var ts = timespec()
            #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
                // macOS uses absolute time from gettimeofday
                var tv = timeval()
                unsafe gettimeofday(&tv, nil)
                let (seconds, attoseconds) = timeout.components
                ts.tv_sec = tv.tv_sec + Int(seconds)
                ts.tv_nsec = Int(tv.tv_usec) * 1000 + Int(attoseconds / 1_000_000_000)
                if ts.tv_nsec >= 1_000_000_000 {
                    ts.tv_sec += 1
                    ts.tv_nsec -= 1_000_000_000
                }
            #else
                // Linux uses CLOCK_MONOTONIC (set in init)
                clock_gettime(CLOCK_MONOTONIC, &ts)
                let (seconds, attoseconds) = timeout.components
                ts.tv_sec += Int(seconds)
                ts.tv_nsec += Int(attoseconds / 1_000_000_000)
                if ts.tv_nsec >= 1_000_000_000 {
                    ts.tv_sec += 1
                    ts.tv_nsec -= 1_000_000_000
                }
            #endif
            let result = unsafe pthread_cond_timedwait(&cond, mutexPtr, &ts)
            return result == 0
        }
    }
}

// MARK: - Signal Operations

extension ISO_9945.Kernel.Thread.Condition {
    /// Signals one waiting thread.
    ///
    /// If multiple threads are waiting, one is unblocked (which one is unspecified).
    public func signal() {
        unsafe pthread_cond_signal(&cond)
    }

    /// Signals all waiting threads.
    ///
    /// All threads waiting on this condition variable are unblocked.
    public func broadcast() {
        unsafe pthread_cond_broadcast(&cond)
    }
}

// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-posix open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-posix project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

public import Kernel_Primitives_Core
public import Kernel_Descriptor_Primitives
public import Kernel_Error_Primitives
public import Kernel_File_Primitives
public import Kernel_IO_Primitives
public import Kernel_Socket_Primitives
public import Kernel_Memory_Primitives
public import Kernel_Process_Primitives
public import Kernel_Permission_Primitives
public import Kernel_Path_Primitives
public import Kernel_Thread_Primitives
public import Kernel_System_Primitives
public import Kernel_Time_Primitives
public import Kernel_Clock_Primitives
public import Kernel_Random_Primitives
public import Kernel_Environment_Primitives
public import Kernel_Syscall_Primitives
public import Kernel_Terminal_Primitives
public import ISO_9945

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Signal.Action {
    /// Sets the signal action, returning the previous configuration.
    ///
    /// - Parameters:
    ///   - signal: The signal to configure.
    ///   - configuration: The new signal action configuration.
    /// - Returns: The previous signal action configuration.
    /// - Throws: `Error.action` on failure.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Install a custom handler
    /// let config = Configuration(handler: .custom(myHandler), flags: .restart)
    /// let previous = try POSIX.Kernel.Signal.Action.set(signal: .user1, config)
    ///
    /// // Always restore on cleanup
    /// defer { _ = try? POSIX.Kernel.Signal.Action.set(signal: .user1, previous) }
    /// ```
    @discardableResult

    @unsafe
    public static func set(
        signal: POSIX.Kernel.Signal.Number,
        _ configuration: Configuration
    ) throws(POSIX.Kernel.Signal.Error) -> Configuration {
        var newAction = unsafe sigaction(configuration)
        var oldAction = sigaction()

        guard unsafe sigaction(signal.rawValue, &newAction, &oldAction) == 0 else {
            throw .action(POSIX.Kernel.Error.captureErrno())
        }

        return unsafe Configuration(oldAction)
    }

    /// Gets the current signal action configuration.
    ///
    /// - Parameter signal: The signal to query.
    /// - Returns: The current signal action configuration.
    /// - Throws: `Error.action` on failure.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let config = try POSIX.Kernel.Signal.Action.get(signal: .user1)
    /// switch config.handler {
    /// case .default: print("Using default action")
    /// case .ignore: print("Signal ignored")
    /// case .custom: print("Custom handler installed")
    /// case .customInfo: print("Custom handler with siginfo")
    /// }
    /// ```

    @unsafe
    public static func get(
        signal: POSIX.Kernel.Signal.Number
    ) throws(POSIX.Kernel.Signal.Error) -> Configuration {
        var action = sigaction()

        guard unsafe sigaction(signal.rawValue, nil, &action) == 0 else {
            throw .action(POSIX.Kernel.Error.captureErrno())
        }

        return unsafe Configuration(action)
    }
}

// MARK: - sigaction ← Configuration

extension sigaction {
    /// Creates a sigaction struct from a Configuration.
    @unsafe
    internal init(_ configuration: POSIX.Kernel.Signal.Action.Configuration) {
        self.init()

        // Set mask
        self.sa_mask = configuration.mask.storage

        // Set flags
        self.sa_flags = configuration.flags.rawValue

        // Set handler based on type
        #if canImport(Darwin)
            switch unsafe configuration.handler {
            case .default:
                unsafe (self.__sigaction_u.__sa_handler = SIG_DFL)
            case .ignore:
                unsafe (self.__sigaction_u.__sa_handler = SIG_IGN)
            case .custom(let handler):
                unsafe (self.__sigaction_u.__sa_handler = handler)
            case .customInfo(let handler):
                unsafe (self.__sigaction_u.__sa_sigaction = handler)
            }
        #elseif canImport(Glibc)
            switch unsafe configuration.handler {
            case .default:
                unsafe (self.__sigaction_handler.sa_handler = SIG_DFL)
            case .ignore:
                unsafe (self.__sigaction_handler.sa_handler = SIG_IGN)
            case .custom(let handler):
                unsafe (self.__sigaction_handler.sa_handler = handler)
            case .customInfo(let handler):
                unsafe (self.__sigaction_handler.sa_sigaction = handler)
            }
        #elseif canImport(Musl)
            switch unsafe configuration.handler {
            case .default:
                unsafe (self.sa_handler = SIG_DFL)
            case .ignore:
                unsafe (self.sa_handler = SIG_IGN)
            case .custom(let handler):
                unsafe (self.sa_handler = handler)
            case .customInfo(let handler):
                unsafe (self.sa_sigaction = handler)
            }
        #endif
    }
}

// MARK: - Configuration ← sigaction

extension ISO_9945.Kernel.Signal.Action.Configuration {
    /// Creates a Configuration from a raw sigaction struct.
    @unsafe
    internal init(_ action: sigaction) {
        let flags = POSIX.Kernel.Signal.Action.Options(rawValue: action.sa_flags)
        let mask = POSIX.Kernel.Signal.Set(storage: action.sa_mask)

        // Determine handler type
        let handler: POSIX.Kernel.Signal.Action.Handler

        #if canImport(Darwin)
            let handlerPtr = unsafe action.__sigaction_u.__sa_handler
            let sigactionPtr = unsafe action.__sigaction_u.__sa_sigaction
        #elseif canImport(Glibc)
            let handlerPtr = unsafe action.__sigaction_handler.sa_handler
            let sigactionPtr = unsafe action.__sigaction_handler.sa_sigaction
        #elseif canImport(Musl)
            let handlerPtr = unsafe action.sa_handler
            let sigactionPtr = unsafe action.sa_sigaction
        #endif

        if flags.contains(.sigInfo) {
            // SA_SIGINFO set, use sa_sigaction
            if let ptr = unsafe sigactionPtr {
                unsafe (handler = .customInfo(ptr))
            } else {
                // Shouldn't happen, but fallback to default
                unsafe (handler = .default)
            }
        } else {
            // Check for special handler values using raw pointer comparison
            // SIG_DFL and SIG_IGN are special constants (typically 0 and 1)
            let handlerRaw = unsafe unsafeBitCast(handlerPtr, to: Int.self)
            let sigDflRaw = unsafe unsafeBitCast(SIG_DFL, to: Int.self)
            let sigIgnRaw = unsafe unsafeBitCast(SIG_IGN, to: Int.self)

            if handlerRaw == sigDflRaw {
                unsafe (handler = .default)
            } else if handlerRaw == sigIgnRaw {
                unsafe (handler = .ignore)
            } else if let ptr = handlerPtr {
                unsafe (handler = .custom(ptr))
            } else {
                unsafe (handler = .default)
            }
        }

        // Use unchecked init - kernel state has correct handler/flags relationship
        unsafe self.init(__unchecked: (), handler: handler, mask: mask, flags: flags)
    }
}

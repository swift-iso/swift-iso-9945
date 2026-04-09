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

#ifndef CISO9945_SHIM_H
#define CISO9945_SHIM_H

// POSIX C interop shims for functions Swift cannot call directly:
// - Variadic C functions
// - C macros that Swift cannot import

#if defined(__APPLE__) || defined(__linux__) || defined(__OpenBSD__)

// ===----------------------------------------------------------------------===//
// MARK: - Terminal I/O (ioctl is variadic)
// ===----------------------------------------------------------------------===//

#include <sys/ioctl.h>

/// Get terminal window size via ioctl TIOCGWINSZ.
/// ioctl is variadic — Swift cannot call it directly.
static inline int iso9945_ioctl_tiocgwinsz(int fd, struct winsize *ws) {
    return ioctl(fd, TIOCGWINSZ, ws);
}

// ===----------------------------------------------------------------------===//
// MARK: - Dynamic Loading Sentinels (C macros)
// ===----------------------------------------------------------------------===//

#include <dlfcn.h>

/// RTLD_DEFAULT — search default symbol scope.
/// This is a C macro (typically ((void *)0)), not importable by Swift.
static inline void *iso9945_RTLD_DEFAULT(void) {
    return RTLD_DEFAULT;
}

/// RTLD_NEXT — search next shared object in load order.
/// This is a C macro, not importable by Swift.
static inline void *iso9945_RTLD_NEXT(void) {
    return RTLD_NEXT;
}

#endif /* __APPLE__ || __linux__ || __OpenBSD__ */

// ===----------------------------------------------------------------------===//
// MARK: - Darwin-specific POSIX workarounds
// ===----------------------------------------------------------------------===//

#if defined(__APPLE__)

#include <sys/mman.h>
#include <sys/types.h>

/// shm_open wrapper — on Darwin, shm_open is declared variadic:
///   int shm_open(const char *, int, ...);
/// Swift cannot call variadic C functions.
static inline int iso9945_shm_open(const char *name, int oflag, mode_t mode) {
    return shm_open(name, oflag, mode);
}

#endif /* __APPLE__ */

#endif /* CISO9945_SHIM_H */

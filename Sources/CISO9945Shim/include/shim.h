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

#ifndef CISO9945_SHIM_H
#define CISO9945_SHIM_H

// POSIX C interop shims for functions Swift cannot call directly:
// - Variadic C functions
// - C macros that Swift cannot import

// _GNU_SOURCE is required on glibc to expose FNM_CASEFOLD (POSIX Issue 8).
// It must be defined before ANY libc header is included: <features.h> is
// include-guarded, so a later define is a no-op. Defined here, before the
// first include, and left defined for the rest of the translation unit.
//
// This deliberately makes every feature-gated struct this header's system
// includes can see (glibc's __USE_GNU-conditional fields) wider than the
// Swift toolchain's own SwiftGlibc module, which does not define
// _GNU_SOURCE. Clang's modules system requires two modules that both parse
// the same system header to agree on its expansion, so this header must
// never itself declare, or expose a function signature naming, a type
// whose layout _GNU_SOURCE affects — glob_t in particular (see the Glob
// section below, which deliberately does not include <glob.h> here for
// this reason). A type unaffected by _GNU_SOURCE (dev_t, struct winsize,
// the FNM_* int constants) is unaffected by which module parsed it first.
#if !defined(_GNU_SOURCE)
#define _GNU_SOURCE 1
#endif

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
// MARK: - Device numbers (major/minor/makedev are macros)
// ===----------------------------------------------------------------------===//

#include <stdint.h>
#include <sys/types.h>
#if defined(__linux__)
#include <sys/sysmacros.h>
#endif

/// Extract the major device number using the platform's own decomposition.
/// POSIX defines no dev_t encoding; major()/minor()/makedev() are macros
/// Swift cannot import.
static inline unsigned int iso9945_device_major(uint64_t dev) {
    return (unsigned int)major((dev_t)dev);
}

/// Extract the minor device number using the platform's own decomposition.
static inline unsigned int iso9945_device_minor(uint64_t dev) {
    return (unsigned int)minor((dev_t)dev);
}

/// Compose a dev_t from major and minor using the platform's own encoding.
static inline uint64_t iso9945_device_make(unsigned int major_number, unsigned int minor_number) {
    return (uint64_t)makedev(major_number, minor_number);
}

// ===----------------------------------------------------------------------===//
// MARK: - Fnmatch (POSIX Issue 8)
// ===----------------------------------------------------------------------===//

#include <fnmatch.h>

// fnmatch constants
static inline int iso9945_fnm_pathname(void) { return FNM_PATHNAME; }
static inline int iso9945_fnm_noescape(void) { return FNM_NOESCAPE; }
static inline int iso9945_fnm_period(void)   { return FNM_PERIOD; }

// FNM_CASEFOLD is a GNU/Darwin extension adopted by POSIX Issue 8.
// Musl does not implement it yet.
#ifdef FNM_CASEFOLD
static inline int iso9945_fnm_casefold(void) { return FNM_CASEFOLD; }
#else
static inline int iso9945_fnm_casefold(void) { return 0; }
#endif

// fnmatch no-match result
static inline int iso9945_fnm_nomatch(void) { return FNM_NOMATCH; }

// fnmatch function
static inline int iso9945_fnmatch(const char *pattern, const char *string, int flags) {
    return fnmatch(pattern, string, flags);
}

// ===----------------------------------------------------------------------===//
// MARK: - Glob (POSIX Issue 8)
// ===----------------------------------------------------------------------===//
//
// glob(3)/globfree(3) are not variadic and glob_t carries no macro Swift
// cannot import, so this package has no shim reason to redeclare them.
// Deliberately not wrapped here: including <glob.h> under this header's
// permanent _GNU_SOURCE would give glob_t extra __USE_GNU-gated fields
// (gl_readdir/gl_stat/gl_lstat) that the Swift toolchain's own SwiftGlibc
// module — compiled without _GNU_SOURCE — does not have, and Clang's
// modules system rejects the two disagreeing views of the same struct
// the moment both modules are loaded together. ISO 9945 Glob calls
// glob(3)/globfree(3) and reads GLOB_*/glob_t directly through the
// platform module (Darwin/Glibc/Musl) instead, so only one module ever
// declares the type.

#endif /* __APPLE__ || __linux__ || __OpenBSD__ */

// ===----------------------------------------------------------------------===//
// MARK: - Darwin-specific POSIX workarounds
// ===----------------------------------------------------------------------===//

#if defined(__APPLE__)

#include <sys/mman.h>

/// shm_open wrapper — on Darwin, shm_open is declared variadic:
///   int shm_open(const char *, int, ...);
/// Swift cannot call variadic C functions.
static inline int iso9945_shm_open(const char *name, int oflag, mode_t mode) {
    return shm_open(name, oflag, mode);
}

#endif /* __APPLE__ */

#endif /* CISO9945_SHIM_H */

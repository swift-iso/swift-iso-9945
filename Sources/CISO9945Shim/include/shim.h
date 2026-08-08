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

#if defined(__ANDROID__)
#include "android.h"
#endif

// POSIX C interop shims for functions Swift cannot call directly:
// - Variadic C functions
// - C macros that Swift cannot import

// This header deliberately never defines _GNU_SOURCE (or any other
// feature-test macro) before its system includes. Defining it would
// widen every __USE_GNU-gated struct these includes reach — not just
// glob_t (see the Glob section below) but, e.g., fd_set via
// <sys/types.h>'s transitive <sys/select.h> — beyond what the Swift
// toolchain's own SwiftGlibc module sees, since that module does not
// define _GNU_SOURCE. Clang's modules system requires two modules that
// both parse the same system header to agree on its expansion, so any
// such widening surfaces as a Clang-modules "not present in definition"
// error the moment both modules are loaded together, for whichever
// struct happened to be reached first. FNM_CASEFOLD, the one constant
// here that glibc gates behind _GNU_SOURCE, is exposed via its stable
// glibc ABI value instead — see iso9945_fnm_casefold below.

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
#elif defined(__GLIBC__)
// glibc only exposes the FNM_CASEFOLD macro under _GNU_SOURCE
// (posix/fnmatch.h gates it on __USE_GNU), which this header does not
// define — see the file-level comment above. The bit position is
// stable glibc ABI (unchanged since the flag's introduction), so it is
// used directly instead of forcing _GNU_SOURCE on this whole header.
static inline int iso9945_fnm_casefold(void) { return 1 << 4; }
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
// cannot import, so this package has no shim reason to redeclare them —
// deliberately not wrapped here (see the file-level _GNU_SOURCE comment
// above: <glob.h> is precisely the header whose glob_t widens under
// _GNU_SOURCE). ISO 9945 Glob calls glob(3)/globfree(3) and reads
// GLOB_*/glob_t directly through the platform module (Darwin/Glibc/Musl)
// instead, so only one module ever declares the type.

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

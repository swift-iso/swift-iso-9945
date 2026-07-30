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
// include-guarded, so a later define is a no-op. Defined here — before the
// first include — and undefined again at the end of this header so the
// feature-test macro does not leak into consumers of this public header.
#if !defined(_GNU_SOURCE)
#define _GNU_SOURCE 1
#define ISO9945_SHIM_DEFINED_GNU_SOURCE 1
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
// MARK: - Glob / Fnmatch (POSIX Issue 8)
// ===----------------------------------------------------------------------===//

#include <fnmatch.h>
#include <glob.h>

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

// glob constants
static inline int iso9945_glob_err(void)      { return GLOB_ERR; }
static inline int iso9945_glob_mark(void)     { return GLOB_MARK; }
static inline int iso9945_glob_nosort(void)   { return GLOB_NOSORT; }
static inline int iso9945_glob_nocheck(void)  { return GLOB_NOCHECK; }
static inline int iso9945_glob_noescape(void) { return GLOB_NOESCAPE; }

// glob error codes
static inline int iso9945_glob_nomatch(void)  { return GLOB_NOMATCH; }
static inline int iso9945_glob_nospace(void)  { return GLOB_NOSPACE; }
static inline int iso9945_glob_aborted(void)  { return GLOB_ABORTED; }

// glob function
static inline int iso9945_glob(const char *pattern, int flags,
                               int (*errfunc)(const char *, int),
                               glob_t *pglob) {
    return glob(pattern, flags, errfunc, pglob);
}

static inline void iso9945_globfree(glob_t *pglob) {
    globfree(pglob);
}

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

#if defined(ISO9945_SHIM_DEFINED_GNU_SOURCE)
#undef _GNU_SOURCE
#undef ISO9945_SHIM_DEFINED_GNU_SOURCE
#endif

#endif /* CISO9945_SHIM_H */

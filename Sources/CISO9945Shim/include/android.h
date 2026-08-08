// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#ifndef CISO9945_ANDROID_H
#define CISO9945_ANDROID_H

#include <errno.h>
#include <fcntl.h>
#include <sys/syscall.h>
#include <unistd.h>

// Bionic's faccessat() rejects AT_EACCESS. Its public headers expose the
// faccessat2 syscall number but no non-variadic wrapper Swift can call.
static inline int iso9945_android_faccessat2(const char *path, int mode) {
#if defined(SYS_faccessat2)
    return (int)syscall(SYS_faccessat2, AT_FDCWD, path, mode, AT_EACCESS);
#else
    errno = ENOSYS;
    return -1;
#endif
}

#endif /* CISO9945_ANDROID_H */

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

// MARK: - POSIX error mapping
//
// All init?(code:) initializers for kernel error types are defined in Kernel_Primitives.
// This file documents the POSIX errno mappings but does not duplicate the implementations.
//
// Mappings defined in Kernel_Primitives:
// - Path.Resolution.Error: ENOENT, EEXIST, EISDIR, ENOTDIR, ENOTEMPTY, ELOOP, EXDEV, ENAMETOOLONG
// - ISO_9945.Kernel.Permission.Error: EACCES, EPERM, EROFS
// - ISO_9945.Kernel.Descriptor.Validity.Error: EBADF
// - ISO_9945.Kernel.IO.Blocking.Error: EAGAIN, EWOULDBLOCK
// - ISO_9945.Kernel.Storage.Error: ENOSPC, EDQUOT
// - Memory.Error: EFAULT, ENOMEM
// - ISO_9945.Kernel.IO.Error: EIO, EPIPE, EINTR
// - ISO_9945.Kernel.Lock.Error: ENOLCK, EDEADLK

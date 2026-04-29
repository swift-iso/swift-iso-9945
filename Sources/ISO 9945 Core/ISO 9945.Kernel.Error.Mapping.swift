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
// - Kernel.Permission.Error: EACCES, EPERM, EROFS
// - Kernel.Descriptor.Validity.Error: EBADF
// - Kernel.IO.Blocking.Error: EAGAIN, EWOULDBLOCK
// - Kernel.Storage.Error: ENOSPC, EDQUOT
// - Memory.Error: EFAULT, ENOMEM
// - Kernel.IO.Error: EIO, EPIPE, EINTR
// - Kernel.Lock.Error: ENOLCK, EDEADLK

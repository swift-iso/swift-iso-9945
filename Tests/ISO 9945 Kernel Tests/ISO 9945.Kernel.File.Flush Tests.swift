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

import ISO_9945_Kernel_Test_Support
import ISO_9945_Kernel
import ISO_9945_Kernel_File
import Kernel_Primitives_Core
import Kernel_Descriptor_Primitives
import Kernel_File_Primitives
import Kernel_Path_Primitives
import Testing

@testable import ISO_9945_Kernel

extension Kernel.File.Flush {
    @Suite
    struct Test {
        @Suite struct DataOnly {}
        @Suite struct Directory {}
    }
}

// MARK: - dataOnly(_:) Smoke

extension Kernel.File.Flush.Test.DataOnly {
    @Test("dataOnly(_:) on a fresh tmp file succeeds on every platform")
    func dataOnlyOnTempFile() throws {
        let path = KernelIOTest.makeTempPath(prefix: "flush-dataOnly")
        defer { KernelIOTest.cleanup(path: path) }

        let fd = try KernelIOTest.open(at: path)
        KernelIOTest.write("payload", to: fd)

        // Cross-platform contract — no #if, single call.
        try Kernel.File.Flush.dataOnly(fd)
    }
}

// MARK: - directory(path:) Smoke

extension Kernel.File.Flush.Test.Directory {
    @Test("directory(path:) on the system temp directory succeeds (POSIX) / no-ops (Windows)")
    func directoryOnTempDirectory() throws {
        let tempDir = Kernel.Temporary.directory
        try ISO_9945.Kernel.Path.scope(tempDir) { dirPath in
            // Cross-platform contract:
            //   POSIX: open(O_RDONLY) + fsync + auto-close — must not throw.
            //   Windows: documented no-op — must not throw.
            try Kernel.File.Flush.directory(path: dirPath)
        }
    }
}

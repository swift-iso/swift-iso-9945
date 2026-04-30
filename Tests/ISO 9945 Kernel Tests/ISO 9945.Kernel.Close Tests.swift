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

import ISO_9945_Kernel_Test_Support
import ISO_9945_Kernel
import Kernel_Primitives_Core
import Kernel_File_Primitives
import Path_Primitives
import Error_Primitives
@_spi(Syscall) import Kernel_Primitives_Core
@_spi(Syscall) import Kernel_File_Primitives
@_spi(Syscall) import Path_Primitives
@_spi(Syscall) import Error_Primitives
import Testing

@testable import ISO_9945_Kernel

extension Kernel.Close {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Close Tests

extension Kernel.Close.Test.Unit {
    @Test
    func `close succeeds on valid descriptor`() throws {
        let path = KernelIOTest.makeTempPath(prefix: "close-test")
        defer { KernelIOTest.cleanup(path: path) }
        let fd = try KernelIOTest.open(at: path)

        try Kernel.Close.close(fd)
    }

    @Test
    func `close throws on invalid descriptor`() {
        #expect(throws: Kernel.Close.Error.self) {
            try Kernel.Close.close(.invalid)
        }
    }
}

// MARK: - Edge Cases

extension Kernel.Close.Test.EdgeCase {
    @Test
    func `close throws on negative descriptor`() {
        #expect(throws: Kernel.Close.Error.self) {
            try Kernel.Close.close(Kernel.Descriptor(_rawValue: -100))
        }
    }
}

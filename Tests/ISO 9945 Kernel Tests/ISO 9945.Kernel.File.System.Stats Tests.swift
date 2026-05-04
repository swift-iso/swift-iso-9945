// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

// Tests use Apple native Testing framework
import Testing
import Tagged_Primitives_Standard_Library_Integration
import ISO_9945_Kernel
import ISO_9945_Kernel_Test_Support


extension ISO_9945.Kernel.File.System.Stats {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension ISO_9945.Kernel.File.System.Stats.Test.Unit {
    @Test
    func `Statfs memberwise init`() {
        let fs = ISO_9945.Kernel.File.System.Stats(
            type: ISO_9945.Kernel.File.System.Kind(0x1234),
            blockSize: 4096,
            blocks: 1_000_000,
            freeBlocks: 500000,
            availableBlocks: 400000,
            files: 100000,
            freeFiles: 50000,
            fsid: 0xABCD,
            nameMax: 255
        )

        #expect(fs.type == ISO_9945.Kernel.File.System.Kind(0x1234))
        #expect(fs.blockSize == 4096)
        #expect(fs.blocks == 1_000_000)
        #expect(fs.freeBlocks == 500000)
        #expect(fs.availableBlocks == 400000)
        #expect(fs.files == 100000)
        #expect(fs.freeFiles == 50000)
        #expect(fs.fsid == 0xABCD)
        #expect(fs.nameMax == 255)
        #expect(fs.fsTypeName == nil)  // Default is nil
    }

    @Test
    func `Statfs with fsTypeName`() {
        let fs = ISO_9945.Kernel.File.System.Stats(
            type: ISO_9945.Kernel.File.System.Kind(0x1234),
            blockSize: 4096,
            blocks: 1_000_000,
            freeBlocks: 500000,
            availableBlocks: 400000,
            files: 100000,
            freeFiles: 50000,
            fsid: 0xABCD,
            nameMax: 255,
            fsTypeName: "apfs"
        )

        #expect(fs.fsTypeName == "apfs")
    }

    @Test
    func `Statfs is equatable`() {
        let fs1 = ISO_9945.Kernel.File.System.Stats(
            type: ISO_9945.Kernel.File.System.Kind(1),
            blockSize: 4096,
            blocks: 1000,
            freeBlocks: 500,
            availableBlocks: 400,
            files: 100,
            freeFiles: 50,
            fsid: 1,
            nameMax: 255
        )

        let fs2 = ISO_9945.Kernel.File.System.Stats(
            type: ISO_9945.Kernel.File.System.Kind(1),
            blockSize: 4096,
            blocks: 1000,
            freeBlocks: 500,
            availableBlocks: 400,
            files: 100,
            freeFiles: 50,
            fsid: 1,
            nameMax: 255
        )

        let fs3 = ISO_9945.Kernel.File.System.Stats(
            type: ISO_9945.Kernel.File.System.Kind(2),  // Different type
            blockSize: 4096,
            blocks: 1000,
            freeBlocks: 500,
            availableBlocks: 400,
            files: 100,
            freeFiles: 50,
            fsid: 1,
            nameMax: 255
        )

        #expect(fs1 == fs2)
        #expect(fs1 != fs3)
    }

    @Test
    func `Statfs is hashable`() {
        let fs1 = ISO_9945.Kernel.File.System.Stats(
            type: ISO_9945.Kernel.File.System.Kind(1),
            blockSize: 4096,
            blocks: 1000,
            freeBlocks: 500,
            availableBlocks: 400,
            files: 100,
            freeFiles: 50,
            fsid: 1,
            nameMax: 255
        )

        let fs2 = ISO_9945.Kernel.File.System.Stats(
            type: ISO_9945.Kernel.File.System.Kind(2),
            blockSize: 4096,
            blocks: 1000,
            freeBlocks: 500,
            availableBlocks: 400,
            files: 100,
            freeFiles: 50,
            fsid: 1,
            nameMax: 255
        )

        var set = Set<ISO_9945.Kernel.File.System.Stats>()
        set.insert(fs1)
        set.insert(fs1)  // Duplicate
        set.insert(fs2)

        #expect(set.count == 2)
    }
}

// MARK: - Computed Property Tests

extension ISO_9945.Kernel.File.System.Stats.Test.Unit {
    @Test
    func `availableBlocks <= freeBlocks (typical)`() {
        // In real filesystems, availableBlocks is typically <= freeBlocks
        // (root-reserved blocks)
        let fs = ISO_9945.Kernel.File.System.Stats(
            type: ISO_9945.Kernel.File.System.Kind(1),
            blockSize: 4096,
            blocks: 1000,
            freeBlocks: 500,
            availableBlocks: 400,  // Less than freeBlocks
            files: 100,
            freeFiles: 50,
            fsid: 1,
            nameMax: 255
        )

        #expect(fs.availableBlocks <= fs.freeBlocks)
    }
}

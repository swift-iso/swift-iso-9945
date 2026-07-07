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

import ISO_9945_Kernel
import ISO_9945_Kernel_Test_Support
import Tagged_Primitives_Standard_Library_Integration
// Tests use Apple native Testing framework
import Testing

extension ISO_9945.Kernel.File.Stats {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension ISO_9945.Kernel.File.Stats.Test.Unit {
    @Test
    func `Stat stores all fields`() {
        let time = ISO_9945.Kernel.Time(secondsSinceUnixEpoch: 1000)
        let stat = ISO_9945.Kernel.File.Stats(
            size: 1024,
            type: .regular,
            permissions: 0o644,
            uid: 501,
            gid: 20,
            inode: 12345,
            device: 1,
            linkCount: 1,
            accessTime: time,
            modificationTime: time,
            changeTime: time
        )

        #expect(stat.size == 1024)
        #expect(stat.type == .regular)
        #expect(stat.permissions == 0o644)
        #expect(stat.uid == 501)
        #expect(stat.gid == 20)
        #expect(stat.inode == 12345)
        #expect(stat.device == 1)
        #expect(stat.linkCount == 1)
    }

    @Test
    func `Stat is Sendable`() {
        let time = ISO_9945.Kernel.Time(secondsSinceUnixEpoch: 0)
        let stat: any Sendable = ISO_9945.Kernel.File.Stats(
            size: 0,
            type: .regular,
            permissions: 0,
            uid: 0,
            gid: 0,
            inode: 0,
            device: 0,
            linkCount: 0,
            accessTime: time,
            modificationTime: time,
            changeTime: time
        )
        #expect(stat is ISO_9945.Kernel.File.Stats)
    }

    @Test
    func `Stat is Equatable`() {
        let time = ISO_9945.Kernel.Time(secondsSinceUnixEpoch: 0)
        let a = ISO_9945.Kernel.File.Stats(
            size: 100,
            type: .regular,
            permissions: 0o644,
            uid: 0,
            gid: 0,
            inode: 1,
            device: 1,
            linkCount: 1,
            accessTime: time,
            modificationTime: time,
            changeTime: time
        )
        let b = ISO_9945.Kernel.File.Stats(
            size: 100,
            type: .regular,
            permissions: 0o644,
            uid: 0,
            gid: 0,
            inode: 1,
            device: 1,
            linkCount: 1,
            accessTime: time,
            modificationTime: time,
            changeTime: time
        )

        #expect(a == b)
    }
}

// MARK: - Kind Unit Tests

extension ISO_9945.Kernel.File.Stats.Test.Unit {
    @Test
    func `Kind cases are distinct`() {
        let cases: [ISO_9945.Kernel.File.Stats.Kind] = [
            .regular,
            .directory,
            .link(.symbolic),
            .device(.block),
            .device(.character),
            .fifo,
            .socket,
            .unknown,
        ]

        for (i, a) in cases.enumerated() {
            for (j, b) in cases.enumerated() {
                if i != j {
                    #expect(a != b, "Kind cases at \(i) and \(j) should differ")
                }
            }
        }
    }

    @Test
    func `Kind is Sendable`() {
        let kind: any Sendable = ISO_9945.Kernel.File.Stats.Kind.regular
        #expect(kind is ISO_9945.Kernel.File.Stats.Kind)
    }

    @Test
    func `Kind is Hashable`() {
        let a = ISO_9945.Kernel.File.Stats.Kind.regular
        let b = ISO_9945.Kernel.File.Stats.Kind.regular

        #expect(a.hashValue == b.hashValue)
    }

    @Test
    func `Kind.Link cases`() {
        let symbolic = ISO_9945.Kernel.File.Stats.Kind.Link.symbolic
        #expect(symbolic == .symbolic)
    }

    @Test
    func `Kind.Device cases are distinct`() {
        let block = ISO_9945.Kernel.File.Stats.Kind.Device.block
        let character = ISO_9945.Kernel.File.Stats.Kind.Device.character
        #expect(block != character)
    }
}

// MARK: - Edge Cases

extension ISO_9945.Kernel.File.Stats.Test.EdgeCase {
    @Test
    func `zero size file`() {
        let time = ISO_9945.Kernel.Time(secondsSinceUnixEpoch: 0)
        let stat = ISO_9945.Kernel.File.Stats(
            size: 0,
            type: .regular,
            permissions: 0,
            uid: 0,
            gid: 0,
            inode: 0,
            device: 0,
            linkCount: 0,
            accessTime: time,
            modificationTime: time,
            changeTime: time
        )

        #expect(stat.size == 0)
    }

    @Test
    func `maximum permissions`() {
        let time = ISO_9945.Kernel.Time(secondsSinceUnixEpoch: 0)
        let stat = ISO_9945.Kernel.File.Stats(
            size: 0,
            type: .regular,
            permissions: 0o7777,
            uid: 0,
            gid: 0,
            inode: 0,
            device: 0,
            linkCount: 0,
            accessTime: time,
            modificationTime: time,
            changeTime: time
        )

        #expect(stat.permissions == 0o7777)
    }
}

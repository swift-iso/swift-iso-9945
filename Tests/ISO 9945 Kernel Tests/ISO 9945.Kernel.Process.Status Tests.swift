// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

import Error_Primitives
import Path_Primitives
import Tagged_Primitives_Standard_Library_Integration
import Testing

@testable import ISO_9945_Kernel

extension ISO_9945.Kernel.Process.Status {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Unit Tests

extension ISO_9945.Kernel.Process.Status.Test.Unit {
    @Test
    func `status is RawRepresentable`() {
        let status = ISO_9945.Kernel.Process.Status(rawValue: 0)
        #expect(status.rawValue == 0)
    }

    @Test
    func `status is Sendable`() {
        let status: any Sendable = ISO_9945.Kernel.Process.Status(rawValue: 0)
        #expect(status is ISO_9945.Kernel.Process.Status)
    }

    @Test
    func `status is Equatable`() {
        #expect(ISO_9945.Kernel.Process.Status(rawValue: 0) == ISO_9945.Kernel.Process.Status(rawValue: 0))
        #expect(ISO_9945.Kernel.Process.Status(rawValue: 0) != ISO_9945.Kernel.Process.Status(rawValue: 1))
    }

    @Test
    func `status is Hashable`() {
        let status = ISO_9945.Kernel.Process.Status(rawValue: 42)
        var set = Set<ISO_9945.Kernel.Process.Status>()
        set.insert(status)
        #expect(set.contains(status))
    }
}

// MARK: - Nest.Name Accessor Tests

extension ISO_9945.Kernel.Process.Status.Test.Unit {
    @Test
    func `exit accessor returns Exit struct`() {
        let status = ISO_9945.Kernel.Process.Status(rawValue: 0)
        let exit = status.exit
        #expect(exit is ISO_9945.Kernel.Process.Status.Exit)
    }

    @Test
    func `terminating accessor returns Terminating struct`() {
        let status = ISO_9945.Kernel.Process.Status(rawValue: 0)
        let terminating = status.terminating
        #expect(terminating is ISO_9945.Kernel.Process.Status.Terminating)
    }

    @Test
    func `stop accessor returns Stop struct`() {
        let status = ISO_9945.Kernel.Process.Status(rawValue: 0)
        let stop = status.stop
        #expect(stop is ISO_9945.Kernel.Process.Status.Stop)
    }

    @Test
    func `core accessor returns Core struct`() {
        let status = ISO_9945.Kernel.Process.Status(rawValue: 0)
        let core = status.core
        #expect(core is ISO_9945.Kernel.Process.Status.Core)
    }
}

// MARK: - Classification Tests

extension ISO_9945.Kernel.Process.Status.Test.Unit {
    @Test
    func `Classification cases are distinct`() {
        let signal = ISO_9945.Kernel.Signal.Number(rawValue: 9)  // SIGKILL
        let cases: [ISO_9945.Kernel.Process.Status.Classification] = [
            .exited(code: 0),
            .signaled(signal: signal, false),
            .stopped(signal: signal),
            .continued,
        ]

        for (i, a) in cases.enumerated() {
            for (j, b) in cases.enumerated() {
                if i != j {
                    #expect(a != b, "Cases at index \(i) and \(j) should be different")
                }
            }
        }
    }

    @Test
    func `exited classifications with different codes are different`() {
        #expect(
            ISO_9945.Kernel.Process.Status.Classification.exited(code: 0)
                != ISO_9945.Kernel.Process.Status.Classification.exited(code: 1)
        )
    }

    @Test
    func `signaled classifications with different signals are different`() {
        let sig9 = ISO_9945.Kernel.Signal.Number(rawValue: 9)
        let sig15 = ISO_9945.Kernel.Signal.Number(rawValue: 15)
        #expect(
            ISO_9945.Kernel.Process.Status.Classification.signaled(signal: sig9, false)
                != ISO_9945.Kernel.Process.Status.Classification.signaled(signal: sig15, false)
        )
    }

    @Test
    func `signaled classifications with different core dump are different`() {
        let sig = ISO_9945.Kernel.Signal.Number(rawValue: 9)
        #expect(
            ISO_9945.Kernel.Process.Status.Classification.signaled(signal: sig, false)
                != ISO_9945.Kernel.Process.Status.Classification.signaled(signal: sig, true)
        )
    }
}

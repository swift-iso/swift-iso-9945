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


import Testing

    import Kernel_Primitives_Core
    import Kernel_Descriptor_Primitives
    import Kernel_Event_Primitives
    import Kernel_IO_Primitives
    import Kernel_File_Primitives
    import Kernel_Path_Primitives
    import Kernel_Environment_Primitives
    import Kernel_Process_Primitives
    import Kernel_Thread_Primitives
    import Kernel_Error_Primitives
    @testable import ISO_9945_Kernel

    extension Kernel.Process.Status {
        @Suite
        struct Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Unit Tests

    extension Kernel.Process.Status.Test.Unit {
        @Test
        func `status is RawRepresentable`() {
            let status = Kernel.Process.Status(rawValue: 0)
            #expect(status.rawValue == 0)
        }

        @Test
        func `status is Sendable`() {
            let status: any Sendable = Kernel.Process.Status(rawValue: 0)
            #expect(status is Kernel.Process.Status)
        }

        @Test
        func `status is Equatable`() {
            #expect(Kernel.Process.Status(rawValue: 0) == Kernel.Process.Status(rawValue: 0))
            #expect(Kernel.Process.Status(rawValue: 0) != Kernel.Process.Status(rawValue: 1))
        }

        @Test
        func `status is Hashable`() {
            let status = Kernel.Process.Status(rawValue: 42)
            var set = Set<Kernel.Process.Status>()
            set.insert(status)
            #expect(set.contains(status))
        }
    }

    // MARK: - Nest.Name Accessor Tests

    extension Kernel.Process.Status.Test.Unit {
        @Test
        func `exit accessor returns Exit struct`() {
            let status = Kernel.Process.Status(rawValue: 0)
            let exit = status.exit
            #expect(exit is Kernel.Process.Status.Exit)
        }

        @Test
        func `terminating accessor returns Terminating struct`() {
            let status = Kernel.Process.Status(rawValue: 0)
            let terminating = status.terminating
            #expect(terminating is Kernel.Process.Status.Terminating)
        }

        @Test
        func `stop accessor returns Stop struct`() {
            let status = Kernel.Process.Status(rawValue: 0)
            let stop = status.stop
            #expect(stop is Kernel.Process.Status.Stop)
        }

        @Test
        func `core accessor returns Core struct`() {
            let status = Kernel.Process.Status(rawValue: 0)
            let core = status.core
            #expect(core is Kernel.Process.Status.Core)
        }
    }

    // MARK: - Classification Tests

    extension Kernel.Process.Status.Test.Unit {
        @Test
        func `Classification cases are distinct`() {
            let signal = Kernel.Signal.Number(rawValue: 9)  // SIGKILL
            let cases: [Kernel.Process.Status.Classification] = [
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
                Kernel.Process.Status.Classification.exited(code: 0)
                    != Kernel.Process.Status.Classification.exited(code: 1)
            )
        }

        @Test
        func `signaled classifications with different signals are different`() {
            let sig9 = Kernel.Signal.Number(rawValue: 9)
            let sig15 = Kernel.Signal.Number(rawValue: 15)
            #expect(
                Kernel.Process.Status.Classification.signaled(signal: sig9, false)
                    != Kernel.Process.Status.Classification.signaled(signal: sig15, false)
            )
        }

        @Test
        func `signaled classifications with different core dump are different`() {
            let sig = Kernel.Signal.Number(rawValue: 9)
            #expect(
                Kernel.Process.Status.Classification.signaled(signal: sig, false)
                    != Kernel.Process.Status.Classification.signaled(signal: sig, true)
            )
        }
    }


// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-posix open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-posix project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//


import Testing

    import Kernel_Primitives_Core
    import Kernel_Descriptor_Primitives
    import Kernel_Event_Primitives
    import Kernel_File_Primitives
    import Path_Primitives
    import Kernel_Environment_Primitives
    import Kernel_Process_Primitives
    import Kernel_Thread_Primitives
    import Error_Primitives
    @testable import ISO_9945_Kernel
import ISO_9945_Kernel

    extension ISO_9945.Kernel.Device {
        @Suite
        struct Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Major/Minor Tests

    extension ISO_9945.Kernel.Device.Test.Unit {
        @Test
        func `Device major/minor extraction`() {
            // Create a device with known major/minor
            let device = ISO_9945.Kernel.Device(major: 8, minor: 1)
            #expect(device.major == 8)
            #expect(device.minor == 1)
        }

        @Test
        func `Device major/minor roundtrip`() {
            let major: ISO_9945.Kernel.Device.Major = 253
            let minor: ISO_9945.Kernel.Device.Minor = 42
            let device = ISO_9945.Kernel.Device(major: major, minor: minor)
            #expect(device.major == major)
            #expect(device.minor == minor)
        }
    }

    // MARK: - Typed Major/Minor Tests

    extension ISO_9945.Kernel.Device.Test.Unit {
        @Test
        func `Device typed major/minor`() {
            let device = ISO_9945.Kernel.Device(major: 8, minor: 16)
            let major = device.major
            let minor = device.minor
            #expect(major == 8)
            #expect(minor == 16)
        }

        @Test
        func `Device init from typed major/minor`() {
            let major = ISO_9945.Kernel.Device.Major(rawValue: 253)
            let minor = ISO_9945.Kernel.Device.Minor(rawValue: 42)
            let device = ISO_9945.Kernel.Device(major: major, minor: minor)
            #expect(device.major == 253)
            #expect(device.minor == 42)
        }
    }

    // MARK: - CustomStringConvertible Tests

    extension ISO_9945.Kernel.Device.Test.Unit {
        @Test
        func `Device description contains colon`() {
            let device = ISO_9945.Kernel.Device(major: 8, minor: 1)
            #expect(device.description.contains(":"))
        }

        @Test
        func `Device description format`() {
            let device = ISO_9945.Kernel.Device(major: 8, minor: 1)
            #expect(device.description == "8:1")
        }
    }


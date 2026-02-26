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
import ISO_9945_Kernel_Test_Support
import ISO_9945
import Kernel_Primitives

@testable import ISO_9945_Kernel

extension Kernel.Descriptor {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Kernel.Descriptor.Test.Unit {
    @Test("invalid descriptor has correct raw value on POSIX")
    func invalidDescriptorValue() {
        #if !os(Windows)
            #expect(Kernel.Descriptor.invalid._raw == -1)
        #endif
    }

    @Test("isValid returns false for invalid descriptor")
    func isValidFalseForInvalid() {
        #expect(!Kernel.Descriptor.invalid.isValid)
    }

    @Test("isValid returns true for valid descriptor")
    func isValidTrueForValid() {
        #if !os(Windows)
            // Standard input (0), stdout (1), stderr (2) are always valid
            #expect(Kernel.Descriptor(_raw: 0).isValid)
            #expect(Kernel.Descriptor(_raw: 1).isValid)
            #expect(Kernel.Descriptor(_raw: 2).isValid)
        #endif
    }

    @Test("internal raw roundtrip preserves value")
    func internalRawRoundtrip() {
        #if !os(Windows)
            let original = Kernel.Descriptor(_raw: 42)
            let reconstructed = Kernel.Descriptor(_raw: original._raw)
            #expect(original == reconstructed)
            #expect(original._raw == 42)
        #endif
    }

    @Test("Descriptor is Equatable")
    func descriptorIsEquatable() {
        #if !os(Windows)
            let a = Kernel.Descriptor(_raw: 5)
            let b = Kernel.Descriptor(_raw: 5)
            let c = Kernel.Descriptor(_raw: 10)

            #expect(a == b)
            #expect(a != c)
        #endif
    }

    @Test("Descriptor is Hashable")
    func descriptorIsHashable() {
        #if !os(Windows)
            var set = Set<Kernel.Descriptor>()
            set.insert(Kernel.Descriptor(_raw: 1))
            set.insert(Kernel.Descriptor(_raw: 2))
            set.insert(Kernel.Descriptor(_raw: 1))  // duplicate

            #expect(set.count == 2)
        #endif
    }

    @Test("Descriptor works in Dictionary")
    func descriptorInDictionary() {
        #if !os(Windows)
            var dict = [Kernel.Descriptor: String]()
            dict[Kernel.Descriptor(_raw: 0)] = "stdin"
            dict[Kernel.Descriptor(_raw: 1)] = "stdout"
            dict[Kernel.Descriptor(_raw: 2)] = "stderr"

            #expect(dict[Kernel.Descriptor(_raw: 0)] == "stdin")
            #expect(dict[Kernel.Descriptor(_raw: 1)] == "stdout")
            #expect(dict[Kernel.Descriptor(_raw: 2)] == "stderr")
            #expect(dict.count == 3)
        #endif
    }

    @Test("negative descriptors are invalid on POSIX")
    func negativeDescriptorsInvalid() {
        #if !os(Windows)
            #expect(!Kernel.Descriptor(_raw: -1).isValid)
            #expect(!Kernel.Descriptor(_raw: -100).isValid)
            #expect(!Kernel.Descriptor(_raw: Int32.min).isValid)
        #endif
    }
}

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
@_spi(Syscall) import Kernel_Primitives

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
            #expect(Kernel.Descriptor.invalid == Kernel.Descriptor(_rawValue: -1))
    }

    @Test("isValid returns false for invalid descriptor")
    func isValidFalseForInvalid() {
        #expect(!Kernel.Descriptor.invalid.isValid)
    }

    @Test("isValid returns true for valid descriptor")
    func isValidTrueForValid() {
            // Standard input (0), stdout (1), stderr (2) are always valid
            #expect(Kernel.Descriptor(_rawValue: 0).isValid)
            #expect(Kernel.Descriptor(_rawValue: 1).isValid)
            #expect(Kernel.Descriptor(_rawValue: 2).isValid)
    }

    @Test("internal raw roundtrip preserves value")
    func internalRawRoundtrip() {
            let original = Kernel.Descriptor(_rawValue: 42)
            let reconstructed = Kernel.Descriptor(_rawValue: 42)
            #expect(original == reconstructed)
    }

    @Test("Descriptor is Equatable")
    func descriptorIsEquatable() {
            let a = Kernel.Descriptor(_rawValue: 5)
            let b = Kernel.Descriptor(_rawValue: 5)
            let c = Kernel.Descriptor(_rawValue: 10)

            #expect(a == b)
            #expect(a != c)
    }

    @Test("Descriptor is Hashable")
    func descriptorIsHashable() {
            var set = Set<Kernel.Descriptor>()
            set.insert(Kernel.Descriptor(_rawValue: 1))
            set.insert(Kernel.Descriptor(_rawValue: 2))
            set.insert(Kernel.Descriptor(_rawValue: 1))  // duplicate

            #expect(set.count == 2)
    }

    @Test("Descriptor works in Dictionary")
    func descriptorInDictionary() {
            var dict = [Kernel.Descriptor: Swift.String]()
            dict[Kernel.Descriptor(_rawValue: 0)] = "stdin"
            dict[Kernel.Descriptor(_rawValue: 1)] = "stdout"
            dict[Kernel.Descriptor(_rawValue: 2)] = "stderr"

            #expect(dict[Kernel.Descriptor(_rawValue: 0)] == "stdin")
            #expect(dict[Kernel.Descriptor(_rawValue: 1)] == "stdout")
            #expect(dict[Kernel.Descriptor(_rawValue: 2)] == "stderr")
            #expect(dict.count == 3)
    }

    @Test("negative descriptors are invalid on POSIX")
    func negativeDescriptorsInvalid() {
            #expect(!Kernel.Descriptor(_rawValue: -1).isValid)
            #expect(!Kernel.Descriptor(_rawValue: -100).isValid)
            #expect(!Kernel.Descriptor(_rawValue: Int32.min).isValid)
    }
}

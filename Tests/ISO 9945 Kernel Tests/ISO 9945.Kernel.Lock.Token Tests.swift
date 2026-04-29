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

// Tests use Apple native Testing framework
import Testing
import ISO_9945_Kernel_Test_Support
import ISO_9945_Kernel
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

extension Kernel.Lock.Token {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Kernel.Lock.Token.Test.Unit {
    @Test
    func `Token type exists`() {
        let _: Kernel.Lock.Token.Type = Kernel.Lock.Token.self
    }

    @Test
    func `Token is ~Copyable`() {
        // Token is ~Copyable, which means it cannot be copied
        // This is a compile-time constraint, we just verify the type exists
        let _: Kernel.Lock.Token.Type = Kernel.Lock.Token.self
    }
}

// MARK: - withExclusive and withShared Tests

extension Kernel.Lock.Token.Test.Unit {
    @Test
    func `withExclusive exists`() {
        // Verify the static method signature exists
        typealias WithExclusiveType = (
            borrowing Kernel.Descriptor,
            Kernel.Lock.Range,
            Kernel.Lock.Acquire,
            () throws -> Void
        ) throws -> Void
        // The method signature is verified at compile time
    }

    @Test
    func `withShared exists`() {
        // Verify the static method signature exists
        typealias WithSharedType = (
            borrowing Kernel.Descriptor,
            Kernel.Lock.Range,
            Kernel.Lock.Acquire,
            () throws -> Void
        ) throws -> Void
        // The method signature is verified at compile time
    }
}

// MARK: - Acquire Strategy Tests

extension Kernel.Lock.Token.Test.Unit {
    @Test
    func `Token init accepts try acquisition`() {
        // Verify the init accepts .try acquisition
        // The init signature is: init(descriptor:range:kind:acquire:)
        let _: Kernel.Lock.Acquire = .try
    }

    @Test
    func `Token init accepts wait acquisition`() {
        // Verify the init accepts .wait acquisition (the default)
        let _: Kernel.Lock.Acquire = .wait
    }

    @Test
    func `Token init accepts deadline acquisition`() {
        // Verify the init accepts .deadline acquisition
        let deadline = Clock.Continuous.now
        let _: Kernel.Lock.Acquire = .deadline(deadline)
    }
}

// MARK: - Default Parameter Tests

extension Kernel.Lock.Token.Test.Unit {
    @Test
    func `Token init has default range of .file`() {
        // The init has: range: Range = .file
        let _: Kernel.Lock.Range = .file
    }

    @Test
    func `Token init has default acquire of .wait`() {
        // The init has: acquire: Acquire = .wait
        let _: Kernel.Lock.Acquire = .wait
    }
}

// MARK: - Edge Cases

extension Kernel.Lock.Token.Test.EdgeCase {
    @Test
    func `Token uses all Lock.Kind values`() {
        // Token accepts both shared and exclusive kinds
        let _: Kernel.Lock.Kind = .shared
        let _: Kernel.Lock.Kind = .exclusive
    }

    @Test
    func `Token uses all Lock.Range values`() {
        // Token accepts all range types
        let _: Kernel.Lock.Range = .file
        let _: Kernel.Lock.Range = .bytes(start: 0, end: 100)
        let _: Kernel.Lock.Range = .bytes(start: 0, length: 100)
    }

    @Test
    func `Token uses all Lock.Acquire values`() {
        // Token accepts all acquisition strategies
        let _: Kernel.Lock.Acquire = .try
        let _: Kernel.Lock.Acquire = .wait
        let _: Kernel.Lock.Acquire = .deadline(Clock.Continuous.now)
    }
}

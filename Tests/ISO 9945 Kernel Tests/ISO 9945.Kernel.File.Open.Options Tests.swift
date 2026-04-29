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
import Kernel_Process_Primitives
import Kernel_Thread_Primitives
import Error_Primitives

#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#elseif canImport(Musl)
    import Musl
#endif

@testable import ISO_9945_Kernel

extension Kernel.File.Open.Options {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Kernel.File.Open.Options.Test.Unit {
    @Test
    func `Options from rawValue`() {
        let options = Kernel.File.Open.Options(rawValue: 1)
        #expect(options.rawValue == 1)
    }
}

// MARK: - Standard Options

extension Kernel.File.Open.Options.Test.Unit {
    @Test
    func `create maps to O_CREAT`() {
        #expect(Kernel.File.Open.Options.create.rawValue == O_CREAT)
    }

    @Test
    func `truncate maps to O_TRUNC`() {
        #expect(Kernel.File.Open.Options.truncate.rawValue == O_TRUNC)
    }

    @Test
    func `append maps to O_APPEND`() {
        #expect(Kernel.File.Open.Options.append.rawValue == O_APPEND)
    }

    @Test
    func `exclusive maps to O_EXCL`() {
        #expect(Kernel.File.Open.Options.exclusive.rawValue == O_EXCL)
    }

    @Test
    func `noFollow maps to O_NOFOLLOW`() {
        #expect(Kernel.File.Open.Options.noFollow.rawValue == O_NOFOLLOW)
    }
}

// MARK: - OptionSet Operations

extension Kernel.File.Open.Options.Test.Unit {
    @Test
    func `options can be combined`() {
        let options: Kernel.File.Open.Options = [.create, .truncate]
        #expect(options.contains(.create))
        #expect(options.contains(.truncate))
    }

    @Test
    func `contains check`() {
        let options: Kernel.File.Open.Options = [.create, .exclusive]
        #expect(options.contains(.create))
        #expect(options.contains(.exclusive))
        #expect(!options.contains(.append))
    }

    @Test
    func `empty options`() {
        let options = Kernel.File.Open.Options()
        #expect(!options.contains(.create))
        #expect(!options.contains(.truncate))
    }

    @Test
    func `union of options`() {
        let a: Kernel.File.Open.Options = [.create]
        let b: Kernel.File.Open.Options = [.truncate]
        let combined = a.union(b)
        #expect(combined.contains(.create))
        #expect(combined.contains(.truncate))
    }

    @Test
    func `intersection of options`() {
        let a: Kernel.File.Open.Options = [.create, .truncate]
        let b: Kernel.File.Open.Options = [.truncate, .append]
        let common = a.intersection(b)
        #expect(!common.contains(.create))
        #expect(common.contains(.truncate))
        #expect(!common.contains(.append))
    }
}

// MARK: - POSIX Flag Verification

extension Kernel.File.Open.Options.Test.Unit {
    @Test
    func `create rawValue contains O_CREAT`() {
        let options: Kernel.File.Open.Options = [.create]
        #expect(options.rawValue & O_CREAT != 0)
    }

    @Test
    func `truncate rawValue contains O_TRUNC`() {
        let options: Kernel.File.Open.Options = [.truncate]
        #expect(options.rawValue & O_TRUNC != 0)
    }

    @Test
    func `append rawValue contains O_APPEND`() {
        let options: Kernel.File.Open.Options = [.append]
        #expect(options.rawValue & O_APPEND != 0)
    }

    @Test
    func `exclusive rawValue contains O_EXCL`() {
        let options: Kernel.File.Open.Options = [.exclusive]
        #expect(options.rawValue & O_EXCL != 0)
    }

    @Test
    func `noFollow rawValue contains O_NOFOLLOW`() {
        let options: Kernel.File.Open.Options = [.noFollow]
        #expect(options.rawValue & O_NOFOLLOW != 0)
    }

    @Test
    func `combined options rawValue maps correctly`() {
        let options: Kernel.File.Open.Options = [.create, .truncate, .exclusive]
        let flags = options.rawValue
        #expect(flags & O_CREAT != 0)
        #expect(flags & O_TRUNC != 0)
        #expect(flags & O_EXCL != 0)
    }

    @Test
    func `empty options have zero rawValue`() {
        let options = Kernel.File.Open.Options()
        #expect(options.rawValue == 0)
    }
}

// MARK: - Conformances

extension Kernel.File.Open.Options.Test.Unit {
    @Test
    func `Options is Sendable`() {
        let options: any Sendable = Kernel.File.Open.Options.create
        #expect(options is Kernel.File.Open.Options)
    }

    @Test
    func `Options is Equatable`() {
        let a: Kernel.File.Open.Options = [.create]
        let b: Kernel.File.Open.Options = [.create]
        let c: Kernel.File.Open.Options = [.truncate]
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Options is Hashable`() {
        var set = Set<Kernel.File.Open.Options>()
        set.insert([.create])
        set.insert([.truncate])
        set.insert([.create])  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Edge Cases

extension Kernel.File.Open.Options.Test.EdgeCase {
    @Test
    func `all standard options are distinct`() {
        let options: [Kernel.File.Open.Options] = [
            .create, .truncate, .append, .exclusive, .noFollow,
        ]
        for i in 0..<options.count {
            for j in (i + 1)..<options.count {
                #expect(options[i].rawValue & options[j].rawValue == 0)
            }
        }
    }

    @Test
    func `common file creation pattern`() {
        let options: Kernel.File.Open.Options = [.create, .truncate]
        #expect(options.contains(.create))
        #expect(options.contains(.truncate))
    }

    @Test
    func `exclusive create pattern`() {
        let options: Kernel.File.Open.Options = [.create, .exclusive]
        #expect(options.contains(.create))
        #expect(options.contains(.exclusive))
    }
}

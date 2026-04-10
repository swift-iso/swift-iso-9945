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
import Kernel_IO_Primitives
import Kernel_File_Primitives
import Kernel_Path_Primitives
import Kernel_Environment_Primitives
import Kernel_Process_Primitives
import Kernel_Thread_Primitives
import Kernel_Error_Primitives

#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
    import CLinuxShim
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
    @Test("Options from rawValue")
    func rawValueInit() {
        let options = Kernel.File.Open.Options(rawValue: 1)
        #expect(options.rawValue == 1)
    }
}

// MARK: - Standard Options

extension Kernel.File.Open.Options.Test.Unit {
    @Test("create maps to O_CREAT")
    func createConstant() {
        #expect(Kernel.File.Open.Options.create.rawValue == O_CREAT)
    }

    @Test("truncate maps to O_TRUNC")
    func truncateConstant() {
        #expect(Kernel.File.Open.Options.truncate.rawValue == O_TRUNC)
    }

    @Test("append maps to O_APPEND")
    func appendConstant() {
        #expect(Kernel.File.Open.Options.append.rawValue == O_APPEND)
    }

    @Test("exclusive maps to O_EXCL")
    func exclusiveConstant() {
        #expect(Kernel.File.Open.Options.exclusive.rawValue == O_EXCL)
    }

    @Test("noFollow maps to O_NOFOLLOW")
    func noFollowConstant() {
        #expect(Kernel.File.Open.Options.noFollow.rawValue == O_NOFOLLOW)
    }

    #if os(Linux)
        @Test("direct maps to O_DIRECT on Linux")
        func directConstant() {
            #expect(Kernel.File.Open.Options.direct.rawValue == O_DIRECT)
        }
    #endif
}

// MARK: - OptionSet Operations

extension Kernel.File.Open.Options.Test.Unit {
    @Test("options can be combined")
    func combinedOptions() {
        let options: Kernel.File.Open.Options = [.create, .truncate]
        #expect(options.contains(.create))
        #expect(options.contains(.truncate))
    }

    @Test("contains check")
    func containsCheck() {
        let options: Kernel.File.Open.Options = [.create, .exclusive]
        #expect(options.contains(.create))
        #expect(options.contains(.exclusive))
        #expect(!options.contains(.append))
    }

    @Test("empty options")
    func emptyOptions() {
        let options = Kernel.File.Open.Options()
        #expect(!options.contains(.create))
        #expect(!options.contains(.truncate))
    }

    @Test("union of options")
    func unionOptions() {
        let a: Kernel.File.Open.Options = [.create]
        let b: Kernel.File.Open.Options = [.truncate]
        let combined = a.union(b)
        #expect(combined.contains(.create))
        #expect(combined.contains(.truncate))
    }

    @Test("intersection of options")
    func intersectionOptions() {
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
    @Test("create rawValue contains O_CREAT")
    func createPosixFlags() {
        let options: Kernel.File.Open.Options = [.create]
        #expect(options.rawValue & O_CREAT != 0)
    }

    @Test("truncate rawValue contains O_TRUNC")
    func truncatePosixFlags() {
        let options: Kernel.File.Open.Options = [.truncate]
        #expect(options.rawValue & O_TRUNC != 0)
    }

    @Test("append rawValue contains O_APPEND")
    func appendPosixFlags() {
        let options: Kernel.File.Open.Options = [.append]
        #expect(options.rawValue & O_APPEND != 0)
    }

    @Test("exclusive rawValue contains O_EXCL")
    func exclusivePosixFlags() {
        let options: Kernel.File.Open.Options = [.exclusive]
        #expect(options.rawValue & O_EXCL != 0)
    }

    @Test("noFollow rawValue contains O_NOFOLLOW")
    func noFollowPosixFlags() {
        let options: Kernel.File.Open.Options = [.noFollow]
        #expect(options.rawValue & O_NOFOLLOW != 0)
    }

    @Test("combined options rawValue maps correctly")
    func combinedPosixFlags() {
        let options: Kernel.File.Open.Options = [.create, .truncate, .exclusive]
        let flags = options.rawValue
        #expect(flags & O_CREAT != 0)
        #expect(flags & O_TRUNC != 0)
        #expect(flags & O_EXCL != 0)
    }

    @Test("empty options have zero rawValue")
    func emptyPosixFlags() {
        let options = Kernel.File.Open.Options()
        #expect(options.rawValue == 0)
    }

    #if os(Linux)
        @Test("direct rawValue contains O_DIRECT on Linux")
        func directPosixFlags() {
            let options: Kernel.File.Open.Options = [.direct]
            #expect(options.rawValue & O_DIRECT != 0)
        }
    #endif
}

// MARK: - Conformances

extension Kernel.File.Open.Options.Test.Unit {
    @Test("Options is Sendable")
    func isSendable() {
        let options: any Sendable = Kernel.File.Open.Options.create
        #expect(options is Kernel.File.Open.Options)
    }

    @Test("Options is Equatable")
    func isEquatable() {
        let a: Kernel.File.Open.Options = [.create]
        let b: Kernel.File.Open.Options = [.create]
        let c: Kernel.File.Open.Options = [.truncate]
        #expect(a == b)
        #expect(a != c)
    }

    @Test("Options is Hashable")
    func isHashable() {
        var set = Set<Kernel.File.Open.Options>()
        set.insert([.create])
        set.insert([.truncate])
        set.insert([.create])  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Edge Cases

extension Kernel.File.Open.Options.Test.EdgeCase {
    @Test("all standard options are distinct")
    func distinctBits() {
        var options: [Kernel.File.Open.Options] = [
            .create, .truncate, .append, .exclusive, .noFollow,
        ]
        #if os(Linux)
            options.append(.direct)
        #endif
        for i in 0..<options.count {
            for j in (i + 1)..<options.count {
                #expect(options[i].rawValue & options[j].rawValue == 0)
            }
        }
    }

    @Test("common file creation pattern")
    func createTruncatePattern() {
        let options: Kernel.File.Open.Options = [.create, .truncate]
        #expect(options.contains(.create))
        #expect(options.contains(.truncate))
    }

    @Test("exclusive create pattern")
    func exclusiveCreatePattern() {
        let options: Kernel.File.Open.Options = [.create, .exclusive]
        #expect(options.contains(.create))
        #expect(options.contains(.exclusive))
    }
}

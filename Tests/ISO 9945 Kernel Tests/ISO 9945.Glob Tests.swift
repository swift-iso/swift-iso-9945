// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

import ISO_9945_Glob
import Path_Primitives
import Testing

// MARK: - fnmatch Tests

extension ISO_9945.Glob.Fnmatch {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
    }
}

extension ISO_9945.Glob.Fnmatch.Test.Unit {
    @Testing.Test
    func `star wildcard matches suffix`() throws {
        let matched = try Path.scope("*.swift", "file.swift") { pattern, name in
            ISO_9945.Glob.fnmatch(pattern: pattern, name: name)
        }
        #expect(matched)
    }

    @Testing.Test
    func `star wildcard rejects non-matching suffix`() throws {
        let matched = try Path.scope("*.swift", "file.rs") { pattern, name in
            ISO_9945.Glob.fnmatch(pattern: pattern, name: name)
        }
        #expect(!matched)
    }

    @Testing.Test
    func `question mark matches single character`() throws {
        let matched = try Path.scope("file.?", "file.c") { pattern, name in
            ISO_9945.Glob.fnmatch(pattern: pattern, name: name)
        }
        #expect(matched)
    }

    @Testing.Test
    func `question mark rejects multi-character`() throws {
        let matched = try Path.scope("file.?", "file.rs") { pattern, name in
            ISO_9945.Glob.fnmatch(pattern: pattern, name: name)
        }
        #expect(!matched)
    }

    @Testing.Test
    func `character class matches member`() throws {
        let matched = try Path.scope("[abc]", "a") { pattern, name in
            ISO_9945.Glob.fnmatch(pattern: pattern, name: name)
        }
        #expect(matched)
    }

    @Testing.Test
    func `character class rejects non-member`() throws {
        let matched = try Path.scope("[abc]", "d") { pattern, name in
            ISO_9945.Glob.fnmatch(pattern: pattern, name: name)
        }
        #expect(!matched)
    }

    @Testing.Test
    func `negated class matches non-member`() throws {
        let matched = try Path.scope("[!abc]", "d") { pattern, name in
            ISO_9945.Glob.fnmatch(pattern: pattern, name: name)
        }
        #expect(matched)
    }

    @Testing.Test
    func `negated class rejects member`() throws {
        let matched = try Path.scope("[!abc]", "a") { pattern, name in
            ISO_9945.Glob.fnmatch(pattern: pattern, name: name)
        }
        #expect(!matched)
    }

    @Testing.Test
    func `casefold matches different case`() throws {
        let matched = try Path.scope("*.SWIFT", "file.swift") { pattern, name in
            ISO_9945.Glob.fnmatch(pattern: pattern, name: name, options: .casefold)
        }
        #expect(matched)
    }

    @Testing.Test
    func `without casefold rejects different case`() throws {
        let matched = try Path.scope("*.SWIFT", "file.swift") { pattern, name in
            ISO_9945.Glob.fnmatch(pattern: pattern, name: name)
        }
        #expect(!matched)
    }

    @Testing.Test
    func `exact literal matches`() throws {
        let matched = try Path.scope("hello.txt", "hello.txt") { pattern, name in
            ISO_9945.Glob.fnmatch(pattern: pattern, name: name)
        }
        #expect(matched)
    }

    @Testing.Test
    func `exact literal rejects different name`() throws {
        let matched = try Path.scope("hello.txt", "other.txt") { pattern, name in
            ISO_9945.Glob.fnmatch(pattern: pattern, name: name)
        }
        #expect(!matched)
    }

    @Testing.Test
    func `star matches empty prefix`() throws {
        let matched = try Path.scope("*.txt", ".txt") { pattern, name in
            ISO_9945.Glob.fnmatch(pattern: pattern, name: name)
        }
        #expect(matched)
    }
}

extension ISO_9945.Glob.Fnmatch.Test.`Edge Case` {
    @Testing.Test
    func `period flag prevents star from matching leading dot`() throws {
        let matched = try Path.scope("*", ".hidden") { pattern, name in
            ISO_9945.Glob.fnmatch(pattern: pattern, name: name, options: .period)
        }
        #expect(!matched)
    }

    @Testing.Test
    func `period flag allows literal dot match`() throws {
        let matched = try Path.scope(".*", ".hidden") { pattern, name in
            ISO_9945.Glob.fnmatch(pattern: pattern, name: name, options: .period)
        }
        #expect(matched)
    }

    @Testing.Test
    func `pathname flag prevents star from matching slash`() throws {
        let matched = try Path.scope("*", "a/b") { pattern, name in
            ISO_9945.Glob.fnmatch(pattern: pattern, name: name, options: .pathname)
        }
        #expect(!matched)
    }

    @Testing.Test
    func `without pathname star matches slash`() throws {
        let matched = try Path.scope("*", "a/b") { pattern, name in
            ISO_9945.Glob.fnmatch(pattern: pattern, name: name)
        }
        #expect(matched)
    }
}

// MARK: - glob(3) Expand Tests

extension ISO_9945.Glob.Expand {
    @Suite
    struct Test {
        @Suite struct Unit {}
    }
}

extension ISO_9945.Glob.Expand.Test.Unit {
    @Testing.Test
    func `non-existent pattern throws noMatch`() throws {
        do throws(Path.String.Error<ISO_9945.Glob.Expand.Error>) {
            _ = try Path.scope("/tmp/iso9945-glob-test-nonexistent-dir-*") { pattern throws(ISO_9945.Glob.Expand.Error) in
                try ISO_9945.Glob.expand(pattern: pattern)
            }
            Issue.record("Expected noMatch error")
        } catch where error.body == .noMatch {
            // Expected
        }
    }
}

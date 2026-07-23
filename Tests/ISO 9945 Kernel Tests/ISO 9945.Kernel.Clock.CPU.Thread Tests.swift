// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

import Testing

@testable import ISO_9945_Kernel

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux)
extension Clock.CPU.Thread {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

extension Clock.CPU.Thread.Test.Unit {
    @Test
    func `now advances while the calling thread consumes CPU`() {
        let before = Clock.CPU.Thread.now()

        #expect((0..<100_000).reduce(0, &+) != 0)

        let after = Clock.CPU.Thread.now()
        #expect(after > before)
    }
}
#endif

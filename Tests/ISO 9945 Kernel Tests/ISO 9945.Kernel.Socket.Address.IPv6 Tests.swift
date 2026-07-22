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

@Suite
struct `IPv6 Socket Address Tests` {
    @Test
    func `host order segments round trip with metadata`() {
        let segments: (UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16) =
            (0x2001, 0x0db8, 0, 1, 2, 3, 4, 5)
        let address = ISO_9945.Kernel.Socket.Address.IPv6(
            segments: segments,
            port: 8443,
            flowInfo: 7,
            scopeId: 9
        )

        #expect(address.segments.0 == segments.0)
        #expect(address.segments.1 == segments.1)
        #expect(address.segments.2 == segments.2)
        #expect(address.segments.3 == segments.3)
        #expect(address.segments.4 == segments.4)
        #expect(address.segments.5 == segments.5)
        #expect(address.segments.6 == segments.6)
        #expect(address.segments.7 == segments.7)
        #expect(address.port == 8443)
        #expect(address.flowInfo == 7)
        #expect(address.scopeId == 9)
    }
}
